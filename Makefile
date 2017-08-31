SCHEMA_PATH=/usr/share/glib-2.0/schemas/

APP_FILES = src/application.vala \
	src/tabs.vala \
	src/apply.vala \
	src/notebook.vala \
	src/preferences.vala \
	src/window.vala \
	src/dialogs.vala \
	src/operations.vala \
	src/search.vala \
	src/settings.vala \
        src/toolbar.vala \
        src/replace.vala

LIB_FILES = src/PluginsManager.vala

PLUGINS_FILES = terminal.vala

all: Lib App Plugin Schema

Lib:
	valac -o libiZiCodeEditor.so --library iZiCodeEditor -H iZiCodeEditor.h  --gir iZiCodeEditor-1.0.gir  -X -shared -X -fPIC --pkg libpeas-1.0 --pkg gtk+-3.0 $(LIB_FILES) 


App:
	valac -o iZiCodeEditor $(APP_FILES) --vapidir . --pkg gtk+-3.0 --pkg iZiCodeEditor --pkg gtksourceview-3.0 -X -I. -X -L. -X -liZiCodeEditor


Plugin:
	valac -o libterminal.so --library terminal $(PLUGINS_FILES)  -X -shared -X -fPIC --vapidir . --pkg libpeas-1.0 --pkg gtk+-3.0 --pkg iZiCodeEditor --pkg vte-2.91 -X -I. -X -L. -X -liZiCodeEditor

Schema:
	cp data/com.github.danielpinto8zz6.iZiCodeEditor.gschema.xml $(SCHEMA_PATH) 
	glib-compile-schemas $(SCHEMA_PATH)

clean:
	rm -rf *.vapi *.h *.so *.gir iZiCodeEditor
