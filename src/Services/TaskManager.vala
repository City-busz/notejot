/*
* Copyright (c) 2018-2020 Lains
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

namespace Notejot {
    public class Services.TaskManager {
        public MainWindow win;
        public Json.Builder builder;
        private string file_name = Environment.get_user_cache_dir () +
                                 "/com.github.lainsce.notejot" +
                                 "/saved_notes.json";

        public TaskManager (MainWindow win) {
            this.win = win;
        }

        public void save_notes() {
            string json_string = prepare_json_from_notes();
            var file = File.new_for_path (file_name);
            try {
                if (file.query_exists ()) {
                    file.delete ();
                }
                var file_stream = file.create (
                                        FileCreateFlags.REPLACE_DESTINATION
                                        );
                var data_stream = new DataOutputStream (file_stream);
                data_stream.put_string(json_string);
            } catch (Error e) {
                warning ("Failed to save timetable: %s\n", e.message);
            }

        }

        private string prepare_json_from_notes () {
            builder = new Json.Builder ();

            builder.begin_array ();
            save_column (builder, win.column);
            builder.end_array ();

            Json.Generator generator = new Json.Generator ();
            Json.Node root = builder.get_root ();
            generator.set_root (root);
            string str = generator.to_data (null);
            return str;
        }

        private static void save_column (Json.Builder builder,
                                         Widgets.Column column) {
	        builder.begin_array ();
	        foreach (var task in column.get_tasks ()) {
                builder.begin_array ();
                builder.add_string_value (task.title);
		        builder.add_string_value (task.contents);
                builder.add_string_value (task.color);
                builder.end_array ();
	        }
	        builder.end_array ();
        }

        public void load_from_file () {
            try {
                var file = File.new_for_path(file_name);
                var json_string = "";
                if (file.query_exists()) {
                    string line;
                    var dis = new DataInputStream (file.read ());
                    while ((line = dis.read_line (null)) != null) {
                        json_string += line;
                    }
                    var parser = new Json.Parser();
                    parser.load_from_data(json_string);
                    var root = parser.get_root();
                    var array = root.get_array();
                    var columns = array.get_array_element (0);
                    foreach (var tasks in columns.get_elements()) {
                        var task = tasks.get_array ();
                        string title = task.get_string_element(0);
                        string contents = task.get_string_element(1);
                        string color = task.get_string_element(2);

                        win.column.add_task (title, contents, color);
                    }
                }
            } catch (Error e) {
                warning ("Failed to load file: %s\n", e.message);
            }
        }
    }
}

