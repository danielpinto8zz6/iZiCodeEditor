namespace iZiCodeEditor{
    private GLib.List<string> files ;
    private Gtk.ApplicationWindow window ;
    private Gtk.Notebook notebook ;
    private Gtk.Button searchButton ;
    public iZiCodeEditor.Toolbar toolbar ;
    private Gtk.Notebook bottomBar ;
    private iZiCodeEditor.Terminal terminal ;

    public int FONT_SIZE_MAX = 72 ;
    public int FONT_SIZE_MIN = 7 ;

    public class MainWin : Gtk.ApplicationWindow {
        private const GLib.ActionEntry[] action_entries = {

            { "next-page", next_page },
            { "undo", action_undo },
            { "redo", action_redo },
            { "open", action_open },
            { "save", action_save },
            { "search", action_search },
            { "gotoline", action_gotoline },
            { "new", action_new },
            { "save-as", action_save_as },
            { "save-all", action_save_all },
            { "replace", action_replace },
            { "close", action_close },
            { "close-all", action_close_all },
            { "pref", action_preferences },
            { "about", action_about },
            { "quit", action_quit },
            { "zoom-in", zoom_in },
            { "zoom-out", zoom_out }
        } ;

        public void add_main_window(Gtk.Application app) {

            app.add_action_entries (action_entries, app) ;
            app.set_accels_for_action ("app.next-page", { "<Primary>Tab" }) ;
            app.set_accels_for_action ("app.show-menu", { "F10" }) ;
            app.set_accels_for_action ("app.undo", { "<Primary>Z" }) ;
            app.set_accels_for_action ("app.redo", { "<Primary>Y" }) ;
            app.set_accels_for_action ("app.open", { "<Primary>O" }) ;
            app.set_accels_for_action ("app.save", { "<Primary>S" }) ;
            app.set_accels_for_action ("app.new", { "<Primary>N" }) ;
            app.set_accels_for_action ("app.save-all", { "<Primary><Shift>S" }) ;
            app.set_accels_for_action ("app.search", { "<Primary>F" }) ;
            app.set_accels_for_action ("app.gotoline", { "<Primary>L" }) ;
            app.set_accels_for_action ("app.replace", { "<Primary>H" }) ;
            app.set_accels_for_action ("app.color", { "F9" }) ;
            app.set_accels_for_action ("app.pref", { "<Primary>P" }) ;
            app.set_accels_for_action ("app.close", { "<Primary>W" }) ;
            app.set_accels_for_action ("app.close-all", { "<Primary><Shift>W" }) ;
            app.set_accels_for_action ("app.quit", { "<Primary>Q" }) ;
            app.set_accels_for_action ("app.zoom-in", { "<Primary>plus" }) ;
            app.set_accels_for_action ("app.zoom-out", { "<Primary>minus" }) ;

            files = new GLib.List<string>() ;

            notebook = new Gtk.Notebook () ;
            notebook.expand = true ;
            notebook.popup_enable () ;
            notebook.set_scrollable (true) ;
            notebook.switch_page.connect (on_notebook_page_switched) ;
            notebook.page_reordered.connect (on_page_reordered) ;

            // window
            window = new Gtk.ApplicationWindow (app) ;
            window.window_position = Gtk.WindowPosition.CENTER ;
            window.set_default_size (Application.saved_state.get_int ("width"), Application.saved_state.get_int ("height")) ;
            window.set_icon_name (ICON) ;

            Gtk.Settings.get_default ().set_property ("gtk-application-prefer-dark-theme", Application.settings.get_boolean ("dark-mode")) ;

            Application.settings.changed["dark-mode"].connect (() => {
                Gtk.Settings.get_default ().set_property ("gtk-application-prefer-dark-theme", Application.settings.get_boolean ("dark-mode")) ;
            }) ;

            toolbar = new iZiCodeEditor.Toolbar () ;
            toolbar.set_show_close_button (true) ;
            toolbar.set_title (NAME) ;
            window.set_titlebar (toolbar) ;
            toolbar.show_all () ;

            if( Application.saved_state.get_boolean ("maximized") ){
                window.maximize () ;
            }

            var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) ;
            content.width_request = 200 ;
            content.pack_start (notebook, true, true, 0) ;

            // Bottom Bar
            bottomBar = new Gtk.Notebook () ;
            bottomBar.no_show_all = true ;
            bottomBar.page_added.connect (() => { on_bars_changed (bottomBar) ; }) ;
            bottomBar.page_removed.connect (() => { on_bars_changed (bottomBar) ; }) ;

            var leftPane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) ;
            leftPane.position = 180 ;
            // leftPane.pack1 (leftBar, false, false) ;
            leftPane.pack2 (content, true, false) ;

            var rightPane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) ;
            rightPane.position = (Application.saved_state.get_int ("width") - 180) ;
            rightPane.pack1 (leftPane, true, false) ;
            // rightPane.pack2 (rightBar, false, false) ;

            var mainPane = new Gtk.Paned (Gtk.Orientation.VERTICAL) ;
            mainPane.position = (Application.saved_state.get_int ("height") - 150) ;
            mainPane.pack1 (rightPane, true, false) ;
            mainPane.pack2 (bottomBar, false, false) ;

            Gtk.ActionBar action_bar = new Gtk.ActionBar () ;

            Gtk.Button zoomoutButton = new Gtk.Button.from_icon_name ("zoom-out", Gtk.IconSize.SMALL_TOOLBAR) ;
            action_bar.pack_start (zoomoutButton) ;
            zoomoutButton.clicked.connect (zoom_out) ;
            Gtk.Button zoominButton = new Gtk.Button.from_icon_name ("zoom-in", Gtk.IconSize.SMALL_TOOLBAR) ;
            action_bar.pack_start (zoominButton) ;
            zoominButton.clicked.connect (zoom_in) ;

            terminal = new iZiCodeEditor.Terminal () ;

            var label_terminal = new Gtk.Label ("Terminal") ;
            var scrolled_terminal = (Gtk.Scrollbar)terminal.get_child_at (1, 0) ;

            var terminal_switch = new Gtk.Button.from_icon_name ("terminal", Gtk.IconSize.SMALL_TOOLBAR) ;
            action_bar.pack_start (terminal_switch) ;

            terminal_switch.clicked.connect (() => {
                Application.settings.set_boolean ("terminal", !Application.settings.get_boolean ("terminal")) ;
            }) ;


            if( Application.settings.get_boolean ("terminal") ){
                bottomBar.append_page (terminal, label_terminal) ;
            } else {
                bottomBar.remove_page (notebook.page_num (scrolled_terminal)) ;
            }
            Application.settings.changed["terminal"].connect (() => {
                if( Application.settings.get_boolean ("terminal") ){
                    bottomBar.append_page (terminal, label_terminal) ;
                } else {
                    bottomBar.remove_page (notebook.page_num (scrolled_terminal)) ;
                }
            }) ;

            if( Application.settings.get_boolean ("status-bar") ){
                action_bar.show () ;
            } else {
                action_bar.hide () ;
            }
            Application.settings.changed["status-bar"].connect (() => {
                if( Application.settings.get_boolean ("status-bar") ){
                    action_bar.show () ;
                } else {
                    action_bar.hide () ;
                }
            }) ;

            var mainBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) ;

            mainBox.pack_start (mainPane, false, true, 0) ;

            mainBox.pack_end (action_bar, false, false, 0) ;

            mainBox.show_all () ;

            window.add (mainBox) ;

            window.show () ;

            window.delete_event.connect (() => {
                action_quit () ;
                return true ;
            }) ;
        }

        private void on_bars_changed(Gtk.Notebook notebook) {
            var pages = notebook.get_n_pages () ;
            notebook.set_show_tabs (pages > 1) ;
            notebook.no_show_all = (pages == 0) ;
            notebook.visible = (pages > 0) ;
        }

        private void next_page() {
            if( (notebook.get_current_page () + 1) == notebook.get_n_pages () ){
                notebook.set_current_page (0) ;
            } else {
                notebook.next_page () ;
            }
        }

        private void on_notebook_page_switched(Gtk.Widget page, uint page_num) {
            var tabs = new iZiCodeEditor.Tabs () ;
            string path = tabs.get_path_at_tab ((int) page_num) ;
            string filename = GLib.Path.get_basename (path) ;
            string filelocation = Path.get_dirname (path) ;
            if( filename == "Untitled" ){
                toolbar.set_title (filename) ;
                toolbar.set_subtitle (null) ;
            } else {
                toolbar.set_title (filename) ;
                toolbar.set_subtitle (filelocation) ;
            }

        }

        void on_page_reordered(Gtk.Widget page, uint pagenum) {
            // full path is in the tooltip text of Tab Label
            var tabs = new iZiCodeEditor.Tabs () ;
            Gtk.Label l = tabs.get_label_at_tab ((int) pagenum) ;
            string path = l.get_tooltip_text () ;
            // find and update file's position in GLib.List
            for( int i = 0 ; i < files.length () ; i++ ){
                if( files.nth_data (i) == path ){
                    // remove from files list
                    unowned List<string> del_item = files.find_custom (path, strcmp) ;
                    files.remove_link (del_item) ;
                    // insert in new position
                    files.insert (path, (int) pagenum) ;
                }
            }
            for( int i = 0 ; i < files.length () ; i++ ){
                print ("NEW LIST %s\n", files.nth_data (i)) ;

            }
        }

        public void action_app_quit() {
            window.get_application ().quit () ;
        }

        public void action_undo() {
            var operations = new iZiCodeEditor.Operations () ;
            operations.undo_last () ;
        }

        public void action_redo() {
            var operations = new iZiCodeEditor.Operations () ;
            operations.redo_last () ;
        }

