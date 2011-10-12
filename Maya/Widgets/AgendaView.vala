//
//  Copyright (C) 2011 Maxwell Barvian
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

using Gtk;
using Gdk;

namespace Maya.Widgets {

    /**
     * The AgendaView shows all events for the currently selected date,
     * even with fancy colors!
     */
	public class AgendaView : Gtk.VBox {

		private MayaWindow window;

		public AgendaView (MayaWindow window) {

			this.window = window;

			// VBox properties
			spacing = 0;
			homogeneous = false;
		}

	}

}

