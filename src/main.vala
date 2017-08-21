using Gtk ;

class iZiCodeEditor : Window {

    SourceView source_view ;
    SourceLanguageManager language_manager ;
    SourceFile file ;
    SourceBuffer buffer ;
    string fileName ;
    string fileLocation ;
    bool unsaved = true ;

    private static GLib.Settings _settings = new GLib.Settings ("com.github.danielpinto8zz6.iZiCodeEditor") ;
    public static GLib.Settings settings {
        get {
            return _settings ;
        }
    }

    public iZiCodeEditor () {

        var header = new HeaderBar () ;
        header.set_show_close_button (true) ;
        header.set_title ("iZiCodeEditor") ;
        header.set_has_subtitle (true) ;

        this.window_position = WindowPosition.CENTER ;
        this.title = "iZiCodeEditor" ;
        this.icon_name = "accessories-text-editor" ;
        set_default_size (800, 500) ;
        set_titlebar (header) ;

        var label = new Label (null) ;
        label.set_label ("Untitled 1") ;

        var leftIcons = new Box (Orientation.HORIZONTAL, 0) ;
        var rightIcons = new Box (Orientation.HORIZONTAL, 0) ;

        var notebook = new Notebook () ;
        this.add (notebook) ;

        buffer = new SourceBuffer (null) ;
        source_view = new SourceView.with_buffer (buffer) ;
        source_view.wrap_mode = WrapMode.NONE ;
        source_view.indent = 2 ;
        source_view.monospace = true ;
        source_view.buffer.text = "" ;
        // source_view.auto_indent = true ;
        // source_view.indent_on_tab = true ;
        // source_view.show_line_numbers = true ;
        // source_view.highlight_current_line = true ;
        // source_view.smart_home_end = SourceSmartHomeEndType.BEFORE ;
        // source_view.auto_indent = true ;
        // source_view.show_right_margin = false ;
        // buffer.set_style_scheme (SourceStyleSchemeManager.get_default ().get_scheme ("classic")) ;
        // buffer.highlight_syntax = true ;

        /* Bind Prefrences */
        // Bind auto-indent option
        settings.bind ("auto-indent", source_view, "auto_indent", SettingsBindFlags.DEFAULT) ;
        settings.changed["indent-width"].connect (() => {
            source_view.indent_width = (settings.get_int ("indent-width")) ;
        }) ;                                    // Bind tab indent setting
        settings.bind ("indent-on-tab", source_view, "indent_on_tab", SettingsBindFlags.DEFAULT) ;

        // Bind the line number margin prefrence
        settings.bind ("show-line-numbers", source_view, "show_line_numbers", SettingsBindFlags.DEFAULT) ;
        settings.bind ("highlight-current-line", source_view, "highlight_current_line", SettingsBindFlags.DEFAULT) ;
        source_view.smart_home_end = SourceSmartHomeEndType.BEFORE ;
        settings.bind ("show-right-margin", source_view, "show_right_margin", SettingsBindFlags.DEFAULT) ;
        settings.bind ("spaces-instead-of-tabs", source_view, "insert_spaces_instead_of_tabs", SettingsBindFlags.DEFAULT) ;
        buffer.set_style_scheme (SourceStyleSchemeManager.get_default ().get_scheme (settings.get_string ("color-scheme"))) ;
        settings.changed["color-scheme"].connect (() => {
            buffer.set_style_scheme (SourceStyleSchemeManager.get_default ().get_scheme (settings.get_string ("color-scheme"))) ;
        }) ;
        settings.changed["right-margin-position"].connect (() => {
            source_view.right_margin_position = (settings.get_int ("right-margin-position")) ;
        }) ;
        /* Bind Prefrences */

        language_manager = SourceLanguageManager.get_default () ;

        var scrolled_window = new ScrolledWindow (null, null) ;
        scrolled_window.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC) ;
        scrolled_window.add (source_view) ;

        var vbox = new Box (Orientation.VERTICAL, 0) ;
        vbox.pack_start (scrolled_window, true, true, 0) ;

        notebook.append_page (vbox, label) ;

        var openButton = new Button.from_icon_name ("document-open-symbolic", IconSize.BUTTON) ;
        openButton.clicked.connect (() => {
            if( on_open () == true ){
                header.set_title (fileName) ;
                header.set_subtitle (fileLocation) ;
                label.set_label (fileName) ;
            }
        }) ;

