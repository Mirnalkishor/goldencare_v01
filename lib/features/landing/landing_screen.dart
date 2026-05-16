/// Landing page — replicates web screen at route /
/// This is the FIRST screen users see. NOT login.
/// Contains: Nav, Hero, Stats, Services, How It Works, Platform Highlights, CTA, Footer
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../core/spacing.dart';
import '../../core/typography.dart';
import '../../core/constants.dart';
import '../../core/widgets/gc_button.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/service_model.dart';
import '../bookings/booking_screen.dart';
import '../auth/auth_controller.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _scrolled = false;
  bool _mobileMenuOpen = false;

  // Scroll keys for anchor navigation
  final _servicesKey = GlobalKey();
  final _howItWorksKey = GlobalKey();
  final _platformHighlightsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final isScrolled = _scrollController.offset > 50;
      if (isScrolled != _scrolled) {
        setState(() => _scrolled = isScrolled);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
    setState(() => _mobileMenuOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    debugPrint(
        'Building LandingScreen: width=$screenWidth, isDesktop=$isDesktop');

    final horizontalPadding =
        isDesktop ? GCSpacing.pagePaddingDesktop : GCSpacing.pagePaddingMobile;

    return Scaffold(
      backgroundColor: GCColors.background,
      body: Stack(
        children: [
          // ── Main scrollable content ──────────────
          SingleChildScrollView(
            controller: _scrollController,
            physics:
                const AlwaysScrollableScrollPhysics(), // Ensure scrolling is always enabled
            child: Column(
              children: [
                // Space for fixed nav bar
                const SizedBox(height: 80),
                _buildHeroSection(isDesktop, horizontalPadding),
                _buildStatsSection(isDesktop, horizontalPadding),
                _buildServicesSection(
                    context, ref, isDesktop, horizontalPadding),
                _buildHowItWorksSection(isDesktop, horizontalPadding),
                _buildPlatformHighlightsSection(isDesktop, horizontalPadding),
                _buildCTASection(horizontalPadding),
                _buildFooter(isDesktop, horizontalPadding),
              ],
            ),
          ),

          // ── Fixed top nav bar ───────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildNavBar(isDesktop, horizontalPadding),
          ),

          // ── Mobile menu overlay ─────────────────
          if (_mobileMenuOpen && !isDesktop) _buildMobileMenu(),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // NAV BAR
  // from web: fixed top, transparent → bg on scroll, logo + links + CTAs
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildNavBar(bool isDesktop, double horizontalPadding) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color:
            _scrolled ? GCColors.background.withAlpha(242) : Colors.transparent,
        boxShadow: _scrolled
            ? [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 4)]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Container(
            constraints:
                const BoxConstraints(maxWidth: GCSpacing.maxContentWidth),
            margin: const EdgeInsets.symmetric(horizontal: 0),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            height: isDesktop
                ? GCSpacing.navHeightDesktop
                : GCSpacing.navHeightMobile,
            child: Row(
              children: [
                // Logo
                GestureDetector(
                  onTap: () => _scrollController.animateTo(0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 40,
                        height: 40,
                      ).animate().fade().scale(),
                      const SizedBox(width: 8),
                      Text(GCConstants.appName,
                          style:
                              GCTypography.displaySmall.copyWith(fontSize: 20)),
                    ],
                  ),
                ),

                const Spacer(),

                // Desktop nav links
                if (isDesktop) ...[
                  _navLink('Services', () => _scrollToKey(_servicesKey)),
                  const SizedBox(width: 32),
                  _navLink('How It Works', () => _scrollToKey(_howItWorksKey)),
                  const SizedBox(width: 32),
                  _navLink('Platform Highlights',
                      () => _scrollToKey(_platformHighlightsKey)),
                  const SizedBox(width: 32),
                  _buildSupportDropdown(isDesktop),
                  const SizedBox(width: 32),
                  _navLink('Find Caregivers', () => context.go('/caregivers')),
                  const SizedBox(width: 24),

                  // Conditional Auth Links
                  ref.watch(authStateProvider).when(
                        data: (user) {
                          if (user != null) {
                            return Row(
                              children: [
                                TextButton(
                                  onPressed: () => context.go('/dashboard'),
                                  child: Text('Dashboard',
                                      style: GCTypography.labelMedium.copyWith(
                                          color: GCColors.foreground)),
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              GCButton(
                                label: 'Sign In',
                                onPressed: () =>
                                    context.go('/auth/login?mode=signin'),
                                variant: GCButtonVariant.outline,
                                width: 90,
                              ),
                              const SizedBox(width: 12),
                              GCButton(
                                label: 'Sign Up',
                                onPressed: () => context
                                    .go('/auth/login?mode=signup&role=family'),
                                variant: GCButtonVariant.primary,
                                width: 90,
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox(
                            width: 40,
                            height: 40,
                            child: Padding(
                                padding: EdgeInsets.all(8),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))),
                        error: (_, __) => Row(
                          children: [
                            GCButton(
                              label: 'Sign In',
                              onPressed: () =>
                                  context.go('/auth/login?mode=signin'),
                              variant: GCButtonVariant.outline,
                              width: 90,
                            ),
                            const SizedBox(width: 12),
                            GCButton(
                              label: 'Sign Up',
                              onPressed: () => context
                                  .go('/auth/login?mode=signup&role=family'),
                              variant: GCButtonVariant.primary,
                              width: 90,
                            ),
                          ],
                        ),
                      ),

                  const SizedBox(width: 12),
                  GCButton(
                    label: 'Book Care',
                    onPressed: () => context.go('/book'),
                    variant: GCButtonVariant.primary,
                    icon: Icons.arrow_forward,
                    width: 120,
                  ),
                ],

                // Mobile hamburger
                if (!isDesktop)
                  IconButton(
                    icon: Icon(_mobileMenuOpen ? Icons.close : Icons.menu,
                        color: GCColors.foreground),
                    onPressed: () =>
                        setState(() => _mobileMenuOpen = !_mobileMenuOpen),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navLink(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Text(label, style: GCTypography.labelMedium),
      ),
    );
  }

  Widget _buildMobileMenu() {
    return Positioned(
      top: GCSpacing.navHeightMobile + MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Material(
        elevation: 4,
        color: GCColors.background,
        child: Padding(
          padding: const EdgeInsets.all(GCSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _mobileNavItem('Services', () => _scrollToKey(_servicesKey)),
              _mobileNavItem(
                  'How It Works', () => _scrollToKey(_howItWorksKey)),
              _mobileNavItem('Platform Highlights',
                  () => _scrollToKey(_platformHighlightsKey)),
              _mobileNavItem('Contact Us', () {
                setState(() => _mobileMenuOpen = false);
                context.push('/contact');
              }),
              _mobileNavItem('Terms & Conditions', () {
                setState(() => _mobileMenuOpen = false);
                context.push('/legal/terms');
              }),
              _mobileNavItem('Privacy Policy', () {
                setState(() => _mobileMenuOpen = false);
                context.push('/legal/privacy');
              }),
              _mobileNavItem('Data Collection Policy', () {
                setState(() => _mobileMenuOpen = false);
                context.push('/legal/data-collection');
              }),
              _mobileNavItem('Refund Policy', () {
                setState(() => _mobileMenuOpen = false);
                context.push('/legal/refunds');
              }),
              _mobileNavItem('Account Deletion', () {
                setState(() => _mobileMenuOpen = false);
                context.push('/legal/account-deletion');
              }),
              _mobileNavItem('Find Caregivers', () {
                setState(() => _mobileMenuOpen = false);
                context.push('/caregivers');
              }),
              const Divider(height: 24),

              // Conditional Auth section for mobile
              ref.watch(authStateProvider).when(
                    data: (user) {
                      if (user != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _mobileNavItem('Dashboard', () {
                              setState(() => _mobileMenuOpen = false);
                              context.go('/dashboard');
                            }),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GCButton(
                                  label: 'Sign In',
                                  onPressed: () {
                                    setState(() => _mobileMenuOpen = false);
                                    context.go('/auth/login?mode=signin');
                                  },
                                  variant: GCButtonVariant.outline,
                                  icon: Icons.lock_outline,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GCButton(
                                  label: 'Sign Up',
                                  onPressed: () {
                                    setState(() => _mobileMenuOpen = false);
                                    context.go(
                                        '/auth/login?mode=signup&role=family');
                                  },
                                  variant: GCButtonVariant.primary,
                                  icon: Icons.person_add_outlined,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GCButton(
                                label: 'Sign In',
                                onPressed: () {
                                  setState(() => _mobileMenuOpen = false);
                                  context.go('/auth/login?mode=signin');
                                },
                                variant: GCButtonVariant.outline,
                                icon: Icons.lock_outline,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GCButton(
                                label: 'Sign Up',
                                onPressed: () {
                                  setState(() => _mobileMenuOpen = false);
                                  context.go(
                                      '/auth/login?mode=signup&role=family');
                                },
                                variant: GCButtonVariant.primary,
                                icon: Icons.person_add_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

              const SizedBox(height: 12),
              GCButton(
                label: 'Book Care',
                onPressed: () {
                  setState(() => _mobileMenuOpen = false);
                  context.push('/book');
                },
                variant: GCButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileNavItem(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(label,
            style: GCTypography.headlineSmall.copyWith(fontSize: 16)),
      ),
    );
  }

  Widget _buildSupportDropdown(bool isDesktop) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'contact') context.push('/contact');
        if (value == 'terms') context.push('/legal/terms');
        if (value == 'privacy') context.push('/legal/privacy');
        if (value == 'dataCollection') context.push('/legal/data-collection');
        if (value == 'refunds') context.push('/legal/refunds');
        if (value == 'accountDeletion') context.push('/legal/account-deletion');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Support', style: GCTypography.labelMedium),
            const Icon(Icons.arrow_drop_down,
                size: 20, color: GCColors.foreground),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'contact',
          child: Text('Contact Us', style: GCTypography.bodyMedium),
        ),
        PopupMenuItem<String>(
          value: 'terms',
          child: Text('Terms & Conditions', style: GCTypography.bodyMedium),
        ),
        PopupMenuItem<String>(
          value: 'privacy',
          child: Text('Privacy Policy', style: GCTypography.bodyMedium),
        ),
        PopupMenuItem<String>(
          value: 'dataCollection',
          child: Text('Data Collection Policy', style: GCTypography.bodyMedium),
        ),
        PopupMenuItem<String>(
          value: 'refunds',
          child: Text('Refund Policy', style: GCTypography.bodyMedium),
        ),
        PopupMenuItem<String>(
          value: 'accountDeletion',
          child: Text('Account Deletion', style: GCTypography.bodyMedium),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // HERO SECTION
  // from web: badges, large serif heading, sub text, 2 CTAs, trust features
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildHeroSection(bool isDesktop, double horizontalPadding) {
    return Container(
      constraints: const BoxConstraints(maxWidth: GCSpacing.maxContentWidth),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isDesktop ? 80 : 40,
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _heroContent(isDesktop),
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  flex: 4,
                  child: _heroImage(isDesktop),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ..._heroContent(isDesktop),
                const SizedBox(height: 40),
                _heroImage(isDesktop),
              ],
            ),
    );
  }

  List<Widget> _heroContent(bool isDesktop) {
    return [
      // Badges
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _badge(Icons.auto_awesome, 'Grandkids on demand', GCColors.primary),
          _badge(Icons.location_on,
              'Available in Chandigarh, Mohali & Panchkula', GCColors.accent),
        ],
      ).animate().fade(duration: 600.ms).slideX(begin: -0.2, end: 0),
      const SizedBox(height: 24),

      // Heading — "Compassionate Care for Your Loved Ones"
      Text.rich(
        TextSpan(
          style: GCTypography.displayLarge.copyWith(
            fontSize: isDesktop ? 52 : 36,
          ),
          children: const [
            TextSpan(text: 'Compassionate Care for Your '),
            TextSpan(
              text: 'Loved Ones',
              style: TextStyle(color: GCColors.primary),
            ),
          ],
        ),
        textAlign: isDesktop ? TextAlign.start : TextAlign.center,
      )
          .animate()
          .fade(delay: 200.ms, duration: 800.ms)
          .slideY(begin: 0.2, end: 0),
      const SizedBox(height: 24),

      // Sub text
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Text(
          'Connect with verified, trained caregivers who provide dignified and personalized senior care. Book in minutes, care starts within hours.',
          style: GCTypography.bodyLarge,
          textAlign: isDesktop ? TextAlign.start : TextAlign.center,
        ),
      )
          .animate()
          .fade(delay: 400.ms, duration: 800.ms)
          .slideY(begin: 0.2, end: 0),
      const SizedBox(height: 32),

      // CTAs
      ref.watch(authStateProvider).when(
            data: (user) {
              final isLogged = user != null;
              return Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment:
                    isDesktop ? WrapAlignment.start : WrapAlignment.center,
                children: [
                  if (isLogged)
                    GCButton(
                      label: 'Go to Dashboard',
                      onPressed: () => context.go('/dashboard'),
                      variant: GCButtonVariant.secondary,
                      icon: Icons.dashboard,
                    ),
                  GCButton(
                    label: 'Book a Caregiver',
                    onPressed: () => context.push('/book'),
                    variant: GCButtonVariant.primary,
                    icon: Icons.arrow_forward,
                  ),
                  GCButton(
                    label: 'Browse Caregivers',
                    onPressed: () => context.push('/caregivers'),
                    variant: GCButtonVariant.outline,
                  ),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
              children: [
                GCButton(
                  label: 'Book a Caregiver',
                  onPressed: () => context.push('/book'),
                  variant: GCButtonVariant.primary,
                  icon: Icons.arrow_forward,
                ),
                GCButton(
                  label: 'Browse Caregivers',
                  onPressed: () => context.push('/caregivers'),
                  variant: GCButtonVariant.outline,
                ),
              ],
            ),
          ),
      const SizedBox(height: 32),

      // Trust features
      Wrap(
        spacing: 24,
        runSpacing: 12,
        alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
        children: [
          _trustFeature(Icons.school_outlined, 'Caring Students'),
          _trustFeature(Icons.schedule, 'Flexible Scheduling'),
          _trustFeature(Icons.star_outline, 'Quality Guaranteed'),
        ],
      ),
    ];
  }

  Widget _heroImage(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GCSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: GCColors.primary.withAlpha(26),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GCSpacing.radiusXl),
        child: Image.asset(
          'assets/images/hero_premium.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: GCColors.muted,
            child: const AspectRatio(
              aspectRatio: 1,
              child: Icon(Icons.image_not_supported, size: 48),
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(GCSpacing.radiusRound),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text,
                style: GCTypography.badgeText.copyWith(color: color),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _trustFeature(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: GCColors.primary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(text,
              style: GCTypography.bodyMedium.copyWith(
                color: GCColors.mutedForeground,
              )),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // STATS BAR
  // from web: "py-12 bg-primary/5 border-y" with 4 stats in grid
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildStatsSection(bool isDesktop, double horizontalPadding) {
    final stats = [
      {'value': '100*', 'label': 'Happy Families'},
      {'value': '500+', 'label': 'Verified Caregivers'},
      {'value': '4.9', 'label': 'Average Rating'},
      {'value': 'Full day care', 'label': 'Support Available'},
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: isDesktop ? 48 : 32),
      decoration: BoxDecoration(
        color: GCColors.primary.withAlpha(13),
        border: Border.symmetric(
          horizontal: BorderSide(color: GCColors.primary.withAlpha(26)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: GCSpacing.maxContentWidth),
          child: isDesktop
              ? Row(
                  children: stats
                      .map((stat) => Expanded(
                            child: _buildStatItem(stat),
                          ))
                      .toList(),
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatItem(stats[0])),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatItem(stats[1])),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildStatItem(stats[2])),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatItem(stats[3])),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatItem(Map<String, String> stat) {
    return Column(
      children: [
        Text(stat['value']!,
            style: GCTypography.statValue.copyWith(
              fontSize: 32,
            ),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(stat['label']!,
            style: GCTypography.statLabel, textAlign: TextAlign.center),
      ],
    ).animate().fade(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SERVICES SECTION
  // from web: badge "Our Services", heading, 4 service cards, important notice
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildServicesSection(BuildContext context, WidgetRef ref,
      bool isDesktop, double horizontalPadding) {
    final servicesAsyncValue = ref.watch(servicesProvider);

    return Container(
      key: _servicesKey,
      constraints: const BoxConstraints(maxWidth: GCSpacing.maxContentWidth),
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: GCSpacing.sectionVertical),
      child: Column(
        children: [
          // Section badge + heading
          _badge(Icons.spa, 'Our Services', GCColors.primary)
              .animate()
              .fade()
              .scale(),
          const SizedBox(height: 16),
          Text('Comprehensive Care Solutions',
                  style: GCTypography.displayMedium,
                  textAlign: TextAlign.center)
              .animate()
              .fade(delay: 200.ms)
              .slideY(),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              "From companionship to medical support, we offer a range of services tailored to your family's needs.",
              style: GCTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ).animate().fade(delay: 400.ms).slideY(),
          const SizedBox(height: 48),

          servicesAsyncValue.when(
            data: (services) {
              if (services.isEmpty) {
                return const Center(
                    child: Text('No services available at the moment.'));
              }
              // Show all services on landing page
              final displayServices = services.toList();

              return isDesktop
                  ? GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: GCSpacing.lg,
                      mainAxisSpacing: GCSpacing.lg,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 0.75,
                      children: displayServices
                          .map((s) => _serviceCard(s, isDesktop))
                          .toList(),
                    )
                  : Column(
                      children: displayServices
                          .map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _serviceCard(s, isDesktop),
                              ))
                          .toList(),
                    );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('Error loading services: $err')),
          ),

          const SizedBox(height: 32),

          // Important notice
          _buildImportantNotice(),
          const SizedBox(height: 40),

          // Book a Service button
          GCButton(
            label: 'Book a Service',
            onPressed: () => context.push('/book'),
            variant: GCButtonVariant.primary,
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(ServiceModel service, bool isDesktop) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/book'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: service.imageUrl,
                height: isDesktop ? 140 : 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: isDesktop ? 140 : 180,
                  color: GCColors.muted,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: isDesktop ? 140 : 180,
                  color: GCColors.muted,
                  child: const Icon(Icons.image_not_supported,
                      color: GCColors.mutedForeground),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(GCSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.title, style: GCTypography.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: GCTypography.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  if (service.options.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: service.options
                          .take(3)
                          .map((opt) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: GCColors.primary.withAlpha(26),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(opt.duration,
                                    style: GCTypography.bodySmall
                                        .copyWith(color: GCColors.primary)),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportantNotice() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GCColors.warningBackground,
          borderRadius: BorderRadius.circular(GCSpacing.radiusLg),
          border: Border.all(color: GCColors.warningBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber,
                color: GCColors.warningIcon, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Important Notice',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: GCColors.warningText)),
                  const SizedBox(height: 4),
                  Text(
                    'GoldenCare provides companionship and assistance services only. We do not offer overnight care, medical/nursing services, or clinical treatments. For medical needs, please consult healthcare professionals.',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: GCColors.warningText.withAlpha(204)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // HOW IT WORKS
  // from web: 3 step cards with step numbers, icons, titles, descriptions
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildHowItWorksSection(bool isDesktop, double horizontalPadding) {
    final steps = [
      {
        'step': '01',
        'icon': Icons.calendar_today,
        'title': 'Choose Your Service',
        'desc': 'Select the type of care you need and your preferred schedule.',
      },
      {
        'step': '02',
        'icon': Icons.people,
        'title': 'Get Matched',
        'desc':
            'We match you with verified caregivers based on your needs and location.',
      },
      {
        'step': '03',
        'icon': Icons.favorite,
        'title': 'Care Begins',
        'desc':
            'Your caregiver arrives and provides compassionate, professional care.',
      },
    ];

    return Container(
      key: _howItWorksKey,
      width: double.infinity,
      color: GCColors.muted.withAlpha(128),
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: GCSpacing.sectionVertical),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: GCSpacing.maxContentWidth),
          child: Column(
            children: [
              _badge(Icons.info_outline, 'How It Works', GCColors.primary),
              const SizedBox(height: 16),
              Text('Care in 3 Simple Steps',
                  style: GCTypography.displayMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 48),
              isDesktop
                  ? Row(
                      children: steps
                          .map((step) => Expanded(child: _stepCard(step)))
                          .toList(),
                    )
                  : Column(
                      children: steps
                          .map((step) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _stepCard(step),
                              ))
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepCard(Map<String, dynamic> step) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GCSpacing.cardPadding),
        child: Column(
          children: [
            Text(step['step'] as String,
                style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: GCColors.primary.withAlpha(51))),
            const SizedBox(height: 16),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: GCColors.primary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(step['icon'] as IconData,
                  color: GCColors.primary, size: 28),
            ),
            const SizedBox(height: 16),
            Text(step['title'] as String,
                style: GCTypography.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(step['desc'] as String,
                style: GCTypography.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PLATFORM HIGHLIGHTS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildPlatformHighlightsSection(
      bool isDesktop, double horizontalPadding) {
    final platformHighlights = [
      {
        'name': 'Live Slot Visibility',
        'location': 'Booking Experience',
        'avatar': 'LS',
        'text':
            'Time slots show real caregiver availability so families can select practical booking windows quickly.',
      },
      {
        'name': 'Map Pin Addressing',
        'location': 'Location Flow',
        'avatar': 'MP',
        'text':
            'Families can drag the map pin, search places, and confirm the exact service location before checkout.',
      },
      {
        'name': 'Secure Online Payments',
        'location': 'Checkout System',
        'avatar': 'SP',
        'text':
            'Bookings create server-side payment orders and verify transaction signatures before marking payment complete.',
      },
      {
        'name': 'Verified Caregiver Profiles',
        'location': 'Caregiver Discovery',
        'avatar': 'VC',
        'text':
            'The website presents caregiver details, skills, and assignment context to help families choose confidently.',
      },
      {
        'name': 'Status Tracking',
        'location': 'Booking Lifecycle',
        'avatar': 'ST',
        'text':
            'Booking status and payment state move through clear steps from pending to confirmed and completed.',
      },
      {
        'name': 'Partner + Family Portals',
        'location': 'Platform Access',
        'avatar': 'PF',
        'text':
            'Separate app experiences support both family booking journeys and partner-side operational workflows.',
      },
    ];

    return Container(
      key: _platformHighlightsKey,
      constraints: const BoxConstraints(maxWidth: GCSpacing.maxContentWidth),
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: GCSpacing.sectionVertical),
      child: Column(
        children: [
          _badge(Icons.dashboard_customize, 'Platform Highlights',
              GCColors.primary),
          const SizedBox(height: 16),
          Text('Built for Reliable Home-Care Operations',
              style: GCTypography.displayMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'A quick look at real website capabilities instead of quoted testimonials.',
            style: GCTypography.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          isDesktop
              ? GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: GCSpacing.lg,
                  mainAxisSpacing: GCSpacing.lg,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.3,
                  children: platformHighlights
                      .map((highlight) => _platformHighlightCard(highlight))
                      .toList(),
                )
              : Column(
                  children: platformHighlights
                      .map((highlight) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _platformHighlightCard(highlight),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _platformHighlightCard(Map<String, String> highlight) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GCSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stars
            Row(
              children: List.generate(
                  5,
                  (_) => const Icon(Icons.star,
                      size: 16, color: GCColors.primary)),
            ),
            const SizedBox(height: 12),
            // Quote icon
            Icon(Icons.format_quote,
                size: 32, color: GCColors.primary.withAlpha(51)),
            const SizedBox(height: 8),
            Text(highlight['text']!,
                style: GCTypography.bodyMedium.copyWith(height: 1.5)),
            const SizedBox(height: 16),
            // Avatar + Name + Location
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: GCColors.primary.withAlpha(51),
                  child: Text(highlight['avatar']!,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: GCColors.primary)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(highlight['name']!,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: GCColors.foreground)),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 12, color: GCColors.mutedForeground),
                        const SizedBox(width: 2),
                        Text(highlight['location']!,
                            style: GCTypography.bodySmall),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CTA SECTION
  // from web: "Ready to Find the Perfect Caregiver?" + Book Care Now + Call Us
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildCTASection(double horizontalPadding) {
    return Container(
      width: double.infinity,
      color: GCColors.primary.withAlpha(13),
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: GCSpacing.sectionVertical),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: GCSpacing.maxContentWidthNarrow),
          child: Column(
            children: [
              Text('Ready to Find the Perfect Caregiver?',
                  style: GCTypography.displayMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text(
                'Join thousands of families who trust GoldenCare for their loved ones. Book your first care session today.',
                style: GCTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  GCButton(
                    label: 'Book Care Now',
                    onPressed: () => context.push('/book'),
                    variant: GCButtonVariant.primary,
                    icon: Icons.arrow_forward,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // FOOTER
  // from web: dark bg (foreground color), 4-column grid, copyright
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildFooter(bool isDesktop, double horizontalPadding) {
    final footerTextStyle = GoogleFonts.inter(
        fontSize: 14, color: GCColors.background.withAlpha(179));
    final footerHeadingStyle = GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600, color: GCColors.background);

    return Container(
      width: double.infinity,
      color: GCColors.footerBackground,
      padding:
          EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 64),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: GCSpacing.maxContentWidth),
          child: Column(
            children: [
              // Footer columns
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand
                        Expanded(flex: 2, child: _footerBrand(footerTextStyle)),
                        const SizedBox(width: 32),
                        Expanded(
                            child: _footerServices(
                                footerHeadingStyle, footerTextStyle)),
                        Expanded(
                            child: _footerCompany(
                                footerHeadingStyle, footerTextStyle)),
                        Expanded(
                            child: _footerPortals(
                                footerHeadingStyle, footerTextStyle)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _footerBrand(footerTextStyle),
                        const SizedBox(height: 32),
                        _footerServices(footerHeadingStyle, footerTextStyle),
                        const SizedBox(height: 24),
                        _footerCompany(footerHeadingStyle, footerTextStyle),
                        const SizedBox(height: 24),
                        _footerPortals(footerHeadingStyle, footerTextStyle),
                      ],
                    ),
              const SizedBox(height: 48),
              // Copyright
              Divider(color: GCColors.background.withAlpha(26)),
              const SizedBox(height: 32),
              isDesktop
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(GCConstants.copyright,
                            style: footerTextStyle.copyWith(
                                color: GCColors.background.withAlpha(128))),
                        Row(
                          children: [
                            TextButton(
                                onPressed: () => context.push('/legal/privacy'),
                                child: Text('Privacy Policy',
                                    style: footerTextStyle.copyWith(
                                        color: GCColors.background
                                            .withAlpha(128)))),
                            const SizedBox(width: 24),
                            TextButton(
                                onPressed: () => context.push('/legal/terms'),
                                child: Text('Terms and Conditions',
                                    style: footerTextStyle.copyWith(
                                        color: GCColors.background
                                            .withAlpha(128)))),
                            const SizedBox(width: 24),
                            TextButton(
                                onPressed: () =>
                                    context.push('/legal/data-collection'),
                                child: Text('Data Collection',
                                    style: footerTextStyle.copyWith(
                                        color: GCColors.background
                                            .withAlpha(128)))),
                            const SizedBox(width: 24),
                            TextButton(
                                onPressed: () => context.push('/legal/refunds'),
                                child: Text('Refund Policy',
                                    style: footerTextStyle.copyWith(
                                        color: GCColors.background
                                            .withAlpha(128)))),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Text(GCConstants.copyright,
                            style: footerTextStyle.copyWith(
                                color: GCColors.background.withAlpha(128))),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerBrand(TextStyle textStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 8),
            Text(GCConstants.appName,
                style: GCTypography.displaySmall
                    .copyWith(fontSize: 20, color: GCColors.background)),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Providing compassionate, professional care for seniors in ${GCConstants.region}.',
          style: textStyle,
        ),
        const SizedBox(height: 16),
        _footerContact(Icons.email, GCConstants.email, textStyle),
        const SizedBox(height: 8),
        _footerContact(Icons.location_on, GCConstants.region, textStyle),
      ],
    );
  }

  Widget _footerContact(IconData icon, String text, TextStyle style) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: GCColors.background.withAlpha(179)),
        const SizedBox(width: 8),
        Flexible(child: Text(text, style: style)),
      ],
    );
  }

  Widget _footerServices(TextStyle heading, TextStyle text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Services', style: heading),
        const SizedBox(height: 16),
        _footerLink('Companionship', text, () => context.push('/book')),
        _footerLink('Outings & Visits', text, () => context.push('/book')),
        _footerLink('Daily Activities', text, () => context.push('/book')),
        _footerLink('Exercise & Walks', text, () => context.push('/book')),
      ],
    );
  }

  Widget _footerCompany(TextStyle heading, TextStyle text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Company', style: heading),
        const SizedBox(height: 16),
        _footerLink('About Us', text, () => context.push('/about')),
        _footerLink('Our Caregivers', text, () => context.push('/caregivers')),
        _footerLink('Contact', text, () => context.push('/contact')),
      ],
    );
  }

  Widget _footerPortals(TextStyle heading, TextStyle text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Portals', style: heading),
        const SizedBox(height: 16),
        _footerLinkIcon(Icons.people, 'Family Login', text,
            () => context.push('/auth/login')),
        _footerLinkIcon(Icons.work, 'Caregiver Login', text,
            () => context.push('/auth/login')),
      ],
    );
  }

  Widget _footerLink(String label, TextStyle style, [VoidCallback? onTap]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(label, style: style),
      ),
    );
  }

  Widget _footerLinkIcon(
      IconData icon, String label, TextStyle style, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: GCColors.background.withAlpha(179)),
            const SizedBox(width: 8),
            Flexible(child: Text(label, style: style)),
          ],
        ),
      ),
    );
  }
}
