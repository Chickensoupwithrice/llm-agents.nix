{
  lib,
  flake,
  buildGo127Module,
  fetchurl,
  versionCheckHook,
  versionCheckHomeHook,
}:

buildGo127Module rec {
  pname = "kata";
  version = "0.18.0";

  # The release source archive includes vendored Go dependencies and the built
  # web UI; GitHub's automatically generated tag archive lacks both.
  src = fetchurl {
    url = "https://github.com/kenn-io/kata/releases/download/v${version}/kata_${version}_source.tar.gz";
    hash = "sha256-mAUDq0pbo3KDtcNQE9A0y5TjK8VWaUJihMvUcDAUHbY=";
  };

  vendorHash = null;
  subPackages = [ "cmd/kata" ];
  env.CGO_ENABLED = "0";

  ldflags = [
    "-s"
    "-w"
    "-X=go.kenn.io/kata/internal/version.Version=v${version}"
    "-X=go.kenn.io/kata/internal/version.Distribution=nix"
  ];

  # The CLI suite includes integration tests that start daemons and use sockets.
  doCheck = false;

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    versionCheckHomeHook
  ];
  versionCheckProgramArg = "version";
  postInstallCheck = ''
    "$out/bin/kata" _web-assets-check
  '';

  passthru.category = "Workflow & Project Management";

  meta = with lib; {
    description = "Local-first issue tracker for coding agents and humans";
    homepage = "https://www.katatracker.com/";
    changelog = "https://github.com/kenn-io/kata/releases/tag/v${version}";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ fromSource ];
    maintainers = with flake.lib.maintainers; [ Chickensoupwithrice ];
    mainProgram = "kata";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
