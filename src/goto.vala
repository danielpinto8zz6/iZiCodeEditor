namespace iZiCodeEditor{
    public class GoToLine : Gtk.Dialog {
        private Gtk.SpinButton entry ;
        private Gtk.Popover popover ;

        public void show_dialog() {
            if( notebook.get_n_pages () == 0 )
                return ;

            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            entry = new Gtk.SpinButton.with_range (1, buffer.get_line_count (), 1) ;
            entry.set_size_request (200, 30) ;
            entry.digits = 0 ;

            var gotoBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;
            gotoBox.pack_start (entry, false, true, 0) ;
            gotoBox.valign = Gtk.Align.CENTER ;
            gotoBox.set_border_width (3) ;
            gotoBox.show_all () ;

            popover = new Gtk.Popover (searchButton) ;
            popover.add (gotoBox) ;
            popover.set_visible (true) ;

            popover.scroll_event.connect ((evt) => {
                var scrolled = (Gtk.ScrolledWindow)notebook.get_nth_page (notebook.get_current_page ()) ;
                scrolled.scroll_event (evt) ;
                return Gdk.EVENT_PROPAGATE ;
            }) ;

            //// signals
            entry.value_changed.connect (() => {
                go_to (entry.get_value_as_int ()) ;
            }) ;
            entry.grab_focus () ;

            popover.hide.connect (on_popover_hide) ;
        }

        // Search forward on entry changed
        public void go_to(int line) {
            Gtk.TextIter it ;
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            buffer.get_iter_at_line (out it, line - 1) ;
            view.scroll_to_iter (it, 0, false, 0, 0) ;
            buffer.place_cursor (it) ;
        }

        // On popover hide
        private void on_popover_hide() {
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            view.grab_focus () ;
        }

    }
}
