using Gtk ;

class iZiCodeEditor : Window {

    SourceView source_view ;
    SourceLanguageManager language_manager ;
    SourceFile file ;
    SourceBuffer buffer ;
    string fileName ;
    string fileLocation ;

    iZiCodeEditor () {

        var header = new HeaderBar () ;
        header.set_show_close_button (true) ;
        header.set_title ("iZiCodeEditor") ;

        this.window_position = WindowPosition.CENTER ;
        set_default_size (800, 500) ;
        set_titlebar (header) ;

        var leftIcons = new Box (Orientation.HORIZONTAL, 0) ;
        var rightIcons = new Box (Orientation.HORIZONTAL, 0) ;

        var openButton = new Button.from_icon_name ("document-open-symbolic", IconSize.BUTTON) ;
        openButton.clicked.connect (on_open) ;

        var newButton = new Button.from_icon_name ("tab-new-symbolic", IconSize.BUTTON) ;
        newButton.clicked.connect (() => {
            header.set_title (fileName) ;
            header.set_subtitle (fileLocation) ;
        }) ;

        var saveButton = new Button.from_icon_name ("document-save-symbolic", IconSize.BUTTON) ;

        var menuButton = new Button.from_icon_name ("open-menu-symbolic", IconSize.BUTTON) ;

        leftIcons.pack_start (openButton, false, false, 0) ;
        leftIcons.pack_start (newButton, false, false, 0) ;
        leftIcons.get_style_context ().add_class ("linked") ;

        rightIcons.pack_start (saveButton, false, false, 0) ;
        rightIcons.pack_start (menuButton, false, false, 0) ;
        rightIcons.get_style_context ().add_class ("linked") ;

        header.pack_start (leftIcons) ;
        header.pack_end (rightIcons) ;

        var notebook = new Notebook () ;
        this.add (notebook) ;

        buffer = new SourceBuffer (null) ;
        source_view = new SourceView.with_buffer (buffer) ;
        source_view.wrap_mode = WrapMode.NONE ;
        source_view.indent = 2 ;
        source_view.monospace = true ;
        source_view.buffer.text = "" ;
        source_view.auto_indent = true ;
        source_view.indent_on_tab = true ;
        source_view.show_line_numbers = true ;
        source_view.highlight_current_line = true ;
        source_view.smart_home_end = SourceSmartHomeEndType.BEFORE ;
        source_view.auto_indent = true ;
        source_view.show_right_margin = false ;
        buffer.set_style_scheme (SourceStyleSchemeManager.get_default ().get_scheme ("classic")) ;
        buffer.highlight_syntax = true ;
        language_manager = SourceLanguageManager.get_default () ;

        var scrolled_window = new ScrolledWindow (null, null) ;
        scrolled_window.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC) ;
        scrolled_window.add (source_view) ;

        var vbox = new Box (Orientation.VERTICAL, 0) ;
        vbox.pack_start (scrolled_window, true, true, 0) ;

        var label = new Label (null) ;
        label.set_label ("Example") ;
        notebook.append_page (vbox, label) ;
    }

    void on_open() {
        FileChooserDialog chooser = new FileChooserDialog (
            "Select a file to edit", this, FileChooserAction.OPEN,
            "_Cancel",
            ResponseType.CANCEL,
            "_Open",
            ResponseType.ACCEPT) ;
        chooser.set_select_multiple (false) ;
        chooser.run () ;
        chooser.close () ;

        if( chooser.get_file () != null ){
            file = new SourceFile () ;
            file.location = chooser.get_file () ;

            fileLocation = file.location.get_path () ;
            fileName = file.location.get_basename () ;

            var lm = new SourceLanguageManager () ;
            var language = lm.guess_language (file.location.get_path (), null) ;

            if( language != null ){
                buffer.language = language ;
                buffer.highlight_syntax = true ;
            } else {
                buffer.highlight_syntax = false ;
            }

            var file_loader = new SourceFileLoader (source_view.buffer as SourceBuffer, file) ;
            try {
                file_loader.load_async.begin (Priority.DEFAULT, null, null) ;
            } catch ( Error e ){
                stderr.printf ("Error: %s\n", e.message) ;
            }
        }
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