// buttons
        public void action_open() {
            var dialogs = new iZiCodeEditor.Dialogs () ;
            dialogs.show_open () ;
        }

        public void action_save() {
            var operations = new iZiCodeEditor.Operations () ;
            operations.save_current () ;
        }

        public void action_search() {
            if( notebook.get_n_pages () == 0 ){
                return ;
            }
            var search = new iZiCodeEditor.Search () ;
            search.show_dialog () ;
        }

        public void action_gotoline() {
            if( notebook.get_n_pages () == 0 ){
                return ;
            }
            var gotoline = new iZiCodeEditor.GoToLine () ;
            gotoline.show_dialog () ;
        }

// gear menu
        public void action_new() {
            var nbook = new iZiCodeEditor.NBook () ;
            nbook.create_tab ("Untitled") ;
        }

        public void action_save_as() {
            var dialogs = new iZiCodeEditor.Dialogs () ;
            dialogs.show_save () ;
        }

        public void action_save_all() {
            var operations = new iZiCodeEditor.Operations () ;
            operations.save_all () ;
        }

        public void action_replace() {
            var replace = new iZiCodeEditor.Replace () ;
            replace.show_dialog () ;
        }

        public void action_close() {
            var operations = new iZiCodeEditor.Operations () ;
            operations.close_tab () ;
        }

        public void action_close_all() {
            var operations = new iZiCodeEditor.Operations () ;
            operations.close_all_tabs () ;
        }

