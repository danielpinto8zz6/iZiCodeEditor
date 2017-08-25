namespace iZiCodeEditor{
    private int width ;
    private int height ;
    private bool maximized ;

    private string font ;
    private string scheme ;
    private uint margin_pos ;
    private int indent_size ;
    private uint tab_size ;

    private bool numbers_show ;
    private bool highlight ;
    private bool margin_show ;
    private bool spaces ;
    private bool auto_indent ;
    private bool pattern_show ;
    private bool darktheme ;

    private string[] recent_files ;

    private uint active_tab ;

    private GLib.Settings settings ;

    public class Settings : GLib.Object {
        public void get_all() {
            settings = new GLib.Settings ("com.github.danielpinto8zz6.iZiCodeEditor") ;
            get_width () ;
            get_height () ;
            get_maximized () ;
            get_font () ;
            get_scheme () ;
            get_margin_pos () ;
            get_indent_size () ;
            get_tab_size () ;
            get_numbers_show () ;
            get_highlight () ;
            get_margin_show () ;
            get_spaces () ;
            get_auto_indent () ;
            get_pattern_show () ;
            get_recent_files () ;
            get_active_tab () ;
            get_darktheme () ;
        }

        // settings get
        public int get_width() {
            return width = settings.get_int ("width") ;
        }

        public int get_height() {
            return height = settings.get_int ("height") ;
        }

        public bool get_maximized() {
            return maximized = settings.get_boolean ("maximized") ;
        }

        public string get_font() {
            return font = settings.get_string ("font") ;
        }

        public string get_scheme() {
            return scheme = settings.get_string ("scheme") ;
        }

        public uint get_margin_pos() {
            return margin_pos = settings.get_uint ("margin-pos") ;
        }

        public int get_indent_size() {
            return indent_size = settings.get_int ("indent-size") ;
        }

        public uint get_tab_size() {
            return tab_size = settings.get_uint ("tab-size") ;
        }

        public bool get_numbers_show() {
            return numbers_show = settings.get_boolean ("numbers-show") ;
        }

        public bool get_highlight() {
            return highlight = settings.get_boolean ("highlight") ;
        }

        public bool get_margin_show() {
            return margin_show = settings.get_boolean ("margin-show") ;
        }

        public bool get_spaces() {
            return spaces = settings.get_boolean ("spaces") ;
        }

        public bool get_auto_indent() {
            return auto_indent = settings.get_boolean ("auto-indent") ;
        }

        public bool get_pattern_show() {
            return pattern_show = settings.get_boolean ("pattern-show") ;
        }

        public string[] get_recent_files() {
            return recent_files = settings.get_strv ("recent-files") ;
        }

        public uint get_active_tab() {
            return active_tab = settings.get_uint ("active-tab") ;
        }

        public bool get_darktheme() {
            return darktheme = settings.get_boolean ("darktheme") ;
        }

        // settings set
        public void set_width() {
            settings.set_int ("width", width) ;
        }

        public void set_height() {
            settings.set_int ("height", height) ;
        }

        public void set_maximized() {
            settings.set_boolean ("maximized", maximized) ;
        }

        public void set_font() {
            settings.set_string ("font", font) ;
        }

        public void set_scheme() {
            settings.set_string ("scheme", scheme) ;
        }

        public void set_margin_pos() {
            settings.set_uint ("margin-pos", margin_pos) ;
        }

        public void set_indent_size() {
            settings.set_int ("indent-size", indent_size) ;
        }

        public void set_tab_size() {
            settings.set_uint ("tab-size", tab_size) ;
        }

        public void set_numbers_show() {
            settings.set_boolean ("numbers-show", numbers_show) ;
        }

        public void set_highlight() {
            settings.set_boolean ("highlight", highlight) ;
        }

        public void set_margin_show() {
            settings.set_boolean ("margin-show", margin_show) ;
        }

        public void set_spaces() {
            settings.set_boolean ("spaces", spaces) ;
        }

        public void set_auto_indent() {
            settings.set_boolean ("auto-indent", auto_indent) ;
        }

        public void set_pattern_show() {
            settings.set_boolean ("pattern-show", pattern_show) ;
        }

        public void set_recent_files() {
            recent_files = {} ;
            for( int i = 0 ; i < files.length () ; i++ ){
                recent_files += files.nth_data (i) ;
            }
            settings.set_strv ("recent-files", recent_files) ;
        }

        public void set_active_tab() {
            settings.set_uint ("active-tab", active_tab) ;
        }

        public void set_darktheme() {
            settings.set_boolean ("darktheme", darktheme) ;
        }

    }
}
