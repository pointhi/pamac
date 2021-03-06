/*
 *  pamac-vala
 *
 *  Copyright (C) 2015 Guillaume Benoit <guillaume@manjaro.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a get of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Pamac {

	[GtkTemplate (ui = "/org/manjaro/pamac/preferences/choose_ignorepkgs_dialog.ui")]
	public class ChooseIgnorepkgsDialog : Gtk.Dialog {

		[GtkChild]
		public Gtk.Label label;
		[GtkChild]
		public Gtk.TreeView treeview;
		[GtkChild]
		public Gtk.CellRendererToggle renderertoggle;

		public Gtk.ListStore pkgs_list;

		Transaction transaction;

		public ChooseIgnorepkgsDialog (Gtk.Window window, Transaction transaction) {
			Object (transient_for: window, use_header_bar: 0);

			this.transaction = transaction;

			label.set_markup ("<b>%s</b>".printf (dgettext (null, "Choose the packages you do not want to upgrade")));
			pkgs_list = new Gtk.ListStore (2, typeof (bool), typeof (string));
			treeview.set_model (pkgs_list);
			transaction.get_installed_pkgs.begin ((obj, res) => {
				Pamac.Package[] pkgs = transaction.get_installed_pkgs.end (res);
				Gtk.TreeIter iter;
				string[] already_ignorepkgs = transaction.get_ignorepkgs ();
				foreach (var pkg in pkgs) {
					if (pkg.name in already_ignorepkgs) {
						pkgs_list.insert_with_values (out iter, -1, 0, true, 1, pkg.name);
					} else {
						pkgs_list.insert_with_values (out iter, -1, 0, false, 1, pkg.name);
					}
				}
			});
		}

		[GtkCallback]
		void on_renderertoggle_toggled (string path) {
			Gtk.TreeIter iter;
			GLib.Value val;
			bool selected;
			if (pkgs_list.get_iter_from_string (out iter, path)) {;
				pkgs_list.get_value (iter, 0, out val);
				selected = val.get_boolean ();
				pkgs_list.set_value (iter, 0, !selected);
			}
		}
	}
}