// app menu
        public void action_preferences() {
            var prefdialog = new iZiCodeEditor.PrefDialog () ;
            prefdialog.on_activate () ;
        }

        public void action_about() {
            var dialogs = new iZiCodeEditor.Dialogs () ;
            dialogs.show_about () ;
        }

        public void action_quit() {
            int width, height ;
            window.get_size (out width, out height) ;
            Application.saved_state.set_boolean ("maximized", window.is_maximized) ;
            Application.saved_state.set_int ("width", width) ;
            Application.saved_state.set_int ("height", height) ;
            Application.saved_state.set_uint ("active-tab", notebook.get_current_page ()) ;

            var dialogs = new iZiCodeEditor.Dialogs () ;
            dialogs.changes_all () ;
        }

        public void zoom_in() {
            zooming (Gdk.ScrollDirection.UP) ;
        }

        public void zoom_out() {
            zooming (Gdk.ScrollDirection.DOWN) ;
        }

        private void zooming(Gdk.ScrollDirection direction) {
            string font = get_current_font () ;
            int font_size = (int) get_current_font_size () ;

            if( direction == Gdk.ScrollDirection.DOWN ){
                font_size-- ;
                if( font_size < FONT_SIZE_MIN ){
                    return ;
                }
            } else if( direction == Gdk.ScrollDirection.UP ){
                font_size++ ;
                if( font_size > FONT_SIZE_MAX ){
                    return ;
                }
            }

            string new_font = font + " " + font_size.to_string () ;
            Application.settings.set_string ("font", new_font) ;
        }

        public string get_current_font() {
            string font = Application.settings.get_string ("font") ;
            string font_family = font.substring (0, font.last_index_of (" ")) ;
            return font_family ;
        }

        public double get_current_font_size() {
            string font = Application.settings.get_string ("font") ;
            string font_size = font.substring (font.last_index_of (" ") + 1) ;
            return double.parse (font_size) ;
        }

        public string get_default_font() {
            string font = Application.settings.get_string ("font") ;
            string font_family = font.substring (0, font.last_index_of (" ")) ;
            return font_family ;
        }

        public double get_default_font_size() {
            string font = Application.settings.get_string ("font") ;
            string font_size = font.substring (font.last_index_of (" ") + 1) ;
            return double.parse (font_size) ;
        }

    }
}
