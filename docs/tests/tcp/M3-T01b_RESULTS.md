# M3-T01b Results Log

## Run 1
- Date: 2026-07-25
- Path: Wi-Fi client
- Target: 192.168.1.102:502
- Attempts: 30
- Delay: 1500 ms
- Success: 27/30 (90%)
- Avg Connect Time: 12813.43 ms
- Max Consecutive Failures: 3
- Verdict: FAIL
- Conclusion: Keep M3-T02 blocked. Wired comparison required.

## Run 2
- Date: 2026-07-25
- Path: Wired client (LAN)
- Target: 192.168.1.102:502
- Attempts: 30
- Delay: 1500 ms
- Success: 30/30 (100%)
- Avg Connect Time: not captured
- Max Consecutive Failures: 0
- Verdict: PASS
- Conclusion: TCP path is stable on wired LAN. Keep Wi-Fi path as non-reference for validation.
