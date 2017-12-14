namespace iZiCodeEditor{
    public class GoToLine : Gtk.Popover {
        public unowned ApplicationWindow window { get ; construct set ; }

        private Gtk.Entry entry ;

        public GoToLine (iZiCodeEditor.ApplicationWindow window) {
            Object (
                window: window,
                relative_to: window.headerbar.searchButton) ;
        }

        construct {
            var view = window.notebook.current_doc.sourceview ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            entry = new Gtk.Entry () ;
            entry.set_size_request (200, 30) ;

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

            entry.activate.connect_after (() => {
                int line, offset ;
                entry.text.scanf ("%i.%i", out line, out offset) ;
                if( line < buffer.get_line_count ()){
                    view.go_to (line, offset) ;
                    view.grab_focus () ;
                } else {
                    entry.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR) ;
                }
            }) ;

            entry.grab_focus () ;

            hide.connect (on_popover_hide) ;
        }

        private void on_popover_hide() {
            var view = window.notebook.current_doc.sourceview ;
            view.grab_focus () ;
        }

    }
}
