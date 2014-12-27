// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2011-2015 Maya Developers (http://launchpad.net/maya)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Maxwell Barvian
 *              Corentin Noël <corentin@elementaryos.org>
 */

/**
 * Represents a single event on the grid.
 */
public class Maya.View.EventButton : Gtk.Revealer {
    public signal void edition_request ();
    public E.CalComponent comp {get; private set;}
    private Gtk.EventBox event_box;
    private Gtk.Grid internal_grid;
    Gtk.Label label;

    public EventButton (E.CalComponent comp) {
        this.comp = comp;
        transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        internal_grid = new Gtk.Grid ();
        internal_grid.column_spacing = 6;
        event_box = new Gtk.EventBox ();
        var fake_label = new Gtk.Label (" ");
        event_box.add (fake_label);
        event_box.set_size_request (4, 2);

        event_box.scroll_event.connect ((event) => {return GesturesUtils.on_scroll_event (event);});
        internal_grid.attach (event_box, 0, 0, 1, 1);
        event_box.show ();
        var event_box = new Gtk.EventBox ();
        event_box.events |= Gdk.EventMask.BUTTON_PRESS_MASK;
        event_box.events |= Gdk.EventMask.SCROLL_MASK;
        event_box.events |= Gdk.EventMask.SMOOTH_SCROLL_MASK;
        event_box.add (internal_grid);
        event_box.button_press_event.connect ((event) => {
            if (event.type == Gdk.EventType.2BUTTON_PRESS && event.button == Gdk.BUTTON_PRIMARY) {
                E.Source src = comp.get_data ("source");
                if (src.writable == true && Model.CalendarModel.get_default ().calclient_is_readonly (src) == false) {
                    edition_request ();
                    return true;
                }
            }

            return false;
        });

        add (event_box);
        label = new Gtk.Label(get_summary ());
        label.set_ellipsize(Pango.EllipsizeMode.END);
        internal_grid.attach (label, 1, 0, 1, 1);
        label.hexpand = true;
        label.wrap = false;
        label.xalign = 0;
        label.show ();
    }

    public string get_summary () {
        E.CalComponentText ct;
        comp.get_summary (out ct);
        return ct.value;
    }

    public void set_color (string color) {
        var rgba = Gdk.RGBA();
        rgba.parse (color);
        event_box.override_background_color (Gtk.StateFlags.NORMAL, rgba);
    }

    /**
     * Compares the given buttons according to date.
     */
    public static GLib.CompareDataFunc<Maya.View.EventButton>? compare_buttons = (button1, button2) => {
        var comp1 = button1.comp;
        var comp2 = button2.comp;

        return Util.compare_events (comp1, comp2);
    };

}
