# Enable Sunshine, open its ports and grant screen-capture privileges.
{pkgs, ...}: {
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;

    # FFmpeg dlopens the NVIDIA CUDA/NVENC libraries even without cudaSupport.
    # autoPatchelfHook adds the driver RUNPATH to the ELF binary after wrapping.
    # Patching the wrapper alone does not change the binary's RUNPATH.
    package = pkgs.sunshine.overrideAttrs (old: {
      appendRunpaths = (old.appendRunpaths or []) ++ ["${pkgs.addDriverRunpath.driverLink}/lib"];
    });
  };
}
