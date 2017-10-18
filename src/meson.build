vala_sources = [
    'application.vala',
    'search.vala',
    'operations.vala',
    'preferences.vala',
    'tabs.vala',
    'dialogs.vala',
    'notebook.vala',
    'window.vala',
    'toolbar.vala',
    'replace.vala',
    'utils.vala',
    'goto.vala',
    'sourceview.vala',
    'terminal.vala',
    'statusbar.vala'
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
