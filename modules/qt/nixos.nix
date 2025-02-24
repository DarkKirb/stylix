{
  lib,
  pkgs,
  config,
  ...
}:

let

  recommendedStyle = {
    gnome = if config.stylix.polarity == "dark" then "adwaita-dark" else "adwaita";
    kde = "breeze";
    qtct = "kvantum";
  };

in
{
  options.stylix.targets.qt = {
    enable = config.lib.stylix.mkEnableTarget "QT" pkgs.stdenv.hostPlatform.isLinux;
    platform = lib.mkOption {
      description = ''
        Selects the platform theme to use for Qt applications.

        Defaults to the standard platform used in the configured DE.
      '';
      type = lib.types.str;
    };
  };

  config = lib.mkIf (config.stylix.enable && config.stylix.targets.qt.enable) {
    assertions = [
      {
        assertion =
          config.services.desktopManager.plasma6.enable -> (config.stylix.targets.qt.platform == "kde6");
        message = "Plasma6 only works with QT6 based themes, please set qt.platform to 'kde6', not ${config.stylix.target.qt.platform}";
      }
    ];
    stylix.targets.qt.platform =
      with config.services.desktopManager;
      if plasma6.enable then
        "kde6"
      else if gnome.enable && !(plasma5.enable || lxqt.enable) then
        "gnome"
      else if plasma5.enable && !(gnome.enable || lxqt.enable) then
        "kde"
      else if lxqt.enable && !(gnome.enable || plasma5.enable) then
        "lxqt"
      else
        "qtct";
    qt = {
      enable = true;
      style = recommendedStyle."${config.qt.platformTheme}" or null;
      platformTheme =
        if config.stylix.targets.qt.platform == "qtct" then "qt5ct" else config.stylix.targets.qt.platform;
    };
  };

}
