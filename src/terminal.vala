namespace iZiCodeEditor{
    public class Terminal : Gtk.Notebook {
        private Gtk.Menu context_menu ;
        private GLib.Pid child_pid ;
        private Vte.Terminal terminal ;

        public void show_term() {
            // Terminal
            terminal = new Vte.Terminal () ;

            context_menu = new Gtk.Menu () ;
            add_popup_menu (context_menu) ;

            string terminalPath = Environment.get_home_dir () ;
            terminal.set_scrollback_lines (4096) ;
            terminal.expand = true ;
            terminal.set_cursor_blink_mode (Vte.CursorBlinkMode.OFF) ;
            terminal.set_cursor_shape (Vte.CursorShape.UNDERLINE) ;
            terminal.button_press_event.connect (terminal_button_press) ;
            try {
                terminal.spawn_sync (Vte.PtyFlags.DEFAULT, terminalPath, { Vte.get_user_shell () }, null, GLib.SpawnFlags.SEARCH_PATH, null, out child_pid) ;
            } catch ( Error e ){
                stderr.printf ("error: %s\n", e.message) ;
            }
            var scrolled = new Gtk.Scrollbar (Gtk.Orientation.VERTICAL, terminal.vadjustment) ;

            var gridTerminal = new Gtk.Grid () ;

            gridTerminal.attach (terminal, 0, 0, 1, 1) ;
            gridTerminal.attach (scrolled, 1, 0, 1, 1) ;

            /* Make the terminal occupy the whole GUI */
            terminal.vexpand = true ;
            terminal.hexpand = true ;

            Gtk.Label labelTerminal = new Gtk.Label ("Terminal") ;

            bottomBar.append_page (gridTerminal, labelTerminal) ;

            terminal.child_exited.connect (() => {
                bottomBar.remove_page (notebook.page_num (scrolled)) ;
                show_terminal = false ;
            }) ;
        }

        private void action_copy() {
            terminal.copy_clipboard () ;
            terminal.grab_focus () ;
        }

        private void action_paste() {
            terminal.paste_clipboard () ;
            terminal.grab_focus () ;
        }

        private void action_select_all() {
            terminal.select_all () ;
            terminal.grab_focus () ;
        }

        // Context menu
        private void add_popup_menu(Gtk.Menu menu) {
            var context_copy = new Gtk.MenuItem.with_label ("Copy") ;
            context_copy.activate.connect (action_copy) ;
            var context_paste = new Gtk.MenuItem.with_label ("Paste") ;
            context_paste.activate.connect (action_paste) ;
            var context_select_all = new Gtk.MenuItem.with_label ("Select all") ;
            context_select_all.activate.connect (action_select_all) ;
            menu.append (context_copy) ;
            menu.append (context_paste) ;
            menu.append (context_select_all) ;
            menu.show_all () ;
        }

        private bool terminal_button_press(Gdk.EventButton event) {
            if( event.button == 3 ){
                context_menu.popup (null, null, null, event.button, event.time) ;
            }
            return false ;
        }

    }
}
