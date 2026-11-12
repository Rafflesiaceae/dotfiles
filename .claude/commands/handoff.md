In case you are working on something, finish up what you're currently doing.

Write `./claude-handoff` (markdown, under 60 lines) so a fresh session with no context can continue without asking me anything. First check the real state instead of trusting memory or summaries, and mark anything you couldn't check as `(unverified)`. If the file already exists, replace it.

Be specific (paths, commands, commit hashes, errors), don't repeat repo docs (link to them instead), leave out secrets, and don't commit the file.

Sections (write "none" if empty):
1. **Goal**
2. **State**: branch, what works, what's broken, uncommitted changes
3. **Done**: with commit hashes
4. **Next**: ordered steps, first one marked
5. **Decisions**: what I decided and why, plus rejected options
6. **Dropped**: finished or unwanted topics that must not come up again
7. **Open questions**
8. **Verify**: commands to check progress, and known noise to ignore
