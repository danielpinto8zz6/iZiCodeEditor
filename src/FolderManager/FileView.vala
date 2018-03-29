/*-
 * Copyright (c) 2017 elementary LLC. (https://elementary.io),
 *               2013 Julien Spautz <spautz.julien@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 3
 * as published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Julien Spautz <spautz.julien@gmail.com>, Andrei-Costin Zisu <matzipan@gmail.com>
 */

namespace iZiCodeEditor.FolderManager {

private static GLib.Settings folder_manager_settings;

/**
 * SourceList that displays folders and their contents.
 */
internal class FileView : Granite.Widgets.SourceList {
public signal void select (string file);

// This is a workaround for SourceList silliness: you cannot remove an item
// without it automatically selecting another one.
public bool ignore_next_select { get; set; default = false; }
public string icon_name { get; set; }
public string title { get; set; }

construct {
	width_request = 180;
	icon_name = "folder-symbolic";
	title = "Folders";

	item_selected.connect (on_item_selected);

	folder_manager_settings = new GLib.Settings ("com.github.danielpinto8zz6.iZiCodeEditor.folder-manager");
}

private void on_item_selected (Granite.Widgets.SourceList.Item ? item) {
	// This is a workaround for SourceList silliness: you cannot remove an item
	// without it automatically selecting another one.
	if (ignore_next_select) {
		ignore_next_select = false;
		return;
	}

	if (item is FileItem) {
		select ((item as FileItem).file.path);
	}
}

public void restore_saved_state () {
	string[] opened_folders = folder_manager_settings.get_strv("opened-folders");
	foreach (var path in opened_folders)
		add_folder (new File (path), false);
}

public void open_folder (File folder) {
	if (is_open (folder)) {
		warning ("Folder '%s' is already open.", folder.path);
		return;
	} else if (!folder.is_valid_directory) {
		warning ("Cannot open invalid directory.");
		return;
	}

	add_folder (folder, true);
	write_settings ();
}

private Granite.Widgets.SourceList.Item ? find_path (Granite.Widgets.SourceList.ExpandableItem list, string path) {
	foreach (var item in list.children) {
		if (item is Item) {
			var code_item = item as Item;
			if (code_item.path == path) {
				return item;
			}

			if (item is Granite.Widgets.SourceList.ExpandableItem) {
				var expander = item as Granite.Widgets.SourceList.ExpandableItem;
				if (!expander.expanded || !path.has_prefix (code_item.path)) {
					continue;
				}

				var recurse_item = find_path (expander, path);
				if (recurse_item != null) {
					return recurse_item;
				}
			}
		}
	}

	return null;
}

private void add_folder (File folder, bool expand) {
	if (is_open (folder)) {
		warning ("Folder '%s' is already open.", folder.path);
		return;
	} else if (!folder.is_valid_directory) {
		warning ("Cannot open invalid directory.");
		return;
	}

	var folder_root = new MainFolderItem (folder, this);
	this.root.add (folder_root);

	folder_root.expanded = expand;
	folder_root.closed.connect (() => {
				root.remove (folder_root);
				write_settings ();
			});
}

private bool is_open (File folder) {
	foreach (var child in root.children)
		if (folder.path == (child as Item).path)
			return true;
	return false;
}

private void write_settings () {
	string[] to_save = {};

	foreach (var main_folder in root.children) {
		var saved = false;

		foreach (var saved_folder in to_save) {
			if ((main_folder as Item).path == saved_folder) {
				saved = true;
				break;
			}
		}

		if (!saved) {
			to_save += (main_folder as Item).path;
		}
	}

	folder_manager_settings.set_strv("opened-folders", to_save);
}
}
}
