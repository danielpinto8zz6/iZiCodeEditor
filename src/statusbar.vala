namespace iZiCodeEditor{

    public class StatusBar : Gtk.ActionBar {

        construct {
            var sourceview = new iZiCodeEditor.SourceView () ;
            Gtk.Button zoomoutButton = new Gtk.Button.from_icon_name ("zoom-out", Gtk.IconSize.SMALL_TOOLBAR) ;
            pack_start (zoomoutButton) ;
            zoomoutButton.clicked.connect (sourceview.zoom_out) ;
            Gtk.Button zoominButton = new Gtk.Button.from_icon_name ("zoom-in", Gtk.IconSize.SMALL_TOOLBAR) ;
            pack_start (zoominButton) ;
            zoominButton.clicked.connect (sourceview.zoom_in) ;

            var terminal_switch = new Gtk.Button.from_icon_name ("terminal", Gtk.IconSize.SMALL_TOOLBAR) ;
            pack_start (terminal_switch) ;

            terminal_switch.clicked.connect (() => {
                Application.settings_terminal.set_boolean ("terminal", !Application.settings_terminal.get_boolean ("terminal")) ;
            }) ;
        }
    }
}
