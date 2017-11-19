namespace iZiCodeEditor{
    public class Tabs : GLib.Object {
        public unowned ApplicationWindow window { get ; construct set ; }

        public Tabs (iZiCodeEditor.ApplicationWindow window) {
            Object (
                window: window) ;
        }

        public Gtk.SourceView get_sourceview_at_tab(int pos) {
            var tab_page = (Gtk.Grid)window.notebook.get_nth_page (pos) ;
            var scrolled = (Gtk.ScrolledWindow)tab_page.get_child_at (0, 0) ;
            var view = (Gtk.SourceView)scrolled.get_child () ;
            return view ;
        }

        public Gtk.SourceView get_current_sourceview() {
            var tab_page = (Gtk.Grid)window.notebook.get_nth_page (window.notebook.get_current_page ()) ;
            var scrolled = (Gtk.ScrolledWindow)tab_page.get_child_at (0, 0) ;
            var view = (Gtk.SourceView)scrolled.get_child () ;
            return view ;
        }

    }
}
