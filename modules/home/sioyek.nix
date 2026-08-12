_: {
  flake.homeModules.sioyek =
    { pkgs, config, ... }:
    let
      pythonWithPkgs = pkgs.python3.withPackages (p: [
        p.pymupdf
        p.regex
      ]);
    in
    {
      home = {
        packages = [ pkgs.sioyek ];
        file = {
          ".config/sioyek/scripts/sioyek.py".source = ./../../scripts/sioyek/sioyek.py;
          ".config/sioyek/scripts/embed_annotations_in_file.py".source =
            ./../../scripts/sioyek/embed_annotations_in_file.py;
          ".config/sioyek/scripts/remove_annotation.py".source = ./../../scripts/sioyek/remove_annotation.py;
          ".config/sioyek/scripts/import_annotations.py".source =
            ./../../scripts/sioyek/import_annotations.py;
          ".config/sioyek/prefs_user.config".text = ''
            startup_commands    toggle_custom_color
            super_fast_search 1
            custom_background_color #2e3440
            custom_text_color #eceff4
            page_separator_color #2e3440
            status_bar_color #2e3440
            status_bar_text_color #eceff4
            ui_text_color #eceff4
            ui_selected_text_color #eceff4
            ui_background_color #3b4252
            ui_selected_background_color #4c566a
            background_color #2e3440
            visual_mark_color 0.29803923 0.3372549 0.41568628 0.2
            link_highlight_color #81a1c1
            synctex_highlight_color #bf616a
            new_command _embed_annotations_in_file ${pythonWithPkgs}/bin/python ${config.home.homeDirectory}/.config/sioyek/scripts/embed_annotations_in_file.py %{sioyek_path} %{local_database} %{shared_database} %{file_path}
            new_command _remove_annotations ${pythonWithPkgs}/bin/python ${config.home.homeDirectory}/.config/sioyek/scripts/remove_annotation.py %{sioyek_path} %{local_database} %{shared_database} %{file_path} %{selected_rect}
            new_command _import_annotations ${pythonWithPkgs}/bin/python ${config.home.homeDirectory}/.config/sioyek/scripts/import_annotations.py %{sioyek_path} %{local_database} %{shared_database} %{file_path}
          '';
          ".config/sioyek/keys_user.config".text = ''
            toggle_dark_mode x
            toggle_custom_color c
            zoom_in =
            zoom_out -
            fit_to_page_width w
            goto_page_with_page_number .
            next_page u
            previous_page i
            _embed_annotations_in_file <C-s>
            embed_annotations <C-S>
            _remove_annotations <C-r>
            copy y
          '';
        };
      };
      xdg.desktopEntries."sioyek" = {
        exec = "sioyek --new-window %f";
        icon = "sioyek-icon-linux";
        name = "Sioyek";
        settings.NoDisplay = "false";
      };
    };
}
