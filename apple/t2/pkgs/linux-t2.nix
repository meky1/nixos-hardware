{ lib, buildLinux, fetchFromGitHub, fetchurl, ... } @ args:

let
  patchRepo = fetchFromGitHub {
    owner = "t2linux";
    repo = "linux-t2-patches";
    rev = "46dd873d1d9d12b26916790045008a91a95d0c11";
    hash = "sha256-YGUGuzsAJFtZYjIW9d2XU4eGKNvMKCaWXqgqJn5TdeY=";
  };

  version = "6.6.6";
  majorVersion = with lib; (elemAt (take 1 (splitVersion version)) 0);
in
buildLinux (args // {
  inherit version;

  pname = "linux-t2";
  # Snippet from nixpkgs
  modDirVersion = with lib; "${concatStringsSep "." (take 3 (splitVersion "${version}.0"))}";

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v${majorVersion}.x/linux-${version}.tar.xz";
    sha256 = "1j14n8b012pv3r7i9p762jyabzn2nv1ranxyw5lk3c9lg68hmxzb";
  };

  structuredExtraConfig = with lib.kernel; {
    APPLE_BCE = module;
    APPLE_GMUX = module;
    BRCMFMAC = module;
    BT_BCM = module;
    BT_HCIBCM4377 = module;
    BT_HCIUART_BCM = yes;
    BT_HCIUART = module;
    HID_APPLE_IBRIDGE = module;
    HID_APPLE = module;
    HID_APPLE_MAGIC_BACKLIGHT = module;
    HID_APPLE_TOUCHBAR = module;
    HID_SENSOR_ALS = module;
    SND_PCM = module;
    STAGING = yes;
  };

  kernelPatches = lib.attrsets.mapAttrsToList (file: type: { name = file; patch = "${patchRepo}/${file}"; })
    (lib.attrsets.filterAttrs (file: type: type == "regular" && lib.strings.hasSuffix ".patch" file)
      (builtins.readDir patchRepo));
} // (args.argsOverride or {}))
