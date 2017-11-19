namespace iZiCodeEditor{
    public class Notebook : Gtk.Notebook {
        public unowned ApplicationWindow window { get ; construct set ; }

        public iZiCodeEditor.SourceView tab_view ;

        private Gtk.SourceMap source_map ;

        public Notebook (iZiCodeEditor.ApplicationWindow window) {
            Object (
                window: window,
                expand: true) ;
        }

        public void create_tab(string path) {

            tab_view = new iZiCodeEditor.SourceView (window) ;
            source_map = new Gtk.SourceMap () ;

            tab_view.drag_data_received.connect (on_drag_data_received) ;

            var scroll = new Gtk.ScrolledWindow (null, null) ;
            scroll.add (tab_view) ;
            scroll.set_hexpand (true) ;
            scroll.set_vexpand (true) ;

            source_map.set_view (tab_view) ;

            var tab_page = new Gtk.Grid () ;
            tab_page.attach (scroll, 0, 0, 1, 1) ;
            tab_page.attach_next_to (source_map, scroll, Gtk.PositionType.RIGHT, 1, 1) ;
            tab_page.show_all () ;

            if( Application.settings_view.get_boolean ("source-map")){
                source_map.show () ;
                scroll.vscrollbar_policy = Gtk.PolicyType.EXTERNAL ;
            } else {
                source_map.hide () ;
                source_map.no_show_all = true ;
                scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC ;
            }
            Application.settings_view.changed["source-map"].connect (() => {
                if( Application.settings_view.get_boolean ("source-map")){
                    source_map.show () ;
                    scroll.vscrollbar_policy = Gtk.PolicyType.EXTERNAL ;
                } else {
                    source_map.hide () ;
                    source_map.no_show_all = true ;
                    scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC ;
                }
            }) ;

            // File name

            string fname = GLib.Path.get_basename (path) ;
            if( fname.length > 18 ){
                fname = fname.substring (0, 15) + "..." ;
            }
            // Tab
            var tab_label = new Gtk.Label (fname) ;
            tab_label.set_tooltip_text (path) ;
            tab_label.set_alignment (0, 0.5f) ;
            tab_label.set_hexpand (true) ;
            tab_label.set_size_request (100, -1) ;
            var eventbox = new Gtk.EventBox () ;
            eventbox.add (tab_label) ;
            // Close tab with middle click
            eventbox.button_press_event.connect ((event) => {
                if( event.button == 2 ){
                    destroy_tab (tab_page, path) ;
                }
                return false ;
            }) ;
            var provider = new Gtk.CssProvider () ;
            var css_stuff = """ * { padding :0; } """ ;
            try {
                provider.load_from_data (css_stuff, css_stuff.length) ;
            } catch ( Error e ){
                stderr.printf ("Error: %s\n", e.message) ;
            }
            var tab_button = new Gtk.Button.from_icon_name ("window-close-symbolic",
                                                            Gtk.IconSize.MENU) ;
            tab_button.set_relief (Gtk.ReliefStyle.NONE) ;
            tab_button.set_hexpand (false) ;
            tab_button.get_style_context ().add_provider (provider,
                                                          Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION) ;
            tab_button.clicked.connect (() => {
                destroy_tab (tab_page, path) ;
            }) ;
            var tab = new Gtk.Grid () ;
            tab.attach (eventbox, 0, 0, 1, 1) ;
            tab.attach (tab_button, 1, 0, 1, 1) ;
            tab.set_hexpand (false) ;
            tab.show_all () ;
            window.files.append (path) ;
            // print ("debug: added %s\n", path) ;
            var menu_label = new Gtk.Label (GLib.Path.get_basename (path)) ;
            menu_label.set_alignment (0.0f, 0.5f) ;
            // Add tab and page to notebook
            append_page_menu (tab_page, tab, menu_label) ;
            set_tab_reorderable (tab_page, true) ;
            set_current_page (get_n_pages () - 1) ;
            on_tabs_changed () ;
            show_all () ;
            page_added.connect (() => { on_tabs_changed () ; }) ;
            page_removed.connect (() => { on_tabs_changed () ; }) ;
            tab_view.buffer.modified_changed.connect (() => {
                on_modified_changed (tab_view.buffer, tab_label, path) ;
            }) ;
        }

        private void on_tabs_changed() {
            var pages = get_n_pages () ;
            set_show_tabs (pages > 1) ;
            no_show_all = (pages == 0) ;
            visible = (pages > 0) ;
        }

        // Drag Data
        private void on_drag_data_received(Gdk.DragContext drag_context, int x, int y,
                                           Gtk.SelectionData data, uint info, uint time) {
            string fileopen = null ;
            foreach( string uri in data.get_uris ()){
                fileopen = uri.replace ("file://", "") ;
                fileopen = Uri.unescape_string (fileopen) ;
                create_tab (fileopen) ;
                window.operations.open_file.begin (fileopen) ;
            }
            Gtk.drag_finish (drag_context, true, false, time) ;
        }

        // Destroy tab
        public void destroy_tab(Gtk.Widget page, string path) {
            int page_num = page_num (page) ;
            var view = window.tabs.get_sourceview_at_tab (page_num) ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            if( buffer.get_modified () == true ){
                window.dialogs.changes_one (page_num, path) ;
            } else {
                unowned List<string> del_item = window.files.find_custom (path, strcmp) ;
                window.files.remove_link (del_item) ;
                remove_page (page_num) ;
                if( get_n_pages () == 0 ){
                    window.headerbar.set_title (NAME) ;
                    window.headerbar.set_subtitle (null) ;
                }
            }
        }

        // Update label on modified buffer
        public void on_modified_changed(Gtk.SourceBuffer bf, Gtk.Label lab, string p) {
            if( bf.get_modified () == true ){
                lab.set_text (GLib.Path.get_basename (p) + " *") ;
            } else {
                lab.set_text (GLib.Path.get_basename (p)) ;
            }
        }

    }
}
