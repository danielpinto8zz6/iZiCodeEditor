namespace iZiCodeEditor{
    public string pango_font_description_to_css() {
        StringBuilder str = new StringBuilder () ;

        Pango.FontDescription desc = Pango.FontDescription.from_string (Application.settings_fonts_colors.get_string ("font")) ;
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
