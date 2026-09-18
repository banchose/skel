# Global instructions

## When a command fails

Stop. Do not try a different command.

Report, in this order:
1. the command that failed
2. the actual error output
3. why you think it failed
4. what you propose next, as a single option

Then wait for me.

This applies to any non-zero exit, unexpected empty output, or any result that
made you reconsider your approach. One diagnostic read/grep to understand the
error is fine. A second *attempt* at the goal is not — that needs my go-ahead.

Never work around a failure silently: no switching package managers, no
alternate flags, no fallback tool, no "let me try another way" without asking.
If the fix looks obvious, say it and wait anyway — I usually want to fix the
cause, not route around it.
