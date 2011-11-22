namespace Maya.Model {

public class SourceDecorator : Object {
    public E.Source esource { get; set; }
    public bool enabled { get; set; }
}

public class TreeModelSourceGroup : Gtk.TreeModelSort {

    public TreeModelSourceGroup (Gtk.ListStore child) {
        Object (model : child);
    }

    public SourceDecorator get_source_for_iter (Gtk.TreeIter iter_outer) {

        assert(iter_is_valid(iter_outer));

        Gtk.TreeIter iter_inner;
        convert_iter_to_child_iter(out iter_inner, iter_outer);
        assert((model as Gtk.ListStore).iter_is_valid(iter_inner));

        Value v;
        (model as Gtk.ListStore).get_value(iter_inner, 0, out v);

        return (v as SourceDecorator);
    }
}

class SourceSelector: GLib.Object {

    public signal void source_status_changed (E.Source source, bool enabled);

    Gee.MultiMap<E.SourceGroup, E.Source> group_sources; // TODO: possibly unused

    Gee.List<E.SourceGroup> _groups;
    public Gee.List<E.SourceGroup> groups {
        owned get { return _groups.read_only_view; }
    }

    Gee.Map<E.SourceGroup, TreeModelSourceGroup> _group_tree_model;
    public Gee.Map<E.SourceGroup, TreeModelSourceGroup> group_tree_model {
        owned get { return _group_tree_model.read_only_view; }
    }

    public E.SourceGroup? GROUP_LOCAL { get; private set; }
    public E.SourceGroup? GROUP_REMOTE { get; private set; }
    public E.SourceGroup? GROUP_CONTACTS { get; private set; }

    public SourceSelector() {

        bool status;

        E.SourceList source_list;
        status = E.CalClient.get_sources (out source_list, E.CalClientSourceType.EVENTS);
        assert (status==true); // TODO

        GROUP_LOCAL = source_list.peek_group_by_base_uri("local:");
        GROUP_REMOTE = source_list.peek_group_by_base_uri("webcal://");
        GROUP_CONTACTS = source_list.peek_group_by_base_uri("contacts://");

        _groups = new Gee.ArrayList<E.SourceGroup>();
        _groups.add (GROUP_LOCAL);
        _groups.add (GROUP_REMOTE);
        _groups.add (GROUP_CONTACTS);

        group_sources = new Gee.HashMultiMap<E.SourceGroup, E.Source>();
        _group_tree_model = new Gee.HashMap<E.SourceGroup, TreeModelSourceGroup>();

        foreach (E.SourceGroup group in _groups) {

            var list_store = new Gtk.ListStore.newv ( {typeof(SourceDecorator)} );
            var tree_model = new TreeModelSourceGroup (list_store);
            tree_model.set_default_sort_func (tree_model_sort_func);
            _group_tree_model.set (group, tree_model);

            foreach (unowned E.Source esource in group.peek_sources()) {

                var source_copy = esource.copy ();
                group_sources.set(group, source_copy);

                var source = new SourceDecorator();
                source.enabled = true;
                source.esource = esource;

                Gtk.TreeIter iter;
                list_store.append (out iter);
                list_store.set_value (iter, 0, source);
            }
        }
    }

    private static int tree_model_sort_func(Gtk.TreeModel model, Gtk.TreeIter inner_a, Gtk.TreeIter inner_b) {

        Value source_a, source_b;

        (model as Gtk.ListStore).get_value(inner_a, 0, out source_a);
        (model as Gtk.ListStore).get_value(inner_b, 0, out source_b);

        bool valid_a = source_a.holds(typeof(E.Source));
        bool valid_b = source_a.holds(typeof(E.Source));

        if (! valid_a && ! valid_b)
            return 0;
        else if (! valid_a)
            return 1;
        else if (! valid_b)
            return -1;

        var name_a = (source_a as SourceDecorator).esource.peek_name();
        var name_b = (source_b as SourceDecorator).esource.peek_name();
        return name_a.ascii_casecmp(name_b);
    }

    public Gee.Collection<E.Source> get_sources (E.SourceGroup group) {
        return group_sources.get (group);
    }

    public bool get_show_group (E.SourceGroup group) {
        var sources = get_sources (group);
        return sources.size>0;
    }

    public void toggle_source_status (E.SourceGroup group, string path_string) {

        var model = group_tree_model.get (group);

        Gtk.TreeIter iter_outer;
        var path = new Gtk.TreePath.from_string (path_string);

        model.get_iter (out iter_outer, path);

        Gtk.TreeIter iter_inner;
        model.convert_iter_to_child_iter(out iter_inner, iter_outer);

        Value v;
        (model.model as Gtk.ListStore).get_value(iter_inner, 0, out v);

        var source_dec = (v as SourceDecorator);
        source_dec.enabled = ! source_dec.enabled;

        (model.model as Gtk.ListStore).set_value(iter_inner, 0, source_dec);

        source_status_changed (source_dec.esource, source_dec.enabled);
    }

    public void debug () { // XXX: delete me
        foreach (E.SourceGroup group in groups) {
            print ("%s\n", group.peek_name());
            foreach (E.Source source in get_sources(group)) {
                print ("-- %s\n", source.peek_name());
            }
        }
    }

}

}
