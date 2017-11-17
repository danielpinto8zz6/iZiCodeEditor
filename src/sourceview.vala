namespace iZiCodeEditor{
    public class SourceView : Gtk.SourceView {
        public unowned ApplicationWindow window { get ; construct set ; }

        private const Gtk.TargetEntry[] targets = { { "text/uri-list", 0, 0 } } ;
        public new Gtk.SourceBuffer buffer ;
        Gee.HashMap<string, string> brackets ;
        Gee.HashMap<uint, string> keys ;
        const string[] valid_next_chars = {
            "", " ", "\b", "\r", "\n", "\t", ",", ".", ";", ":"
        } ;
        private const uint SELECTION_CHANGED_PAUSE = 400 ;

        public signal void selection_changed(Gtk.TextIter start_iter, Gtk.TextIter end_iter) ;
        public signal void deselected() ;

        private uint selection_changed_timer = 0 ;
        private Gtk.TextIter last_select_start_iter ;
        private Gtk.TextIter last_select_end_iter ;

        private const uint SELECTION_HIGHLIGHT_MAX_CHARS = 45 ;

        Gee.TreeSet<iZiCodeEditor.SourceView> source_views ;
        Gee.HashMap<iZiCodeEditor.SourceView, Gtk.SourceSearchContext> search_contexts ;
        iZiCodeEditor.SourceView current_source ;

        public SourceView (iZiCodeEditor.ApplicationWindow window) {
            Object (
                window: window,
                cursor_visible: true,
                left_margin: 10,
                smart_backspace: true) ;
        }

        construct {
            var provider = new Gtk.CssProvider () ;
            try {
                provider.load_from_data (pango_font_description_to_css (Application.settings_fonts_colors.get_string ("font")), pango_font_description_to_css (Application.settings_fonts_colors.get_string ("font")).length) ;
            } catch ( Error e ){
                stderr.printf ("Error: %s\n", e.message) ;
            }
            get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION) ;

            Application.settings_fonts_colors.changed["font"].connect (() => {
                try {
                    provider.load_from_data (pango_font_description_to_css (Application.settings_fonts_colors.get_string ("font")), pango_font_description_to_css (Application.settings_fonts_colors.get_string ("font")).length) ;
                } catch ( Error e ){
                    stderr.printf ("Error: %s\n", e.message) ;
                }
                get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION) ;
            }) ;

            Application.settings_editor.bind ("tab-size", this, "tab_width", SettingsBindFlags.DEFAULT) ;
            Application.settings_editor.bind ("indent-size", this, "indent_width", SettingsBindFlags.DEFAULT) ;
            Application.settings_view.bind ("margin-pos", this, "right_margin_position", SettingsBindFlags.DEFAULT) ;
            Application.settings_view.bind ("numbers-show", this, "show_line_numbers", SettingsBindFlags.DEFAULT) ;
            Application.settings_editor.bind ("highlight-current-line", this, "highlight_current_line", SettingsBindFlags.DEFAULT) ;
            Application.settings_view.bind ("margin-show", this, "show_right_margin", SettingsBindFlags.DEFAULT) ;
            Application.settings_editor.bind ("spaces-instead-of-tabs", this, "insert_spaces_instead_of_tabs", SettingsBindFlags.DEFAULT) ;
            Application.settings_editor.bind ("auto-indent", this, "auto_indent", SettingsBindFlags.DEFAULT) ;
            if( Application.settings_view.get_boolean ("pattern-show")){
                set_background_pattern (Gtk.SourceBackgroundPatternType.GRID) ;
            } else {
                set_background_pattern (Gtk.SourceBackgroundPatternType.NONE) ;
            }
            Application.settings_view.changed["pattern-show"].connect (() => {
                if( Application.settings_view.get_boolean ("pattern-show")){
                    background_pattern = Gtk.SourceBackgroundPatternType.GRID ;
                } else {
                    background_pattern = Gtk.SourceBackgroundPatternType.NONE ;
                }
            }) ;

            if( Application.settings_view.get_boolean ("text-wrap")){
                set_wrap_mode (Gtk.WrapMode.WORD) ;
            } else {
                set_wrap_mode (Gtk.WrapMode.NONE) ;
            }
            Application.settings_view.changed["pattern-show"].connect (() => {
                if( Application.settings_view.get_boolean ("text-wrap")){
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

            buffer.mark_set.connect (on_mark_set) ;

            //// drag and drop
            Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, targets, Gdk.DragAction.COPY) ;

            if( this != null ){
                key_press_event.disconnect (on_key_press) ;
                backspace.disconnect (on_backspace) ;
            }

            key_press_event.connect (on_key_press) ;
            backspace.connect (on_backspace) ;

            this.source_views = new Gee.TreeSet<iZiCodeEditor.SourceView> () ;
            this.search_contexts = new Gee.HashMap<iZiCodeEditor.SourceView, Gtk.SourceSearchContext> () ;

            var src = this ;
            src.deselected.disconnect (on_deselection) ;
            src.deselected.connect (on_deselection) ;
            src.selection_changed.disconnect (on_selection_changed) ;
            src.selection_changed.connect (on_selection_changed) ;
            this.source_views.add (src) ;
            this.search_contexts.set (src, new Gtk.SourceSearchContext (src.buffer, null)) ;
            this.current_source = src ;

            buffer.notify["cursor-position"].connect (() => {
                window.status_bar.update_statusbar_line (buffer) ;
            }) ;

            scroll_event.connect ((event) => {
                if((Gdk.ModifierType.CONTROL_MASK in event.state) && event.delta_y < 0 ){
                    window.operations.zooming (Gdk.ScrollDirection.DOWN) ;
                    return true ;
                } else if((Gdk.ModifierType.CONTROL_MASK in event.state) && event.delta_y > 0 ){
                    window.operations.zooming (Gdk.ScrollDirection.UP) ;
                    return true ;
                }
                return false ;
            }) ;
        }

        public void on_selection_changed(Gtk.TextIter start, Gtk.TextIter end) {
            if( this.current_source.buffer.get_has_selection ()){

                string selected_text = this.current_source.buffer.get_text (start, end, false) ;
                if( selected_text.length > SELECTION_HIGHLIGHT_MAX_CHARS ){
                    return ;
                }

                var context = search_contexts.get (this.current_source) ;
                context.settings.search_text = selected_text ;
                context.set_highlight (true) ;
            }
        }

        public void on_deselection() {
            var context = search_contexts.get (this.current_source) ;
            context.settings.search_text = null ;
            context.set_highlight (false) ;
        }

        void on_mark_set(Gtk.TextIter loc, Gtk.TextMark mar) {

            // Weed out user movement for text selection changes
            Gtk.TextIter start, end ;
            buffer.get_selection_bounds (out start, out end) ;

            if( start == last_select_start_iter && end == last_select_end_iter ){
                return ;
            }

            if( selection_changed_timer != 0 && MainContext.get_thread_default ().find_source_by_id (selection_changed_timer) != null ){
                Source.remove (selection_changed_timer) ;
            }

            // Fire deselected immediatly
            if( !buffer.get_has_selection ()){
                deselected () ;
                // Don't fire signal till we think select movement is done
            } else {
                selection_changed_timer = Timeout.add (SELECTION_CHANGED_PAUSE, selection_changed_event) ;
            }

        }

        bool selection_changed_event() {
            Gtk.TextIter start, end ;
            bool selected = buffer.get_selection_bounds (out start, out end) ;
            if( selected ){
                selection_changed (start, end) ;
            } else {
                deselected () ;
            }

            return false ;
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
            if( Application.settings_editor.get_boolean ("brackets-completion")){
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
            if( Application.settings_editor.get_boolean ("brackets-completion")){
                if( keys.has_key (event.keyval) &&
                    !(Gdk.ModifierType.MOD1_MASK in event.state) &&
                    !(Gdk.ModifierType.CONTROL_MASK in event.state)){
                    string bracket = keys[event.keyval] ;
                    string next_char = get_next_char () ;

                    if( brackets.has_key (bracket) &&
                        (buffer.has_selection || has_valid_next_char (next_char))){
                        complete_brackets (bracket) ;
                        return true ;
                    } else if( bracket in brackets.values && next_char == bracket ){
                        skip_char () ;
                        return true ;
                    }
                }
            }
            return false ;
        }

        public string pango_font_description_to_css(string font) {
            StringBuilder str = new StringBuilder () ;

            Pango.FontDescription desc = Pango.FontDescription.from_string (font) ;
            var family = desc.get_family () ;
            var weight = desc.get_weight () ;
            var style = desc.get_style () ;
            var variant = desc.get_variant () ;

            str.append_printf (" * {\n") ;
            str.append_printf (" font-size: %dpx;\n", desc.get_size () / Pango.SCALE) ;
            str.append_printf (" font-style: %s;\n", (style == Pango.Style.ITALIC) ? "italic" : ((style == Pango.Style.OBLIQUE) ? "oblique" : "normal")) ;
            str.append_printf (" font-variant: %s;\n", (variant == Pango.Variant.SMALL_CAPS) ? "small-caps" : "normal") ;
            str.append_printf (" font-weight: %s;\n", (weight <= Pango.Weight.SEMILIGHT) ? "light" : (weight >= Pango.Weight.SEMIBOLD ? "bold" : "normal")) ;
            str.append_printf (" font-family: %s;\n", family) ;
            str.append_printf ("}\n") ;
            var css = str.str ;
            return css ;
        }

    }
}
