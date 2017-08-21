all:
	valac *.vala --pkg gtk+-3.0 --pkg gtksourceview-3.0 -o iZiCodeEditor

clean:
	rm -rf *.o app1

install:
	cp -f iZiCodeEditor /usr/bin

uninstall:
	rm -f /usr/bin/iZiCodeEditor
