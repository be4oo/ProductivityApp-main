# Local task commands

The companion includes a deliberately small, transport-free command vocabulary.
Open **Local commands** in the planner or press **⌘K**. Task IDs appear as `#ID`
in each task row. Commands act on existing open tasks:

- `start 12` selects task #12 and starts focus (running it again does not pause).
- `finish 12` saves completion for task #12, stops its active focus session, and
  displays the bundled victory GIF only after persistence succeeds.

Invalid syntax, unknown IDs, and closed tasks produce an inline error. No shell
commands are executed. The parser accepts only a verb and a positive numeric ID.
Task/project IDs are not reused after deletion or restart.

## Future agent integration boundary

`LocalTaskCommand.parse` is the reusable contract. A future explicitly authorized
adapter can dispatch these same operations. This build has **no HTTP listener,
URL scheme handler, background agent, external agent connection, credentials,
webhook, or automatic task execution**. An agent with separately authorized UI
control could use the command palette like the user. Adding any other transport
requires its own authentication, user-consent and duplicate-delivery design.

## Privacy and persistence

The UI stores tasks and projects in the existing local Hive boxes. Completion
and edits are acknowledged only after their writes succeed. The animation is a
bundled original GIF; it makes no network requests. Failed focus-time writes are
retained for retry while the app remains open; use **Retry saving focus time** in
the planner before quitting if an error appears.
