namespace iZiCodeEditor{
    public class ApplicationWindow : Gtk.ApplicationWindow {

        public iZiCodeEditor.Notebook notebook ;
        public Gtk.Notebook bottomBar ;
        private iZiCodeEditor.Terminal terminal ;
        public iZiCodeEditor.HeaderBar headerbar ;
        public iZiCodeEditor.StatusBar status_bar ;
        public iZiCodeEditor.Operations operations ;
        public iZiCodeEditor.Dialogs dialogs ;
        public iZiCodeEditor.Tabs tabs ;
        public iZiCodeEditor.Search search ;
        public iZiCodeEditor.GoToLine gotoline ;
        public iZiCodeEditor.Replace replace ;
        public iZiCodeEditor.Preferences preferences ;
        public GLib.List<string> files ;


        public const string ACTION_PREFIX = "win." ;
        public const string ACTION_NEXT_PAGE = "next-page" ;
        public const string ACTION_UNDO = "undo" ;
        public const string ACTION_REDO = "redo" ;
        public const string ACTION_OPEN = "open" ;
        public const string ACTION_SAVE = "save" ;
        public const string ACTION_SEARCH = "search" ;
        public const string ACTION_GOTOLINE = "gotoline" ;
        public const string ACTION_NEW = "new" ;
        public const string ACTION_SAVE_AS = "save-as" ;
        public const string ACTION_SAVE_ALL = "save-all" ;
        public const string ACTION_REPLACE = "replace" ;
        public const string ACTION_CLOSE = "close" ;
        public const string ACTION_CLOSE_ALL = "close-all" ;
        public const string ACTION_PREFERENCES = "pref" ;
        public const string ACTION_ABOUT = "about" ;
        public const string ACTION_QUIT = "quit" ;
        public const string ACTION_SET_DEFAULT_ZOOM = "zoom-default" ;

        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> () ;

        public const GLib.ActionEntry[] action_entries = {
            { ACTION_NEXT_PAGE, next_page },
            { ACTION_UNDO, action_undo },
            { ACTION_REDO, action_redo },
            { ACTION_OPEN, action_open },
            { ACTION_SAVE, action_save },
            { ACTION_SEARCH, action_search },
            { ACTION_GOTOLINE, action_gotoline },
            { ACTION_NEW, action_new },
            { ACTION_SAVE_AS, action_save_as },
            { ACTION_SAVE_ALL, action_save_all },
            { ACTION_REPLACE, action_replace },
            { ACTION_CLOSE, action_close },
            { ACTION_CLOSE_ALL, action_close_all },
            { ACTION_PREFERENCES, action_preferences },
            { ACTION_ABOUT, action_about },
            { ACTION_QUIT, action_quit },
            { ACTION_SET_DEFAULT_ZOOM, set_default_zoom },
        } ;

        public ApplicationWindow (Gtk.Application app) {

            Object (
                application: app,
                icon_name: ICON,
                title: NAME
                ) ;

            action_accelerators.set (ACTION_NEXT_PAGE, "<Control>Tab") ;
            action_accelerators.set (ACTION_UNDO, "<Control>Z") ;
            action_accelerators.set (ACTION_REDO, "<Control>Y") ;
            action_accelerators.set (ACTION_OPEN, "<Control>O") ;
            action_accelerators.set (ACTION_SAVE, "<Control>S") ;
            action_accelerators.set (ACTION_NEW, "<Control>N") ;
            action_accelerators.set (ACTION_SAVE_ALL, "<Control><Shift>S") ;
            action_accelerators.set (ACTION_SEARCH, "<Control>F") ;
            action_accelerators.set (ACTION_GOTOLINE, "<Control>L") ;
            action_accelerators.set (ACTION_REPLACE, "<Control>H") ;
            action_accelerators.set (ACTION_PREFERENCES, "<Control>P") ;
            action_accelerators.set (ACTION_CLOSE, "<Control>W") ;
            action_accelerators.set (ACTION_CLOSE_ALL, "<Control><Shift>W") ;
            action_accelerators.set (ACTION_QUIT, "<Control>Q") ;
            action_accelerators.set (ACTION_SET_DEFAULT_ZOOM, "<Control>0") ;

            var actions = new SimpleActionGroup () ;
            actions.add_action_entries (action_entries, this) ;
            insert_action_group ("win", actions) ;

            foreach( var action in action_accelerators.get_keys ()){
                application.set_accels_for_action (ACTION_PREFIX + action, action_accelerators[action].to_array ()) ;
            }

        }

