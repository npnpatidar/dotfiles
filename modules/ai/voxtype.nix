{ lib, ... }:
{
  flake.homeModules.voxtype = { pkgs, ... }: with lib;
    {

      services.voxtype = {
        enable = true;
        package = pkgs.voxtype-onnx;
        wayland.display = "wayland-1";
        loadModels = [ "parakeet-unified-en-0.6b" ];
        settings = {
          engine = "parakeet";
          hotkey = {
            key = "F13";
            modifiers = [ "SUPER" ];
            enabled = false;
          };
          audio = {
            device = "default";
            sample_rate = 16000;
            max_duration_secs = 60;
          };
          output = {
            mode = "type";
            fallback_to_clipboard = true;
          };
          parakeet = {
            model = "parakeet-unified-en-0.6b";
            streaming = true;
            streaming_chunk_secs = 0.32;
            streaming_left_context_secs = 5.6;
            streaming_right_context_secs = 0.32;
          };
        };
      };

      home.packages = with pkgs; [ wtype ];
    };
}