        var newButton = new Button.from_icon_name ("tab-new-symbolic", IconSize.BUTTON) ;
        newButton.clicked.connect (() => {
        }) ;

        var saveButton = new Button.from_icon_name ("document-save-symbolic", IconSize.BUTTON) ;
        saveButton.clicked.connect (() => {
            save () ;
            header.set_title (fileName) ;
            header.set_subtitle (fileLocation) ;
            label.set_label (fileName) ;
        }) ;

        var menuButton = new Button.from_icon_name ("open-menu-symbolic", IconSize.BUTTON) ;

        var grid = new Grid () ;

        grid.set_column_spacing (10) ;
        grid.set_margin_top (10) ;
        grid.set_margin_end (10) ;
        grid.set_margin_bottom (10) ;
        grid.set_margin_start (10) ;

        var saveas_button = new Button.with_label ("Save as") ;
        saveas_button.get_style_context ().add_class (STYLE_CLASS_FLAT) ;
        saveas_button.clicked.connect (saveas) ;
        saveas_button.get_child ().set_halign (Gtk.Align.START) ;

        grid.attach (saveas_button, 0, 0, 1, 1) ;
        grid.show_all () ;

        var popover = new Popover (menuButton) ;
        popover.add (grid) ;

        menuButton.clicked.connect (() => {
            popover.set_visible (true) ;
        }) ;

        leftIcons.pack_start (openButton, false, false, 0) ;
        leftIcons.pack_start (newButton, false, false, 0) ;
        leftIcons.get_style_context ().add_class ("linked") ;

        rightIcons.pack_start (saveButton, false, false, 0) ;
        rightIcons.pack_start (menuButton, false, false, 0) ;
        rightIcons.get_style_context ().add_class ("linked") ;

        header.pack_start (leftIcons) ;
        header.pack_end (rightIcons) ;
    }

    public void saveas() {
        var chooser = new FileChooserDialog ("Save As",
                                             (Window) this.get_toplevel (),
                                             FileChooserAction.SAVE,
                                             "_Cancel",
                                             ResponseType.CANCEL,
                                             "_Save",
                                             ResponseType.ACCEPT) ;
        chooser.select_multiple = false ;
        if( chooser.run () == ResponseType.ACCEPT ){
            file = new SourceFile () ;
            file.location = chooser.get_file () ;
            fileLocation = file.location.get_path () ;
            fileName = file.location.get_basename () ;
            chooser.destroy () ;
            unsaved = false ;
            save () ;
        } else {
            chooser.destroy () ;
            return ;
        }
    }

    public void save() {
        if( unsaved ){
            saveas () ;
            return ;
        }
        var source_file_saver = new SourceFileSaver (buffer, file) ;
        buffer.set_modified (false) ;
        source_file_saver.save_async.begin (Priority.DEFAULT, null, () => {
            var lm = new SourceLanguageManager () ;
            var language = lm.guess_language (file.location.get_path (), null) ;
            if( language != null ){
                buffer.language = language ;
                buffer.highlight_syntax = true ;
            } else {
                buffer.highlight_syntax = false ;
            }
        }) ;
    }

    bool on_open() {
        FileChooserDialog chooser = new FileChooserDialog (
            "Select a file to edit", this, FileChooserAction.OPEN,
            "_Cancel",
            ResponseType.CANCEL,
            "_Open",
            ResponseType.ACCEPT) ;
        chooser.set_select_multiple (false) ;
        if( chooser.run () == ResponseType.ACCEPT ){
            file = new SourceFile () ;
            file.location = chooser.get_file () ;
            fileLocation = file.location.get_path () ;
            fileName = file.location.get_basename () ;
            chooser.destroy () ;
        } else {
            chooser.destroy () ;
            return false ;
        }

        var file_loader = new SourceFileLoader (source_view.buffer as SourceBuffer, file) ;
        file_loader.load_async.begin (Priority.DEFAULT, null, () => {
            var lm = new SourceLanguageManager () ;
            var language = lm.guess_language (file.location.get_path (), null) ;

            if( language != null ){
                buffer.language = language ;
                buffer.highlight_syntax = true ;
            } else {
                buffer.highlight_syntax = false ;
            }
        }) ;

        return true ;
    }

    static int main(string[] args) {
        init (ref args) ;

        var window = new iZiCodeEditor () ;
        window.destroy.connect (main_quit) ;
        window.show_all () ;

        Gtk.main () ;
        return 0 ;
    }

}
