namespace iZiCodeEditor {
    public class Terminal : Gtk.Grid {
        private Gtk.Menu context_menu;
        private GLib.Pid child_pid;
        private Vte.Terminal terminal;
        private Gtk.Scrollbar scrolled;

        construct {
            terminal = new Vte.Terminal ();

            context_menu = new Gtk.Menu ();
            add_popup_menu (context_menu);

            string terminalPath = Environment.get_home_dir ();
            terminal.set_scrollback_lines (4096);
            terminal.expand = true;
            terminal.set_cursor_blink_mode (Vte.CursorBlinkMode.OFF);
            terminal.set_cursor_shape (Vte.CursorShape.UNDERLINE);

            terminal.set_font (Pango.FontDescription.from_string (Application.settings_terminal.get_string ("font")));
            Application.settings_terminal.changed["font"].connect (() => {
                terminal.set_font (Pango.FontDescription.from_string (Application.settings_terminal.get_string ("font")));
            });

            string background_setting = Application.settings_terminal.get_string ("bgcolor");
            Gdk.RGBA background_color = Gdk.RGBA ();
            background_color.parse (background_setting);

            terminal.set_color_background (background_color);
            Application.settings_terminal.changed["bgcolor"].connect (() => {
                background_setting = Application.settings_terminal.get_string ("bgcolor");
                background_color = Gdk.RGBA ();
                background_color.parse (background_setting);
                terminal.set_color_background (background_color);
            });

            string foreground_setting = Application.settings_terminal.get_string ("fgcolor");
            Gdk.RGBA foreground_color = Gdk.RGBA ();
            foreground_color.parse (foreground_setting);

            terminal.set_color_foreground (foreground_color);
            Application.settings_terminal.changed["fgcolor"].connect (() => {
                foreground_setting = Application.settings_terminal.get_string ("fgcolor");
                foreground_color = Gdk.RGBA ();
                foreground_color.parse (foreground_setting);
                terminal.set_color_foreground (foreground_color);
            });

            terminal.button_press_event.connect (terminal_button_press);
            try {
                terminal.spawn_sync (Vte.PtyFlags.DEFAULT, terminalPath, { Vte.get_user_shell () }, null, GLib.SpawnFlags.SEARCH_PATH, null, out child_pid);
            } catch (Error e) {
                stderr.printf ("error: %s\n", e.message);
            }
            scrolled = new Gtk.Scrollbar (Gtk.Orientation.VERTICAL, terminal.vadjustment);

            attach (terminal, 0, 0, 1, 1);
            attach (scrolled, 1, 0, 1, 1);

            /* Make the terminal occupy the whole GUI */
            terminal.vexpand = true;
            terminal.hexpand = true;

            terminal.child_exited.connect (() => {
                Application.settings_terminal.set_boolean ("terminal", false);
            });

            show_all ();
        }

        private void action_copy () {
            terminal.copy_clipboard ();
            terminal.grab_focus ();
        }

        private void action_paste () {
            terminal.paste_clipboard ();
            terminal.grab_focus ();
        }

        private void action_select_all () {
            terminal.select_all ();
            terminal.grab_focus ();
        }

        // Context menu
        private void add_popup_menu (Gtk.Menu menu) {
            var context_copy = new Gtk.MenuItem.with_label ("Copy");
            context_copy.activate.connect (action_copy);
            var context_paste = new Gtk.MenuItem.with_label ("Paste");
            context_paste.activate.connect (action_paste);
            var context_select_all = new Gtk.MenuItem.with_label ("Select all");
            context_select_all.activate.connect (action_select_all);
            menu.append (context_copy);
            menu.append (context_paste);
            menu.append (context_select_all);
            menu.show_all ();
        }

        private bool terminal_button_press (Gdk.EventButton event) {
            if (event.button == 3) {
                context_menu.popup_at_pointer ();
            }
            return false;
        }
    }
}
