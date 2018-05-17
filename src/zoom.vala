namespace EasyCode {
  public class Zoom {
    private static int FONT_SIZE_MAX = 72;
    private static int FONT_SIZE_MIN = 7;

    public static void handle_zoom (Gdk.ScrollDirection direction) {
      string font = get_current_font ();
      int font_size = (int)get_current_font_size ();

      if (direction == Gdk.ScrollDirection.DOWN) {
        font_size--;
        if (font_size < FONT_SIZE_MIN) {
          return;
        }
      } else if (direction == Gdk.ScrollDirection.UP) {
        font_size++;
        if (font_size > FONT_SIZE_MAX) {
          return;
        }
      }

      string new_font = font + " " + font_size.to_string ();
      set_font (new_font);
    }

    private static void set_font (string font) {
      Application.settings_fonts_colors.set_string ("font", font);
    }

    private static string get_current_font () {
      string font = Application.settings_fonts_colors.get_string ("font");
      string font_family = font.substring (0, font.last_index_of (" "));
      return font_family;
    }

    public static double get_current_font_size () {
      string font = Application.settings_fonts_colors.get_string ("font");
      string font_size = font.substring (font.last_index_of (" ") + 1);
      return double.parse (font_size);
    }

    private static string get_default_font () {
      string font = Application.settings_fonts_colors.get_string ("font");
      string font_family = font.substring (0, font.last_index_of (" "));
      return font_family;
    }

    public static void set_default_zoom () {
      Application.settings_fonts_colors.set_string ("font", get_default_font () + " 14");
    }

    public static int get_default_zoom () {
      return (int)((get_current_font_size () - 4) * 10);
    }
  }
}