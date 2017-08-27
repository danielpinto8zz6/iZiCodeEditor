namespace iZiCodeEditor{
    public class Terminal : Gtk.Notebook {
        private Gtk.Menu context_menu ;
        private GLib.Pid child_pid ;
        private Vte.Terminal terminal ;

        public void show_terminal() {
            // Terminal
            terminal = new Vte.Terminal () ;

            context_menu = new Gtk.Menu () ;
            add_popup_menu (context_menu) ;

            string terminalPath = Environment.get_home_dir () ;
            terminal.set_scrollback_lines (4096) ;
            terminal.expand = true ;
            terminal.set_cursor_blink_mode (Vte.CursorBlinkMode.OFF) ;
            terminal.set_cursor_shape (Vte.CursorShape.UNDERLINE) ;
            // term.child_exited.connect (action_quit) ;
            terminal.button_press_event.connect (terminal_button_press) ;
            try {
                terminal.spawn_sync (Vte.PtyFlags.DEFAULT, terminalPath, { Vte.get_user_shell () }, null,
                                     SpawnFlags.SEARCH_PATH, null, out child_pid) ;
            } catch ( Error e ){
                stderr.printf ("error: %s\n", e.message) ;
            }
            var scrolled = new Gtk.ScrolledWindow (null, null) ;
            scrolled.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS) ;
            scrolled.add (terminal) ;

            Gtk.Label labelTerminal = new Gtk.Label ("Terminal") ;

            bottomBar.append_page (scrolled, labelTerminal) ;
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
