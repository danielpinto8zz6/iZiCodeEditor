namespace iZiCodeEditor{
    public class Apply : GLib.Object {
        // 1. Editor
        public void set_font() {
            for( int i = 0 ; i < files.length () ; i++ ){
                var tabs = new iZiCodeEditor.Tabs () ;
                var view = tabs.get_sourceview_at_tab (i) ;
                var provider = new Gtk.CssProvider () ;
                try {
                    provider.load_from_data (pango_font_description_to_css (), pango_font_description_to_css ().length) ;
                } catch ( Error e ){
                    stderr.printf ("Error: %s\n", e.message) ;
                }
                view.get_style_context ().add_provider (provider,
                                                        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION) ;
            }
        }

        public void set_scheme() {
            var style_manager = new Gtk.SourceStyleSchemeManager () ;
            var style_scheme = style_manager.get_scheme (scheme) ;
            for( int i = 0 ; i < files.length () ; i++ ){
                var tabs = new iZiCodeEditor.Tabs () ;
                var view = tabs.get_sourceview_at_tab (i) ;
                var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
                buffer.set_style_scheme (style_scheme) ;
            }
        }

        public void set_margin_pos() {
            for( int i = 0 ; i < files.length () ; i++ ){
                var tabs = new iZiCodeEditor.Tabs () ;
                var view = tabs.get_sourceview_at_tab (i) ;
                view.set_right_margin_position (margin_pos) ;
            }
        }

        public void set_indent_size() {
            for( int i = 0 ; i < files.length () ; i++ ){
                var tabs = new iZiCodeEditor.Tabs () ;
                var view = tabs.get_sourceview_at_tab (i) ;
                view.set_indent_width (indent_size) ;
            }
        }

        public void set_tab_size() {
            for( int i = 0 ; i < files.length () ; i++ ){
                var tabs = new iZiCodeEditor.Tabs () ;
                var view = tabs.get_sourceview_at_tab (i) ;
                view.set_tab_width (tab_size) ;
            }
        }

        // 2. View
        public void set_numbers_show() {
            for( int i = 0 ; i < files.length () ; i++ ){
                var tabs = new iZiCodeEditor.Tabs () ;
                var view = tabs.get_sourceview_at_tab (i) ;
                view.set_show_line_numbers (numbers_show) ;
            }
        }

        public void set_highlight() {
            for( int i = 0 ; i < files.length () ; i++ ){
                var tabs = new iZiCodeEditor.Tabs () ;
                var view = tabs.get_sourceview_at_tab (i) ;
                view.set_highlight_current_line (highlight) ;
            }
        }

        public void set_margin_show() {
            for( int i = 0 ; i < files.length () ; i++ ){
                var tabs = new iZiCodeEditor.Tabs () ;
                var view = tabs.get_sourceview_at_tab (i) ;
                view.set_show_right_margin (margin_show) ;
            }
        }

        public void set_spaces() {
            for( int i = 0 ; i < files.length () ; i++ ){
                var tabs = new iZiCodeEditor.Tabs () ;
                var view = tabs.get_sourceview_at_tab (i) ;
                view.set_insert_spaces_instead_of_tabs (spaces) ;
            }
        }

        public void set_auto_indent() {
            for( int i = 0 ; i < files.length () ; i++ ){
                var tabs = new iZiCodeEditor.Tabs () ;
                var view = tabs.get_sourceview_at_tab (i) ;
                view.set_auto_indent (auto_indent) ;
            }
        }

        public void set_pattern_show() {
            for( int i = 0 ; i < files.length () ; i++ ){
                var tabs = new iZiCodeEditor.Tabs () ;
                var view = tabs.get_sourceview_at_tab (i) ;
                if( pattern_show == true ){
                    view.set_background_pattern (Gtk.SourceBackgroundPatternType.GRID) ;
                } else {
                    view.set_background_pattern (Gtk.SourceBackgroundPatternType.NONE) ;
                }
            }
        }

        public void set_darktheme() {
            if( darktheme == true ){
                Gtk.Settings.get_default ().set_property ("gtk-application-prefer-dark-theme", true) ;
            } else {
                Gtk.Settings.get_default ().set_property ("gtk-application-prefer-dark-theme", false) ;

            }
        }

        public void set_textwrap() {
            for( int i = 0 ; i < files.length () ; i++ ){
                var tabs = new iZiCodeEditor.Tabs () ;
                var view = tabs.get_sourceview_at_tab (i) ;
                if( textwrap == true ){
                    view.set_wrap_mode (Gtk.WrapMode.WORD) ;
                } else {
                    view.set_wrap_mode (Gtk.WrapMode.NONE) ;
                }

            }
        }

    }
}
