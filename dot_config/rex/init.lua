-- Rex configuration — keybindings migrated from Herdr.
-- Sources:
--   ~/.config/Herdr/config.toml   [keys] overrides: navigate_workspace_up = "k",
--                                 navigate_workspace_down = "j", next_agent = "prefix+J",
--                                 previous_agent = "prefix+K"
--   `herdr --default-config`      defaults, prefix = "ctrl+b"
--   herdr source (via DeepWiki)   split_vertical = side by side = right;
--                                 split_horizontal = top/bottom = down;
--                                 resize mode is sticky: h/l width, j/k height,
--                                 exits on enter or escape.
--   rex docs, reference/mac-actions  names of every action of the Rex for Mac client.
-- Herdr concepts map to Rex as: workspace ~= session, tab ~= tab,
-- pane ~= pane, agent ~= the process occupying a pane.
-- Herdr's keymap already follows the tmux-style ctrl+b prefix, so it replaces the
-- previous tmux/zellij migration kept in init.lua.bak.

-- ---------------------------------------------------------------------------
-- Panes (Herdr prefix-mode actions, prefix = ctrl+b)
-- ---------------------------------------------------------------------------

-- split_vertical: side-by-side split (herdr source: splits toward the right)
rex.bind("ctrl+b>v", "pane.split", { direction = "right" })
-- split_horizontal: top/bottom split (herdr source: splits downward)
rex.bind("ctrl+b>-", "pane.split", { direction = "down" })

-- focus_pane_left/down/up/right
rex.bind("ctrl+b>h", "pane.focus", { direction = "left" })
rex.bind("ctrl+b>j", "pane.focus", { direction = "down" })
rex.bind("ctrl+b>k", "pane.focus", { direction = "up" })
rex.bind("ctrl+b>l", "pane.focus", { direction = "right" })

-- cycle_pane_next / cycle_pane_previous
rex.bind("ctrl+b>tab", "pane.focus_next")
rex.bind("ctrl+b>shift+tab", "pane.focus_previous")

-- close_pane, zoom, rename_pane
rex.bind("ctrl+b>x", "pane.close")
rex.bind("ctrl+b>z", "pane.zoom")
rex.bind("ctrl+b>shift+p", "pane.rename")

-- ---------------------------------------------------------------------------
-- Sessions (Herdr workspaces ~= Rex sessions)
-- ---------------------------------------------------------------------------

-- workspace_picker
rex.bind("ctrl+b>w", "session.switch")
-- navigate sessions (config.toml gave prefix+J/K to agent nav in Herdr;
-- here they cycle sessions instead)
rex.bind("ctrl+b>shift+j", "session.next")
rex.bind("ctrl+b>shift+k", "session.previous")
-- new_workspace
rex.bind("ctrl+b>shift+n", "session.new")
-- rename_workspace
rex.bind("ctrl+b>shift+w", "session.rename")

-- ---------------------------------------------------------------------------
-- Tabs
-- ---------------------------------------------------------------------------

rex.bind("ctrl+b>c", "client.tab.new")          -- new_tab
rex.bind("ctrl+b>n", "client.tab.next")         -- next_tab
rex.bind("ctrl+b>p", "client.tab.previous")     -- previous_tab
rex.bind("ctrl+b>shift+x", "client.tab.close")  -- close_tab
rex.bind("ctrl+b>shift+t", "client.tab.rename") -- rename_tab

-- switch_tab = prefix+1..9
for i = 1, 9 do
	rex.bind("ctrl+b>" .. i, "client.tab.goto", { index = i })
end

-- ---------------------------------------------------------------------------
-- App and interface
-- ---------------------------------------------------------------------------

-- goto: Herdr's fuzzy jump ~= Rex's "Go to Anything…"
rex.bind("ctrl+b>g", "pane.go_to")
-- edit_scrollback: Herdr opens scrollback in an editor; the closest Rex
-- surface is copy mode, which moves through scrollback by keyboard.
rex.bind("ctrl+b>e", "pane.copy_mode.enter")
-- toggle_sidebar
rex.bind("ctrl+b>b", "client.sidebar.toggle")
-- settings
rex.bind("ctrl+b>s", "client.settings")
-- reload_config (same key as Herdr)
rex.bind("ctrl+b>shift+r", "client.config.reload")

-- ---------------------------------------------------------------------------
-- Herdr bindings intentionally left unbound (no Rex equivalent known)
-- ---------------------------------------------------------------------------
-- prefix+?        help                     no help overlay; closest is the command
--                                          palette (client.palette.toggle)
-- prefix+q        detach                   no client detach action
-- prefix+o        open_notification_target closest is View Activity… (pane.view_activity)
-- prefix+shift+g  new_worktree             no worktree action
-- prefix+shift+d  close_workspace          session.close exists but its confirmation
--                                          behavior is undocumented; left unbound on purpose
-- next/previous_agent (prefix+J/K)         Rex has no agent rows; the activity view
--                                          (client.sidebar.activity.toggle) covers this
-- navigate_workspace_up/down (k/j overrides) sidebar-only in Herdr
-- remote_image_paste (ctrl+v)                Herdr --remote only
