{
  lib,
  buildGoModule,
  buildNpmPackage,
  wave,
  fetchFromGitHub,
  makeWrapper,
  npm-lockfile-fix,
}:
let
  version = "1.6.5";
  src = fetchFromGitHub {
    owner = "h2oai";
    repo = "wave";
    rev = "v${version}";
    sha256 = "sha256-cZNjq4Wq2qL/wW0Q2U+3AZo9E7n8nybNhzBaptXM4Zo=";
    postFetch = ''
      ${lib.getExe npm-lockfile-fix} $out/ui/package-lock.json
    '';
  };
in
buildGoModule {

  pname = "wave";

  inherit version src;

  vendorHash = "sha256-bXopLNPFQQy03b7cNsUgMmBh+wyDpEqxp/3uKx/wM1c=";

  nativeBuildInputs = [ makeWrapper ];

  subPackages = [ "cmd/wave" ];

  env.GOEXPERIMENT = "boringcrypto";

  postInstall = ''
    mv $out/bin/wave $out/bin/waved
    makeWrapper $out/bin/waved $out/bin/waved2 \
      --add-flags "-web-dir ${wave.passthru.ui}/www/"
  '';

  doCheck = true;

  passthru.ui = buildNpmPackage {
    inherit src;
    name = "waved-ui";

    sourceRoot = "${src.name}/ui";

    npmDepsHash = "sha256-b87neT6RBPL7TCBOS5NuH0jnDZPU4JZU+bZpyJzCFeU=";

    npmFlags = [ "--ignore-scripts" ];

    # npx vite build to fails since its expecting src/markdownCodeSyntaxHighlighting.json
    # to exist:
    # https://github.com/h2oai/wave/blob/ccb9c280747dafa124d2344a55318e8f65769686/ui/src/markdown.tsx#L62
    # this is actually generated postBuild upstream and that cause the build to fail:
    # https://github.com/h2oai/wave/blob/ccb9c280747dafa124d2344a55318e8f65769686/ui/package.json#L67
    buildPhase = ''
      runHook preBuild

      node setup.js > src/markdownCodeSyntaxHighlighting.json
      npx vite build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -r build $out/www

      runHook postInstall
    '';
  };
  meta = with lib; {
    platforms = platforms.unix;
    license = licenses.asl20;
    maintainers = with maintainers; [ sarcasticadmin ];
  };
}
