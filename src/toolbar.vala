using Gtk ;
namespace iZiCodeEditor{
    public Gtk.Button searchButton ;

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

            var window = new iZiCodeEditor.MainWin () ;
            openButton.clicked.connect (window.action_open) ;
            newButton.clicked.connect (window.action_new) ;
            searchButton.clicked.connect (window.action_replace) ;
            saveButton.clicked.connect (window.action_save) ;

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
