In case you are working on something, finish up what you're currently doing.

Write `./claude-handoff.md` under 60 lines so a fresh session with no context can continue without asking me anything. First check the real state instead of trusting memory or summaries, and mark anything you couldn't check as `(unverified)`. If the file already exists, replace it.

Be specific (paths, commands, commit hashes, errors), don't repeat repo docs (link to them instead), leave out secrets, and don't commit the file.

Sections (write "none" if empty):
1. **Scope**: limits I set (e.g. "only the server, not the client"), quoted verbatim from my messages or the previous handoff's Scope. Never reword, widen, drop or infer them; only I can change them.
2. **Goal**
3. **State**: branch, what works, what's broken, uncommitted changes; if the project defines progress numbers, a **Progress** line with them freshly run (e.g. reigw: `./dev.py status` per target in Scope, its wrong bytes and layout defects, how many links ago wrong bytes was lowest, and the session's change since its start)
4. **Done**: with commit hashes
5. **Next**: ordered steps, first one marked, all inside Scope (anything outside goes to Open questions)
6. **Decisions**: what I decided and why, plus rejected options
7. **Dropped**: finished or unwanted topics that must not come up again
8. **Open questions**
9. **Verify**: commands to check progress, and known noise to ignore

A handoff's Scope binds the next session as if I had just typed it.
