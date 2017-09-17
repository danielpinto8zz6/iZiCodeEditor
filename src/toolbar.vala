namespace iZiCodeEditor{

    public class Toolbar : Gtk.HeaderBar {

        construct {

            // app menu
            var menu = new GLib.Menu () ;
            var section = new GLib.Menu () ;
            section.append ("Save As...", "app.save-as") ;
            section.append ("Save All", "app.save-all") ;
            menu.append_section (null, section) ;
            section = new GLib.Menu () ;
            section.append ("Search...", "app.search") ;
            section.append ("Replace...", "app.replace") ;
            menu.append_section (null, section) ;
            section = new GLib.Menu () ;
            section.append ("Go to line...", "app.gotoline") ;
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

            var leftIcons = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;
            var rightIcons = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;

            var openButton = new Gtk.Button.from_icon_name ("document-open-symbolic", Gtk.IconSize.BUTTON) ;
            var newButton = new Gtk.Button.from_icon_name ("tab-new-symbolic", Gtk.IconSize.BUTTON) ;
            var saveButton = new Gtk.Button.from_icon_name ("document-save-symbolic", Gtk.IconSize.BUTTON) ;
            searchButton = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.BUTTON) ;

            var menuButton = new Gtk.MenuButton () ;
            menuButton.image = new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.MENU) ;
            menuButton.use_popover = true ;
            menuButton.margin_start = 5 ;
            menuButton.set_menu_model (menu) ;

            var window = new iZiCodeEditor.MainWin () ;
            openButton.clicked.connect (window.action_open) ;
            newButton.clicked.connect (window.action_new) ;
            saveButton.clicked.connect (window.action_save) ;
            searchButton.clicked.connect (window.action_search) ;

            leftIcons.pack_start (openButton, false, false, 0) ;
            leftIcons.pack_start (newButton, false, false, 0) ;
            leftIcons.get_style_context ().add_class ("linked") ;

            rightIcons.pack_start (searchButton, false, false, 0) ;
            rightIcons.pack_start (saveButton, false, false, 0) ;
            rightIcons.pack_start (menuButton, false, false, 0) ;
            rightIcons.get_style_context ().add_class ("linked") ;

            pack_start (leftIcons) ;
            pack_end (rightIcons) ;

        }
    }
}
