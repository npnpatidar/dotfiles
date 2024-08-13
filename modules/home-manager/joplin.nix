{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.home-manager.joplin;

  settings = ''
    {
    	"$schema": "https://joplinapp.org/schema/settings.json",
    	"api.token": "7857edcabbc1b6c7105ce5f6611e1ce746b4bef012627069770e74a6c68e940dd28ae166029a6cca7c3c8c1f280b892058c6493b41f1bf70d97c66249d16fd5b",
    	"spellChecker.languages": [
    		"en-US"
    	],
    	"noteVisiblePanes": [
    		"editor"
    	],
    	"ui.layout": {
    		"key": "root",
    		"children": [
    			{
    				"key": "sideBar",
    				"width": 149,
    				"visible": true
    			},
    			{
    				"key": "noteList",
    				"width": 250,
    				"visible": true
    			},
    			{
    				"key": "editor",
    				"visible": true
    			}
    		],
    		"visible": true
    	},
    	"theme": 6,
    	"themeAutoDetect": true,
    	"preferredLightTheme": 6,
    	"preferredDarkTheme": 6,
    	"style.editor.fontSize": 20,
    	"editor": "/etc/profiles/per-user/${config.globals.default_user}/bin/nvim",
    	"sync.target": 2,
    	"sync.5.path": "https://nch.pl/remote.php/webdav/.joplin",
    	"sync.5.username": "s2nw9rov",
    	"clipperServer.autoStart": true,
    	"locale": "en_US",
    	"timeFormat": "h:mm A",
    	"editor.beta": true,
    	"trackLocation": false,
    	"notes.sortOrder.reverse": true,
    	"notes.perFieldReverse": {
    		"user_updated_time": false,
    		"user_created_time": true,
    		"title": false,
    		"order": false
    	},
    	"notes.sortOrder.field": "user_created_time",
    	"editor.spellcheckBeta": true,
    	"sync.2.path": "${config.globals.data_directory}/nextcloud/.joplin/"
    }



  '';

in
{
  options.modules.home-manager.joplin = {
    enable = mkEnableOption false;
  };

  config = mkIf cfg.enable {

    home.packages = [
      pkgs.joplin
      pkgs.joplin-desktop
    ];
    xdg.configFile."joplin/settings.json".text = settings;
    xdg.configFile."joplin-desktop/settings.json".text = settings;

  };
}
