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

            override_font (Pango.FontDescription.from_string (Application.settings_fonts_colors.get_string ("font"))) ;
            Application.settings_fonts_colors.changed["font"].connect (() => {
                override_font (Pango.FontDescription.from_string (Application.settings_fonts_colors.get_string ("font"))) ;
            }) ;

            Application.settings_editor.bind ("tab-size", this, "tab_width", SettingsBindFlags.DEFAULT) ;
            Application.settings_editor.bind ("indent-size", this, "indent_width", SettingsBindFlags.DEFAULT) ;
            Application.settings_view.bind ("margin-pos", this, "right_margin_position", SettingsBindFlags.DEFAULT) ;
            Application.settings_view.bind ("numbers-show", this, "show_line_numbers", SettingsBindFlags.DEFAULT) ;
            Application.settings_editor.bind ("highlight-current-line", this, "highlight_current_line", SettingsBindFlags.DEFAULT) ;
            Application.settings_view.bind ("margin-show", this, "show_right_margin", SettingsBindFlags.DEFAULT) ;
            Application.settings_editor.bind ("spaces-instead-of-tabs", this, "insert_spaces_instead_of_tabs", SettingsBindFlags.DEFAULT) ;
            Application.settings_editor.bind ("auto-indent", this, "auto_indent", SettingsBindFlags.DEFAULT) ;
            if( Application.settings_view.get_boolean ("pattern-show") ){
                set_background_pattern (Gtk.SourceBackgroundPatternType.GRID) ;
            } else {
                set_background_pattern (Gtk.SourceBackgroundPatternType.NONE) ;
            }
            Application.settings_view.changed["pattern-show"].connect (() => {
                if( Application.settings_view.get_boolean ("pattern-show") ){
                    background_pattern = Gtk.SourceBackgroundPatternType.GRID ;
                } else {
                    background_pattern = Gtk.SourceBackgroundPatternType.NONE ;
                }
            }) ;
            // default
            set_cursor_visible (true) ;
            set_left_margin (10) ;
            set_smart_backspace (true) ;

            if( Application.settings_view.get_boolean ("text-wrap") ){
                set_wrap_mode (Gtk.WrapMode.WORD) ;
            } else {
                set_wrap_mode (Gtk.WrapMode.NONE) ;
            }
            Application.settings_view.changed["pattern-show"].connect (() => {
                if( Application.settings_view.get_boolean ("text-wrap") ){
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
            buffer.set_style_scheme (Gtk.SourceStyleSchemeManager.get_default ().get_scheme (Application.settings_fonts_colors.get_string ("color-scheme"))) ;
            Application.settings_fonts_colors.changed["color-scheme"].connect (() => {
                buffer.set_style_scheme (Gtk.SourceStyleSchemeManager.get_default ().get_scheme (Application.settings_fonts_colors.get_string ("color-scheme"))) ;
            }) ;

            Application.settings_editor.bind ("highlight-matching-brackets", buffer, "highlight_matching_brackets", SettingsBindFlags.DEFAULT) ;

            //// drag and drop
            Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, targets, Gdk.DragAction.COPY) ;

            if( this != null ){
                key_press_event.disconnect (on_key_press) ;
                backspace.disconnect (on_backspace) ;
            }

            key_press_event.connect (on_key_press) ;
            backspace.connect (on_backspace) ;
            scroll_event.connect (on_scroll_press) ;

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
            if( Application.settings_editor.get_boolean ("brackets-completion") ){
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
            if( Gdk.ModifierType.CONTROL_MASK in event.state ){
                switch( event.keyval ){
                case Gdk.Key.plus:
                    zoom_in () ;
                    return true ;
                case Gdk.Key.minus:
                    zoom_out () ;
                    return true ;
                case 0x30:
                    set_default_zoom () ;
                    return true ;
                }
            } else if( keys.has_key (event.keyval) && !(Gdk.ModifierType.MOD1_MASK in event.state) && Application.settings_editor.get_boolean ("brackets-completion") ){

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

        bool on_scroll_press(Gdk.EventScroll event) {
            if( (Gdk.ModifierType.CONTROL_MASK in event.state) && event.delta_y < 0 ){
                zoom_in () ;
                return true ;
            } else if( (Gdk.ModifierType.CONTROL_MASK in event.state) && event.delta_y > 0 ){
                zoom_out () ;
                return true ;
            }
            return false ;
        }

        public void zoom_in() {
            zooming (Gdk.ScrollDirection.UP) ;
        }

        public void zoom_out() {
            zooming (Gdk.ScrollDirection.DOWN) ;
        }

        public void set_default_zoom() {
            Application.settings_fonts_colors.set_string ("font", get_current_font () + " 14") ;
        }

        private void zooming(Gdk.ScrollDirection direction) {
            string font = get_current_font () ;
            int font_size = (int) get_current_font_size () ;

            if( direction == Gdk.ScrollDirection.DOWN ){
                font_size-- ;
                if( font_size < FONT_SIZE_MIN ){
                    return ;
                }
            } else if( direction == Gdk.ScrollDirection.UP ){
                font_size++ ;
                if( font_size > FONT_SIZE_MAX ){
                    return ;
                }
            }

            string new_font = font + " " + font_size.to_string () ;
            Application.settings_fonts_colors.set_string ("font", new_font) ;
        }

        public string get_current_font() {
            string font = Application.settings_fonts_colors.get_string ("font") ;
            string font_family = font.substring (0, font.last_index_of (" ")) ;
            return font_family ;
        }

        public double get_current_font_size() {
            string font = Application.settings_fonts_colors.get_string ("font") ;
            string font_size = font.substring (font.last_index_of (" ") + 1) ;
            return double.parse (font_size) ;
        }

        public string get_default_font() {
            string font = Application.settings_fonts_colors.get_string ("font") ;
            string font_family = font.substring (0, font.last_index_of (" ")) ;
            return font_family ;
        }

        public double get_default_font_size() {
            string font = Application.settings_fonts_colors.get_string ("font") ;
            string font_size = font.substring (font.last_index_of (" ") + 1) ;
            return double.parse (font_size) ;
        }

    }
}
