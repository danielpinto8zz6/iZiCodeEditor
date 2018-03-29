vala_sources = [
    'application.vala',
    'goto.vala',
    'headerbar.vala',
    'notebook.vala',
    'preferences.vala',
    'replace.vala',
    'search.vala',
    'sourceview.vala',
    'statusbar.vala',
    'terminal.vala',
    'window.vala',
    'document.vala',
    'FolderManager/File.vala',
    'FolderManager/FileItem.vala',
    'FolderManager/FileView.vala',
    'FolderManager/FolderItem.vala',
    'FolderManager/Item.vala',
    'FolderManager/MainFolderItem.vala',
    'project_browser.vala'
]

vala_args = [
    '--pkg=gtk+-3.0',
    '--pkg=gtksourceview-3.0',
    '--pkg=gee-0.8',
    '--pkg=vte-2.91',
    '--enable-checking',
]

iZiCodeEditor = executable('iZiCodeEditor',
                     vala_sources,
                     vala_args: vala_args,
                     install: true,
                     dependencies : [gtk, sourceview, gee, vte, granite])
