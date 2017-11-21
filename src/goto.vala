namespace iZiCodeEditor{
    public class GoToLine : Gtk.Popover {
        public unowned ApplicationWindow window { get ; construct set ; }

        private Gtk.SpinButton entry ;

        public GoToLine (iZiCodeEditor.ApplicationWindow window) {
            Object (
                window: window,
                relative_to: window.headerbar.searchButton) ;
        }

        construct {
            var view = window.notebook.current_doc.sourceview ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            entry = new Gtk.SpinButton.with_range (1, buffer.get_line_count (), 1) ;
            entry.set_size_request (200, 30) ;
            entry.digits = 0 ;

            var gotoBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;
            gotoBox.pack_start (entry, false, true, 0) ;
            gotoBox.valign = Gtk.Align.CENTER ;
            gotoBox.set_border_width (3) ;
            gotoBox.show_all () ;

            add (gotoBox) ;

            scroll_event.connect ((evt) => {
                var tab_page = (Gtk.Grid)window.notebook.get_nth_page (window.notebook.get_current_page ()) ;
                var scrolled = (Gtk.ScrolledWindow)tab_page.get_child_at (0, 0) ;
                scrolled.scroll_event (evt) ;
                return Gdk.EVENT_PROPAGATE ;
            }) ;

            //// signals
            entry.value_changed.connect (() => {
                go_to (entry.get_value_as_int ()) ;
            }) ;
            entry.grab_focus () ;

            hide.connect (on_popover_hide) ;
        }

        // Search forward on entry changed
        public void go_to(int line) {
            Gtk.TextIter it ;
            var view = window.notebook.current_doc.sourceview ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            buffer.get_iter_at_line (out it, line - 1) ;
            view.scroll_to_iter (it, 0, false, 0, 0) ;
            buffer.place_cursor (it) ;
        }

        // On popover hide
        private void on_popover_hide() {
            var view = window.notebook.current_doc.sourceview ;
            view.grab_focus () ;
        }

    }
}
