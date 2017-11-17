namespace iZiCodeEditor{

    public class HeaderBar : Gtk.HeaderBar {

        public Gtk.Button searchButton ;

        public HeaderBar (iZiCodeEditor.ApplicationWindow window) {

            // app menu
            var menu = new GLib.Menu () ;
            var section = new GLib.Menu () ;
            section.append ("Save As...", "win.save-as") ;
            section.append ("Save All", "win.save-all") ;
            menu.append_section (null, section) ;
            section = new GLib.Menu () ;
            section.append ("Search...", "win.search") ;
            section.append ("Replace...", "win.replace") ;
            menu.append_section (null, section) ;
            section = new GLib.Menu () ;
            section.append ("Go to line...", "win.gotoline") ;
            menu.append_section (null, section) ;
            section = new GLib.Menu () ;
            section.append ("Close", "win.close") ;
            section.append ("Close All", "win.close-all") ;
            menu.append_section (null, section) ;
            section = new GLib.Menu () ;
            section.append ("Preferences", "win.pref") ;
            menu.append_section (null, section) ;
            section = new GLib.Menu () ;
            section.append ("About", "win.about") ;
            section.append ("Quit", "win.quit") ;
            menu.append_section (null, section) ;

            var leftIcons = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;
            var rightIcons = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;

            var openButton = new Gtk.Button.from_icon_name ("document-open-symbolic", Gtk.IconSize.BUTTON) ;
            var newButton = new Gtk.Button.from_icon_name ("tab-new-symbolic", Gtk.IconSize.BUTTON) ;
            var saveButton = new Gtk.Button.from_icon_name ("document-save-symbolic", Gtk.IconSize.BUTTON) ;
            searchButton = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.BUTTON) ;

            var menuButton = new Gtk.MenuButton () ;
            menuButton.image = new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.BUTTON) ;
            menuButton.use_popover = true ;
            menuButton.set_menu_model (menu) ;

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
