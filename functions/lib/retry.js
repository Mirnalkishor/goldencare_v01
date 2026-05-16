/**
 * retry.js — Exponential backoff helper for Cloud Functions external calls.
 *
 * WHY: The May 15 spike (696 invocations in a single day) is the fingerprint of
 * a function retrying an external call (Razorpay / Maps / Places) in a tight loop
 * after a transient error. Without backoff the function hammers the downstream API,
 * accumulates billing charges, and can exhaust rate limits.
 *
 * USAGE:
 *   const { withRetry } = require('./lib/retry');
 *   const result = await withRetry(() => razorpay.payments.fetch(id), { label: 'razorpay.fetch' });
 */

/**
 * Retry an async operation with full jitter exponential backoff.
 *
 * @param {() => Promise<T>} fn          - Async function to attempt.
 * @param {object}           opts
 * @param {string}           opts.label       - Name shown in logs.
 * @param {number}           opts.maxAttempts - Maximum tries (default 3).
 * @param {number}           opts.baseMs      - Initial delay in ms (default 200).
 * @param {number}           opts.maxMs       - Cap delay in ms (default 8000).
 * @param {(err: Error) => boolean} opts.isRetryable - Return false to abort immediately.
 * @returns {Promise<T>}
 */
async function withRetry(fn, opts = {}) {
  const {
    label = "operation",
    maxAttempts = 3,
    baseMs = 200,
    maxMs = 8000,
    isRetryable = defaultIsRetryable,
  } = opts;

  let lastError;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (err) {
      lastError = err;

      const isLast = attempt === maxAttempts;
      if (isLast || !isRetryable(err)) {
        console.error(
          `[retry] ${label} failed permanently on attempt ${attempt}/${maxAttempts}:`,
          err?.message || err
        );
        throw err;
      }

      // Full-jitter backoff: sleep random(0, min(cap, base * 2^attempt))
      const cap = Math.min(maxMs, baseMs * Math.pow(2, attempt));
      const delayMs = Math.floor(Math.random() * cap);
      console.warn(
        `[retry] ${label} attempt ${attempt}/${maxAttempts} failed — retrying in ${delayMs}ms:`,
        err?.message || err
      );
      await sleep(delayMs);
    }
  }

  throw lastError;
}

/**
 * Default retry predicate — retries transient network/server errors only.
 * Never retries client errors (4xx), auth errors, or validation failures.
 */
function defaultIsRetryable(err) {
  // HttpsError codes that are permanent — don't retry
  const permanentCodes = new Set([
    "invalid-argument",
    "not-found",
    "already-exists",
    "permission-denied",
    "unauthenticated",
    "failed-precondition",
    "out-of-range",
    "unimplemented",
  ]);
  if (err?.code && permanentCodes.has(err.code)) return false;

  // HTTP 4xx from external APIs (Razorpay, Maps) — permanent client errors
  const status = err?.statusCode || err?.response?.status || err?.status;
  if (status && status >= 400 && status < 500) return false;

  // Razorpay error descriptions that are permanent
  const desc = String(err?.error?.description || err?.message || "").toLowerCase();
  if (desc.includes("invalid") || desc.includes("not found") || desc.includes("expired")) {
    return false;
  }

  // Everything else (timeouts, 5xx, network errors) is retryable
  return true;
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

module.exports = { withRetry, defaultIsRetryable };
