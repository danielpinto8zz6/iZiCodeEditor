using Gtk ;

namespace iZiCodeEditor{
    private GLib.List<string> files ;
    private Gtk.ApplicationWindow window ;
    private Gtk.Notebook notebook ;
    private Gtk.HeaderBar header ;
    private Gtk.Button searchButton ;

    public class MainWin : Gtk.ApplicationWindow {
        private const GLib.ActionEntry[] action_entries = {
            { "next-page", next_page },
            { "undo", action_undo },
            { "redo", action_redo },
            { "open", action_open },
            { "save", action_save },
            { "find", action_find },
            { "new", action_new },
            { "save-as", action_save_as },
            { "save-all", action_save_all },
            { "replace", action_replace },
            { "wrap", action_wrap },
            { "close", action_close },
            { "close-all", action_close_all },
            { "pref", action_preferences },
            { "about", action_about },
            { "quit", action_quit }
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
            app.set_accels_for_action ("app.find", { "<Primary>F" }) ;
            app.set_accels_for_action ("app.replace", { "<Primary>H" }) ;
            app.set_accels_for_action ("app.wrap", { "<Primary>R" }) ;
            app.set_accels_for_action ("app.color", { "F9" }) ;
            app.set_accels_for_action ("app.pref", { "<Primary>P" }) ;
            app.set_accels_for_action ("app.close", { "<Primary>W" }) ;
            app.set_accels_for_action ("app.close-all", { "<Primary><Shift>W" }) ;
            app.set_accels_for_action ("app.quit", { "<Primary>Q" }) ;
            // app menu
            var menu = new GLib.Menu () ;
            var section = new GLib.Menu () ;
            section.append ("Save As...", "app.save-as") ;
            section.append ("Save All", "app.save-all") ;
            menu.append_section (null, section) ;
            section = new GLib.Menu () ;
            section.append ("Find...", "app.find") ;
            section.append ("Replace...", "app.replace") ;
            section.append ("Text Wrap", "app.wrap") ;
            menu.append_section (null, section) ;
            section = new GLib.Menu () ;
            section.append ("Close", "app.close") ;
            section.append ("Close All", "app.close-all") ;
            menu.append_section (null, section) ;
            section = new GLib.Menu () ;
            section.append ("Preferences", "app.pref") ;
            menu.append_section (null, section) ;
            section = new GLib.Menu () ;
            section.append ("About", "app.about") ;
            section.append ("Quit", "app.quit") ;
            menu.append_section (null, section) ;
            // app.set_app_menu (menu) ;

            files = new GLib.List<string>() ;
            var settings = new iZiCodeEditor.Settings () ;
            settings.get_all () ;

            notebook = new Gtk.Notebook () ;
            notebook.expand = true ;
            notebook.popup_enable () ;
            notebook.set_scrollable (true) ;
            notebook.switch_page.connect (on_notebook_page_switched) ;
            notebook.page_reordered.connect (on_page_reordered) ;

            // window
            window = new Gtk.ApplicationWindow (app) ;
            window.window_position = Gtk.WindowPosition.CENTER ;
            window.set_default_size (width, height) ;
            window.set_icon_name (ICON) ;

            header = new Gtk.HeaderBar () ;
            header.set_show_close_button (true) ;
            header.set_title (NAME) ;
            window.set_titlebar (header) ;

            if( maximized == true ){
                window.maximize () ;
            }

            var leftIcons = new Box (Orientation.HORIZONTAL, 0) ;
            var rightIcons = new Box (Orientation.HORIZONTAL, 0) ;

            var openButton = new Button.from_icon_name ("document-open-symbolic", IconSize.BUTTON) ;
            var newButton = new Button.from_icon_name ("tab-new-symbolic", IconSize.BUTTON) ;
            searchButton = new Button.from_icon_name ("search-symbolic", IconSize.BUTTON) ;
            var saveButton = new Button.from_icon_name ("document-save-symbolic", IconSize.BUTTON) ;

            var menuButton = new Gtk.MenuButton () ;
            menuButton.image = new Image.from_icon_name ("open-menu-symbolic", IconSize.MENU) ;
            menuButton.use_popover = true ;
            menuButton.margin_start = 5 ;
            menuButton.set_menu_model (menu) ;

            openButton.clicked.connect (action_open) ;
            newButton.clicked.connect (action_new) ;
            saveButton.clicked.connect (action_save) ;
            searchButton.clicked.connect (action_find) ;

            leftIcons.pack_start (openButton, false, false, 0) ;
            leftIcons.pack_start (newButton, false, false, 0) ;
            leftIcons.get_style_context ().add_class ("linked") ;

            rightIcons.pack_start (searchButton, false, false, 0) ;
            rightIcons.pack_start (saveButton, false, false, 0) ;
            rightIcons.pack_start (menuButton, false, false, 0) ;
            rightIcons.get_style_context ().add_class ("linked") ;

            header.pack_start (leftIcons) ;
            header.pack_end (rightIcons) ;

            window.add (notebook) ;

            window.show_all () ;

            window.delete_event.connect (() => {
                action_quit () ;
                return true ;
            }) ;
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
            string title = GLib.Path.get_basename (path) ;
            string subtitle = Path.get_dirname (path) ;
            header.set_title (title) ;
            header.set_subtitle (subtitle) ;
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

        private void action_undo() {
            var operations = new iZiCodeEditor.Operations () ;
            operations.undo_last () ;
        }

        private void action_redo() {
            var operations = new iZiCodeEditor.Operations () ;
            operations.redo_last () ;
        }

        // buttons
        private void action_open() {
            var dialogs = new iZiCodeEditor.Dialogs () ;
            dialogs.show_open () ;
        }

        private void action_save() {
            var operations = new iZiCodeEditor.Operations () ;
            operations.save_current () ;
        }

        private void action_find() {
            var find = new iZiCodeEditor.Find () ;
            find.show_dialog () ;
        }

        // gear menu
        private void action_new() {
            var nbook = new iZiCodeEditor.NBook () ;
            nbook.create_tab ("/tmp/untitled") ;
        }

        private void action_save_as() {
            var dialogs = new iZiCodeEditor.Dialogs () ;
            dialogs.show_save () ;
        }

        private void action_save_all() {
            var operations = new iZiCodeEditor.Operations () ;
            operations.save_all () ;
        }

        private void action_replace() {
            var replace = new iZiCodeEditor.Replace () ;
            replace.show_dialog () ;
        }

        private void action_wrap() {
            var operations = new iZiCodeEditor.Operations () ;
            operations.wrap_text () ;
        }

        private void action_close() {
            var operations = new iZiCodeEditor.Operations () ;
            operations.close_tab () ;
        }

        private void action_close_all() {
            var operations = new iZiCodeEditor.Operations () ;
            operations.close_all_tabs () ;
        }

        // app menu
        private void action_preferences() {
            var prefdialog = new iZiCodeEditor.PrefDialog () ;
            prefdialog.on_activate () ;
        }

        private void action_about() {
            var dialogs = new iZiCodeEditor.Dialogs () ;
            dialogs.show_about () ;
        }

        public void action_quit() {
            window.get_size (out width, out height) ;
            maximized = window.is_maximized ;
            active_tab = notebook.get_current_page () ;
            var settings = new iZiCodeEditor.Settings () ;
            settings.set_width () ;
            settings.set_height () ;
            settings.set_maximized () ;
            settings.set_active_tab () ;
            GLib.Settings.sync () ;
            var dialogs = new iZiCodeEditor.Dialogs () ;
            dialogs.changes_all () ;
        }

    }
}
