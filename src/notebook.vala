namespace iZiCodeEditor{
    public class NBook : Gtk.Notebook {
        private const Gtk.TargetEntry[] targets = { { "text/uri-list", 0, 0 } } ;
        private Gtk.SourceView tab_view ;
        Gee.HashMap<string, string> brackets ;
        Gee.TreeSet<Gtk.TextBuffer> buffers ;
        string last_inserted ;
        private Gtk.SourceBuffer buffer ;
        private Gtk.SourceMap source_map ;

        public void create_tab(string path) {

            if( path != "Untitled" ){
                for( int i = 0 ; i < files.length () ; i++ ){
                    if( files.nth_data (i) == path ){
                        notebook.set_current_page (i) ;
                        // print("debug: refusing to add %s again\n", path);
                        return ;
                    }
                }
            }
            // Page
            tab_view = new Gtk.SourceView () ;
            source_map = new Gtk.SourceMap () ;

            var provider = new Gtk.CssProvider () ;
            try {
                provider.load_from_data (pango_font_description_to_css (), pango_font_description_to_css ().length) ;
            } catch ( Error e ){
                stderr.printf ("Error: %s\n", e.message) ;
            }
            Application.settings.changed["font"].connect (() => {
                try {
                    provider.load_from_data (pango_font_description_to_css (), pango_font_description_to_css ().length) ;
                } catch ( Error e ){
                    stderr.printf ("Error: %s\n", e.message) ;
                }
            }) ;

            tab_view.get_style_context ().add_provider (provider,
                                                        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION) ;

            Application.settings.bind ("tab-size", tab_view, "tab_width", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("indent-size", tab_view, "indent_width", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("margin-pos", tab_view, "right_margin_position", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("numbers-show", tab_view, "show_line_numbers", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("highlight", tab_view, "highlight_current_line", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("margin-show", tab_view, "show_right_margin", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("spaces", tab_view, "insert_spaces_instead_of_tabs", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("auto-indent", tab_view, "auto_indent", SettingsBindFlags.DEFAULT) ;
            if( Application.settings.get_boolean ("pattern-show") ){
                tab_view.set_background_pattern (Gtk.SourceBackgroundPatternType.GRID) ;
            } else {
                tab_view.set_background_pattern (Gtk.SourceBackgroundPatternType.NONE) ;
            }
            Application.settings.changed["pattern-show"].connect (() => {
                if( Application.settings.get_boolean ("pattern-show") ){
                    tab_view.background_pattern = Gtk.SourceBackgroundPatternType.GRID ;
                } else {
                    tab_view.background_pattern = Gtk.SourceBackgroundPatternType.NONE ;
                }
            }) ;
            // default
            tab_view.set_cursor_visible (true) ;
            tab_view.set_left_margin (10) ;
            tab_view.set_smart_backspace (true) ;

            if( Application.settings.get_boolean ("text-wrap") ){
                tab_view.set_wrap_mode (Gtk.WrapMode.WORD) ;
            } else {
                tab_view.set_wrap_mode (Gtk.WrapMode.NONE) ;
            }
            Application.settings.changed["pattern-show"].connect (() => {
                if( Application.settings.get_boolean ("text-wrap") ){
                    tab_view.set_wrap_mode (Gtk.WrapMode.WORD) ;
                } else {
                    tab_view.set_wrap_mode (Gtk.WrapMode.NONE) ;
                }
            }) ;

            //// drag and drop
            Gtk.drag_dest_set (tab_view, Gtk.DestDefaults.ALL, targets, Gdk.DragAction.COPY) ;
            tab_view.drag_data_received.connect (on_drag_data_received) ;

            buffers = new Gee.TreeSet<Gtk.TextBuffer> () ;
            brackets = new Gee.HashMap<string, string> () ;
            brackets.set ("(", ")") ;
            brackets.set ("[", "]") ;
            brackets.set ("{", "}") ;
            brackets.set ("<", ">") ;
            brackets.set ("⟨", "⟩") ;
            brackets.set ("｢", "｣") ;
            brackets.set ("⸤", "⸥") ;
            brackets.set ("‘", "‘") ;
            brackets.set ("'", "'") ;
            brackets.set ("\"", "\"") ;

            // style scheme
            buffer = (Gtk.SourceBuffer)tab_view.get_buffer () ;
            buffer.set_style_scheme (Gtk.SourceStyleSchemeManager.get_default ().get_scheme (Application.settings.get_string ("scheme"))) ;
            Application.settings.changed["scheme"].connect (() => {
                buffer.set_style_scheme (Gtk.SourceStyleSchemeManager.get_default ().get_scheme (Application.settings.get_string ("scheme"))) ;
            }) ;

            buffer.insert_text.disconnect (on_insert_text) ;
            buffer.insert_text.connect (on_insert_text) ;
            buffers.add (buffer) ;

            var scroll = new Gtk.ScrolledWindow (null, null) ;
            scroll.add (tab_view) ;
            scroll.set_hexpand (true) ;
            scroll.set_vexpand (true) ;

            source_map.set_view (tab_view) ;

            var tab_page = new Gtk.Grid () ;
            tab_page.attach (scroll, 0, 0, 1, 1) ;
            tab_page.attach_next_to (source_map, scroll, Gtk.PositionType.RIGHT, 1, 1) ;
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
            on_tabs_changed (notebook) ;
            notebook.show_all () ;
            notebook.page_added.connect (() => { on_tabs_changed (notebook) ; }) ;
            notebook.page_removed.connect (() => { on_tabs_changed (notebook) ; }) ;
            print ("%i", buffer.get_line_count ()) ;
            buffer.modified_changed.connect (() => {
                on_modified_changed (buffer, tab_label, path) ;
            }) ;
        }

        private void on_insert_text(ref Gtk.TextIter pos, string new_text, int new_text_length) {
            // If you are copy/pasting a large amount of text...
            if( new_text_length > 1 ){
                return ;
            }
            // To avoid infinite loop
            if( last_inserted == new_text ){
                return ;
            }

            if( new_text in brackets.keys ){
                string text = brackets.get (new_text) ;
                int len = text.length ;
                last_inserted = text ;
                buffer.insert (ref pos, text, len) ;

                // To make " and ' brackets work correctly (opening and closing chars are the same)
                last_inserted = null ;

                pos.backward_chars (len) ;
                buffer.place_cursor (pos) ;
            } else if( new_text in brackets.values ){ // Handle matching closing brackets.
                var end_pos = pos ;
                end_pos.forward_chars (1) ;

                if( new_text == buffer.get_text (pos, end_pos, true) ){
                    buffer.delete (ref pos, ref end_pos) ;
                    buffer.place_cursor (pos) ;
                }
            }
        }

        private void on_tabs_changed(Gtk.Notebook notebook) {
            var pages = notebook.get_n_pages () ;
            notebook.set_show_tabs (pages > 1) ;
            notebook.no_show_all = (pages == 0) ;
            notebook.visible = (pages > 0) ;
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
                    toolbar.set_title (NAME) ;
                    toolbar.set_subtitle (null) ;
                } else {
                    string filename = GLib.Path.get_basename (tabs.get_path_at_tab (notebook.get_current_page ())) ;
                    string filelocation = Path.get_dirname (tabs.get_path_at_tab (notebook.get_current_page ())) ;
                    if( filename == "Untitled" ){
                        toolbar.set_title (filename) ;
                        toolbar.set_subtitle (null) ;
                    } else {
                        toolbar.set_title (filename) ;
                        toolbar.set_subtitle (filelocation) ;
                    }
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
