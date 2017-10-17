namespace iZiCodeEditor{
    public class SourceView : Gtk.SourceView {

        private const Gtk.TargetEntry[] targets = { { "text/uri-list", 0, 0 } } ;
        public new Gtk.SourceBuffer buffer ;
        Gee.HashMap<string, string> brackets ;
        Gee.HashMap<uint, string> keys ;
        const string[] valid_next_chars = {
            "", " ", "\b", "\r", "\n", "\t", ",", ".", ";", ":"
        } ;

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

            brackets = new Gee.HashMap<string, string> () ;
            brackets["("] = ")" ;
            brackets["["] = "]" ;
            brackets["{"] = "}" ;
            brackets["'"] = "'" ;
            brackets["\""] = "\"" ;
            brackets["`"] = "`" ;

            keys = new Gee.HashMap<uint, string> () ;
            keys[Gdk.Key.braceleft] = "{" ;
            keys[Gdk.Key.bracketleft] = "[" ;
            keys[Gdk.Key.parenleft] = "(" ;
            keys[Gdk.Key.braceright] = "}" ;
            keys[Gdk.Key.bracketright] = "]" ;
            keys[Gdk.Key.parenright] = ")" ;
            keys[Gdk.Key.quoteright] = "'" ;
            keys[Gdk.Key.quotedbl] = "\"" ;
            keys[Gdk.Key.grave] = "`" ;

            // style scheme
            buffer = (Gtk.SourceBuffer) this.get_buffer () ;
            buffer.set_style_scheme (Gtk.SourceStyleSchemeManager.get_default ().get_scheme (Application.settings.get_string ("color-scheme"))) ;
            Application.settings.changed["color-scheme"].connect (() => {
                buffer.set_style_scheme (Gtk.SourceStyleSchemeManager.get_default ().get_scheme (Application.settings.get_string ("color-scheme"))) ;
            }) ;

            Application.settings.bind ("highlight-matching-brackets", buffer, "highlight_matching_brackets", SettingsBindFlags.DEFAULT) ;

            //// drag and drop
            Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, targets, Gdk.DragAction.COPY) ;

            if( this != null ){
                key_press_event.disconnect (on_key_press) ;
                backspace.disconnect (on_backspace) ;
            }

            key_press_event.connect (on_key_press) ;
            backspace.connect (on_backspace) ;

        }

        string get_next_char() {
            Gtk.TextIter start, end ;

            buffer.get_selection_bounds (out start, out end) ;
            end.forward_char () ;

            return buffer.get_text (start, end, true) ;
        }

        string get_previous_char() {
            Gtk.TextIter start, end ;

            buffer.get_selection_bounds (out start, out end) ;
            start.backward_char () ;

            return buffer.get_text (start, end, true) ;
        }

        void on_backspace() {
            if( !buffer.has_selection ){
                string left_char = get_previous_char () ;
                string right_char = get_next_char () ;

                if( brackets.has_key (left_char) && right_char in brackets.values ){
                    Gtk.TextIter start, end ;

                    buffer.get_selection_bounds (out start, out end) ;
                    start.backward_char () ;
                    end.forward_char () ;
                    buffer.select_range (start, end) ;
                }
            }
        }

        void complete_brackets(string opening_bracket) {
            Gtk.TextIter start, end ;
            buffer.get_selection_bounds (out start, out end) ;

            string current_selection = buffer.get_text (start, end, true) ;
            string closing_bracket = brackets[opening_bracket] ;
            string text = opening_bracket + current_selection + closing_bracket ;

            buffer.begin_user_action () ;

            buffer.delete (ref start, ref end) ;
            buffer.insert (ref start, text, text.length) ;

            buffer.get_selection_bounds (out start, out end) ;
            end.backward_char () ;
            start.backward_chars (current_selection.length + 1) ;
            buffer.select_range (start, end) ;

            buffer.end_user_action () ;
        }

        void skip_char() {
            Gtk.TextIter start, end ;

            buffer.get_selection_bounds (out start, out end) ;
            end.forward_char () ;
            buffer.place_cursor (end) ;
        }

        bool has_valid_next_char(string next_char) {
            return next_char in valid_next_chars ||
                   next_char in brackets.values ||
                   brackets.has_key (next_char) ;
        }

        bool on_key_press(Gdk.EventKey event) {
            if( keys.has_key (event.keyval) &&
                !(Gdk.ModifierType.MOD1_MASK in event.state) &&
                !(Gdk.ModifierType.CONTROL_MASK in event.state) ){

                string bracket = keys[event.keyval] ;
                string next_char = get_next_char () ;

                if( brackets.has_key (bracket) &&
                    (buffer.has_selection || has_valid_next_char (next_char)) ){
                    complete_brackets (bracket) ;
                    return true ;
                } else if( bracket in brackets.values && next_char == bracket ){
                    skip_char () ;
                    return true ;
                }
            }

            return false ;
        }

    }
}
