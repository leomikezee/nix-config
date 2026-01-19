# Game-streaming host; opens Sunshine's ports and grants capture privileges.
{pkgs, ...}: {
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;

    # FFmpeg dlopens the NVIDIA CUDA/NVENC libraries even without cudaSupport.
    # Let autoPatchelfHook add the driver RUNPATH to the real ELF after wrapping;
    # patching only the wrapper doesn't affect the binary it executes.
    package = pkgs.sunshine.overrideAttrs (old: {
      appendRunpaths = (old.appendRunpaths or []) ++ ["${pkgs.addDriverRunpath.driverLink}/lib"];
    });
  };
}
