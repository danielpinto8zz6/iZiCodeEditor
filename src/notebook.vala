namespace iZiCodeEditor{
    public class NBook : Gtk.Notebook {
        private const Gtk.TargetEntry[] targets = { { "text/uri-list", 0, 0 } } ;

        public void create_tab(string path) {
            for( int i = 0 ; i < files.length () ; i++ ){
                if( files.nth_data (i) == path ){
                    notebook.set_current_page (i) ;
                    // print("debug: refusing to add %s again\n", path);
                    return ;
                }
            }
            // Page
            var tab_view = new Gtk.SourceView () ;
            // from settings
            tab_view.override_font (Pango.FontDescription.from_string (font)) ;
            tab_view.set_right_margin_position (margin_pos) ;
            tab_view.set_indent_width (indent_size) ;
            tab_view.set_tab_width (tab_size) ;
            tab_view.set_show_line_numbers (numbers_show) ;
            tab_view.set_highlight_current_line (highlight) ;
            tab_view.set_show_right_margin (margin_show) ;
            tab_view.set_insert_spaces_instead_of_tabs (spaces) ;
            tab_view.set_auto_indent (auto_indent) ;
            if( pattern_show == true ){
                tab_view.set_background_pattern (Gtk.SourceBackgroundPatternType.GRID) ;
            } else {
                tab_view.set_background_pattern (Gtk.SourceBackgroundPatternType.NONE) ;
            }
            // default
            tab_view.set_cursor_visible (true) ;
            tab_view.set_left_margin (10) ;
            tab_view.set_smart_backspace (true) ;
            //// drag and drop
            Gtk.drag_dest_set (tab_view, Gtk.DestDefaults.ALL, targets, Gdk.DragAction.COPY) ;
            tab_view.drag_data_received.connect (on_drag_data_received) ;
            // style scheme
            var style_manager = new Gtk.SourceStyleSchemeManager () ;
            var style_scheme = style_manager.get_scheme (scheme) ;
            var buffer = (Gtk.SourceBuffer)tab_view.get_buffer () ;
            buffer.set_style_scheme (style_scheme) ;
            var tab_page = new Gtk.ScrolledWindow (null, null) ;
            tab_page.add (tab_view) ;
            tab_page.show_all () ;
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
            var css_stuff = """ * { padding :0; } """ ;
            var provider = new Gtk.CssProvider () ;
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
            files.append (path) ;
            print ("debug: added %s\n", path) ;
            var menu_label = new Gtk.Label (GLib.Path.get_basename (path)) ;
            menu_label.set_alignment (0.0f, 0.5f) ;
            // Add tab and page to notebook
            notebook.append_page_menu (tab_page, tab, menu_label) ;
            notebook.set_tab_reorderable (tab_page, true) ;
            notebook.set_current_page (notebook.get_n_pages () - 1) ;
            notebook.show_all () ;
            tab_view.grab_focus () ;
            buffer.modified_changed.connect (() => {
                on_modified_changed (buffer, tab_label, path) ;
            }) ;
        }

        // Drag Data
        private void on_drag_data_received(Gdk.DragContext drag_context, int x, int y,
                                           Gtk.SelectionData data, uint info, uint time) {
            string fileopen = null ;
            foreach( string uri in data.get_uris () ){
                fileopen = uri.replace ("file://", "") ;
                fileopen = Uri.unescape_string (fileopen) ;
                var nbook = new iZiCodeEditor.NBook () ;
                nbook.create_tab (fileopen) ;
                var operations = new iZiCodeEditor.Operations () ;
                operations.open_file (fileopen) ;
            }
            Gtk.drag_finish (drag_context, true, false, time) ;
        }

        // Destroy tab
        public void destroy_tab(Gtk.Widget page, string path) {
            int page_num = notebook.page_num (page) ;
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_sourceview_at_tab (page_num) ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            if( buffer.get_modified () == true ){
                var dialogs = new iZiCodeEditor.Dialogs () ;
                dialogs.changes_one (page_num, path) ;
            } else {
                notebook.remove_page (page_num) ;
                unowned List<string> del_item = files.find_custom (path, strcmp) ;
                files.remove_link (del_item) ;
                print ("debug: removed %s\n", path) ;
                if( notebook.get_n_pages () == 0 ){
                    window.set_title (NAME) ;
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
