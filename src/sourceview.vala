namespace iZiCodeEditor{
    public class SourceView : Gtk.SourceView {

        private const Gtk.TargetEntry[] targets = { { "text/uri-list", 0, 0 } } ;
        public new Gtk.SourceBuffer buffer ;
        Gee.HashMap<string, string> brackets ;
        Gee.TreeSet<Gtk.TextBuffer> buffers ;
        string last_inserted ;

        construct {

            override_font (Pango.FontDescription.from_string (Application.settings.get_string ("font"))) ;
            Application.settings.changed["font"].connect (() => {
                override_font (Pango.FontDescription.from_string (Application.settings.get_string ("font"))) ;
            }) ;

            Application.settings.bind ("tab-size", this, "tab_width", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("indent-size", this, "indent_width", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("margin-pos", this, "right_margin_position", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("numbers-show", this, "show_line_numbers", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("highlight-current-line", this, "highlight_current_line", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("margin-show", this, "show_right_margin", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("spaces-instead-of-tabs", this, "insert_spaces_instead_of_tabs", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("auto-indent", this, "auto_indent", SettingsBindFlags.DEFAULT) ;
            if( Application.settings.get_boolean ("pattern-show") ){
                set_background_pattern (Gtk.SourceBackgroundPatternType.GRID) ;
            } else {
                set_background_pattern (Gtk.SourceBackgroundPatternType.NONE) ;
            }
            Application.settings.changed["pattern-show"].connect (() => {
                if( Application.settings.get_boolean ("pattern-show") ){
                    background_pattern = Gtk.SourceBackgroundPatternType.GRID ;
                } else {
                    background_pattern = Gtk.SourceBackgroundPatternType.NONE ;
                }
            }) ;
            // default
            set_cursor_visible (true) ;
            set_left_margin (10) ;
            set_smart_backspace (true) ;

            if( Application.settings.get_boolean ("text-wrap") ){
                set_wrap_mode (Gtk.WrapMode.WORD) ;
            } else {
                set_wrap_mode (Gtk.WrapMode.NONE) ;
            }
            Application.settings.changed["pattern-show"].connect (() => {
                if( Application.settings.get_boolean ("text-wrap") ){
                    set_wrap_mode (Gtk.WrapMode.WORD) ;
                } else {
                    set_wrap_mode (Gtk.WrapMode.NONE) ;
                }
            }) ;

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
            buffer = (Gtk.SourceBuffer) this.get_buffer () ;
            buffer.set_style_scheme (Gtk.SourceStyleSchemeManager.get_default ().get_scheme (Application.settings.get_string ("color-scheme"))) ;
            Application.settings.changed["scheme"].connect (() => {
                buffer.set_style_scheme (Gtk.SourceStyleSchemeManager.get_default ().get_scheme (Application.settings.get_string ("color-scheme"))) ;
            }) ;

            buffer.insert_text.disconnect (on_insert_text) ;
            buffer.insert_text.connect (on_insert_text) ;
            buffers.add (buffer) ;

            Application.settings.bind ("highlight-matching-brackets", buffer, "highlight_matching_brackets", SettingsBindFlags.DEFAULT) ;


            //// drag and drop
            Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, targets, Gdk.DragAction.COPY) ;

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

    }
}
