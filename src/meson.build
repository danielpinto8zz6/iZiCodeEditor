vala_sources = [
    'application.vala',
    'dialogs.vala',
    'goto.vala',
    'headerbar.vala',
    'notebook.vala',
    'operations.vala',
    'preferences.vala',
    'replace.vala',
    'search.vala',
    'sourceview.vala',
    'statusbar.vala',
    'tabs.vala',
    'terminal.vala',
    'window.vala'
]

vala_args = [
    '--pkg=gtk+-3.0',
    '--pkg=gtksourceview-3.0',
    '--pkg=gee-0.8',
    '--pkg=vte-2.91'
]

iZiCodeEditor = executable('iZiCodeEditor',
                     vala_sources,
                     vala_args: vala_args,
                     install: true,
                     dependencies : [gtk, sourceview, gee, vte])
