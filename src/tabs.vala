namespace iZiCodeEditor{
    public class Tabs : GLib.Object {
        public string get_path_at_tab(int pos) {
            string path = files.nth_data (pos) ;
            return path ;
        }

        public Gtk.SourceView get_sourceview_at_tab(int pos) {
            var tab_page = (Gtk.Grid)notebook.get_nth_page (pos) ;
            var scrolled = (Gtk.ScrolledWindow)tab_page.get_child_at (0, 0) ;
            var view = (Gtk.SourceView)scrolled.get_child () ;
            return view ;
        }

        public Gtk.Label get_label_at_tab(int pos) {
            var tab_page = (Gtk.Grid)notebook.get_nth_page (pos) ;
            var scrolled = (Gtk.ScrolledWindow)tab_page.get_child_at (0, 0) ;
            var grid = (Gtk.Grid)notebook.get_tab_label (scrolled) ;
            var eventbox = (Gtk.EventBox)grid.get_child_at (0, 0) ;
            var label = (Gtk.Label)eventbox.get_child () ;
            return label ;
        }

        public string get_current_path() {
            string path = files.nth_data (notebook.get_current_page ()) ;
            return path ;
        }

        public Gtk.SourceView get_current_sourceview() {
            var tab_page = (Gtk.Grid)notebook.get_nth_page (notebook.get_current_page ()) ;
            var scrolled = (Gtk.ScrolledWindow)tab_page.get_child_at (0, 0) ;
            var view = (Gtk.SourceView)scrolled.get_child () ;
            return view ;
        }

        public Gtk.Label get_current_label() {
            var tab_page = (Gtk.Grid)notebook.get_nth_page (notebook.get_current_page ()) ;
            var scrolled = (Gtk.ScrolledWindow)tab_page.get_child_at (0, 0) ;
            var grid = (Gtk.Grid)notebook.get_tab_label (scrolled) ;
            var eventbox = (Gtk.EventBox)grid.get_child_at (0, 0) ;
            var label = (Gtk.Label)eventbox.get_child () ;
            return label ;
        }

        public void check_notebook_for_file_name(string path) {
            notebook.get_current_page () ;
            for( int i = 0 ; i < files.length () ; i++ ){
                if( files.nth_data (i) == path ){
                    var tab_page = (Gtk.Grid)notebook.get_nth_page (i) ;
                    var nbook = new iZiCodeEditor.NBook () ;
                    nbook.destroy_tab (tab_page, path) ;
                    //print ("debug: removed tab number %d with: %s\n", i, path) ;
                }
            }
        }

    }
}
