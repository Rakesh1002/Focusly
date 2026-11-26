// shortcut: project names with spaces break the URL; percent-encode if users report it.
enum AgentHooks {
    static let claudeCode = #"""
    {
      "hooks": {
        "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "open -g \"focusly://agent?state=working&name=Claude&project=${CLAUDE_PROJECT_DIR##*/}&app=${__CFBundleIdentifier}\"" }] }],
        "Stop": [{ "hooks": [{ "type": "command", "command": "open -g \"focusly://agent?state=done&name=Claude&project=${CLAUDE_PROJECT_DIR##*/}&app=${__CFBundleIdentifier}\"" }] }],
        "Notification": [{ "hooks": [{ "type": "command", "command": "open -g \"focusly://agent?state=waiting&name=Claude&project=${CLAUDE_PROJECT_DIR##*/}&app=${__CFBundleIdentifier}\"" }] }]
      }
    }
    """#

    static let cursor = #"""
    {
      "version": 1,
      "hooks": {
        "beforeSubmitPrompt": [{ "command": "open -g \"focusly://agent?state=working&name=Cursor&app=${__CFBundleIdentifier}\"" }],
        "stop": [{ "command": "open -g \"focusly://agent?state=done&name=Cursor&app=${__CFBundleIdentifier}\"" }]
      }
    }
    """#
}
