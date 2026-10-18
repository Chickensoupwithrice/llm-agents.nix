{
  lib,
  flake,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  bun,
  nodejs,
  makeWrapper,
  formatelf,
  python3,
}:

let
  version = "0.10.2";
  src = fetchFromGitHub {
    owner = "anima-research";
    repo = "connectome-host";
    tag = "v${version}";
    hash = "sha256-QAI8bg8J2XJYdqs0NAW/bkO5j+ZLiFBKZxNqfnRslJA=";
  };
  web = buildNpmPackage {
    pname = "connectome-host-web";
    inherit version src;
    sourceRoot = "source/web";
    npmDepsHash = "sha256-Sxr6zihRCCmKAoQN/97oQ6t+pelDY9O7eIx9ONKAAuA=";
    npmDepsFetcherVersion = 2;
    # Vite writes to ../dist/web, outside the writable sourceRoot.
    preBuild = ''
      chmod u+w ..
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r ../dist/web/. $out/
      runHook postInstall
    '';
  };
in
buildNpmPackage {
  pname = "connectome-host";
  inherit version src;

  npmDepsHash = "sha256-cEtIai9bEPDU7wN3hfqi85fl+L9G/0VaEQO9CTaTmJE=";
  npmDepsFetcherVersion = 2;
  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ formatelf ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    app=$out/share/connectome-host
    mkdir -p "$app/dist"
    cp -r src recipes node_modules package.json "$app/"
    cp -r ${web} "$app/dist/web"
    makeWrapper ${lib.getExe bun} $out/bin/connectome-host \
      --add-flags "$app/src/index.ts" \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]}
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ python3 ];
  installCheckPhase = ''
    runHook preInstallCheck
    ${lib.getExe python3} ${./smoke-test.py} "$out"
    runHook postInstallCheck
  '';

  passthru = {
    category = "AI Assistants";
    inherit web;
  };

  meta = {
    description = "Recipe-configured host for long-lived agents with a terminal and web console";
    homepage = "https://github.com/anima-research/connectome-host";
    changelog = "https://github.com/anima-research/connectome-host/releases/tag/v${version}";
    # Upstream does not declare a license for the host itself.
    license = flake.lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
    maintainers = [ flake.lib.maintainers.Chickensoupwithrice ];
    mainProgram = "connectome-host";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
