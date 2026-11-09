{
  lib,
  buildGoModule,
  fetchFromGitHub,
  flake,
  go-bin,
  git,
  unpinGoModVersionHook,
}:

(buildGoModule.override { go = go-bin; }) rec {
  pname = "ycc";
  version = "0-unstable-2026-11-09";

  src = fetchFromGitHub {
    owner = "whyrusleeping";
    repo = "ycc";
    rev = "76f8492be62db554731cdd3c0f4a22d22b5e0ea5";
    hash = "sha256-pvLc8T55cevbCY8/Fa+bl5Bs1EEl3LthUu+Tvdyqckc=";
  };

  nativeBuildInputs = [ unpinGoModVersionHook ];
  nativeCheckInputs = [ git ];
  vendorHash = "sha256-9b/yNr7TCUfa8lwvA/vnWLf35Qokp4GeZDjiJCPb8Wc=";
  subPackages = [ "cmd/ycc" ];
  ldflags = [
    "-s"
    "-w"
  ];

  # The web bundle is committed upstream and embedded by go:embed.
  passthru.category = "AI Coding Agents";
  passthru.skipUpdate = true;

  meta = {
    description = "Docs-driven coding harness with a persistent daemon and web client";
    homepage = "https://github.com/whyrusleeping/ycc";
    changelog = "https://github.com/whyrusleeping/ycc/commits/${src.rev}";
    # Upstream does not declare a license.
    license = flake.lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ flake.lib.maintainers.Chickensoupwithrice ];
    mainProgram = "ycc";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