        construct {

            files = new GLib.List<string>() ;

            // window
            window_position = Gtk.WindowPosition.CENTER ;
            set_default_size (Application.saved_state.get_int ("width"), Application.saved_state.get_int ("height")) ;

            Gtk.Settings.get_default ().set_property ("gtk-application-prefer-dark-theme", Application.settings_view.get_boolean ("dark-mode")) ;

            Application.settings_view.changed["dark-mode"].connect (() => {
                Gtk.Settings.get_default ().set_property ("gtk-application-prefer-dark-theme", Application.settings_view.get_boolean ("dark-mode")) ;
            }) ;

            if( Application.saved_state.get_boolean ("maximized")){
                maximize () ;
            }

            headerbar = new iZiCodeEditor.HeaderBar (this) ;
            set_titlebar (headerbar) ;
            headerbar.show_all () ;

            notebook = new iZiCodeEditor.Notebook (this) ;
            notebook.switch_page.connect (on_notebook_page_switched) ;
            notebook.page_reordered.connect (on_page_reordered) ;

            operations = new iZiCodeEditor.Operations (this) ;
            dialogs = new iZiCodeEditor.Dialogs (this) ;
            tabs = new iZiCodeEditor.Tabs (this) ;

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

            terminal = new iZiCodeEditor.Terminal () ;

            var label_terminal = new Gtk.Label ("Terminal") ;
            var scrolled_terminal = (Gtk.Scrollbar)terminal.get_child_at (1, 0) ;

            if( Application.settings_terminal.get_boolean ("terminal")){
                bottomBar.append_page (terminal, label_terminal) ;
            } else {
                bottomBar.remove_page (notebook.page_num (scrolled_terminal)) ;
            }
            Application.settings_terminal.changed["terminal"].connect (() => {
                if( Application.settings_terminal.get_boolean ("terminal")){
                    bottomBar.append_page (terminal, label_terminal) ;
                } else {
                    bottomBar.remove_page (notebook.page_num (scrolled_terminal)) ;
                }
            }) ;

            status_bar = new iZiCodeEditor.StatusBar (this) ;

            var mainBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) ;

            mainBox.pack_start (mainPane, false, true, 0) ;

            mainBox.pack_end (status_bar, false, false, 0) ;

            mainBox.show_all () ;

            add (mainBox) ;

            if( Application.settings_view.get_boolean ("status-bar")){
                status_bar.show () ;
            } else {
                status_bar.hide () ;
            }
            Application.settings_view.changed["status-bar"].connect (() => {
                if( Application.settings_view.get_boolean ("status-bar")){
                    status_bar.show () ;
                } else {
                    status_bar.hide () ;
                }
            }) ;

            key_press_event.connect ((key_event) => {
                if( Gdk.ModifierType.CONTROL_MASK in key_event.state ){
                    if( key_event.keyval == Gdk.Key.plus ){
                        zoom_in () ;
                        return true ;
                    } else if( key_event.keyval == Gdk.Key.minus ){
                        zoom_out () ;
                        return true ;
                    }
                }

                return false ;
            }) ;

            delete_event.connect (() => {
                action_quit () ;
                return true ;
            }) ;

            show () ;
        }

        private void zoom_in() {
            operations.zooming (Gdk.ScrollDirection.UP) ;
        }

        private void zoom_out() {
            operations.zooming (Gdk.ScrollDirection.DOWN) ;
        }

        private void set_default_zoom() {
            Application.settings_fonts_colors.set_string ("font", operations.get_default_font () + " 14") ;
        }

        private void on_bars_changed(Gtk.Notebook notebook) {
            var pages = notebook.get_n_pages () ;
            notebook.set_show_tabs (pages > 1) ;
            notebook.no_show_all = (pages == 0) ;
            notebook.visible = (pages > 0) ;
        }

        private void next_page() {
            if((notebook.get_current_page () + 1) == notebook.get_n_pages ()){
                notebook.set_current_page (0) ;
            } else {
                notebook.next_page () ;
            }
        }

        private void on_notebook_page_switched(Gtk.Widget page, uint page_num) {
            string path = files.nth_data (page_num) ;
            string filename = GLib.Path.get_basename (path) ;
            string filelocation = Path.get_dirname (path) ;
            if( filename == "Untitled" ){
                headerbar.set_title (filename) ;
                headerbar.set_subtitle (null) ;
            } else {
                headerbar.set_title (filename) ;
                headerbar.set_subtitle (filelocation) ;
            }
            status_bar.update_statusbar (page, page_num) ;
        }

        void on_page_reordered(Gtk.Widget page, uint pagenum) {
            // full path is in the tooltip text of Tab Label
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

        public void action_undo() {
            tabs.get_current_sourceview ().undo () ;
        }

        public void action_redo() {
            tabs.get_current_sourceview ().redo () ;
        }

        public void action_open() {
            dialogs.show_open () ;
        }

        public void action_save() {
            operations.save_current () ;
        }

        public void action_search() {
            search = new iZiCodeEditor.Search (this) ;
            search.show_all () ;
        }

        public void action_gotoline() {
            gotoline = new iZiCodeEditor.GoToLine (this) ;
            gotoline.show_all () ;
        }

        public void action_new() {
            notebook.create_tab ("Untitled") ;
        }

        public void action_save_as() {
            dialogs.show_save () ;
        }

        public void action_save_all() {
            operations.save_all () ;
        }

        public void action_replace() {
            replace = new iZiCodeEditor.Replace (this) ;
            replace.show_all () ;
        }

        public void action_close() {
            notebook.destroy_tab (notebook.get_nth_page (notebook.get_current_page ()), files.nth_data (notebook.get_current_page ())) ;
        }

        public void action_close_all() {
            for( uint i = files.length () ; i > 0 ; i-- ){
                notebook.destroy_tab (notebook.get_nth_page (notebook.get_current_page ()), files.nth_data (notebook.get_current_page ())) ;
            }
        }

        public void action_preferences() {
            preferences = new iZiCodeEditor.Preferences (this) ;
            preferences.show_all () ;
        }

        public void action_about() {
            dialogs.show_about () ;
        }

        public void action_quit() {
            int width, height ;
            get_size (out width, out height) ;
            Application.saved_state.set_boolean ("maximized", is_maximized) ;
            Application.saved_state.set_int ("width", width) ;
            Application.saved_state.set_int ("height", height) ;
            Application.saved_state.set_uint ("active-tab", notebook.get_current_page ()) ;

            dialogs.changes_all () ;

            get_application ().quit () ;
        }

    }
}
