{ lib
, buildGoModule
, buildNpmPackage
, fetchFromGitHub
, makeWrapper
, stdenvNoCC
, fetchurl
}:
let
  version = "1.1.1";
  src = fetchFromGitHub {
    owner = "h2oai";
    repo = "wave";
    rev = "v${version}";
    sha256 = "sha256-fINuoJx7dPN613wLLzcC2aar5vz6L6qzAWm/bWgj9bo=";
  };

  ui = stdenvNoCC.mkDerivation {
    pname = "ui";
    inherit version;
    src = fetchurl {
      url = "https://github.com/h2oai/wave/releases/download/v1.1.1/wave-1.1.1-linux-amd64.tar.gz";
      hash = "sha256-Q1SfmRyM02qIHJRIToglx4pEczUjte5dvDWNbCQ0W3s=";
    };

    installPhase = ''
      mkdir -p $out/www
      cp -r --no-preserve=mode www $out
    '';
  };
in
buildGoModule {
  pname = "wave";

  inherit version src;

  vendorHash = "sha256-WQqwUN/TPWhfpgSjLgMVKmXVXTk/ElgT+Nk+XLfNayA=";

  nativeBuildInputs = [ makeWrapper ];
  #runtimeDependencies = [ ui ];

  postInstall = ''
    mv $out/bin/wave $out/bin/waved
    makeWrapper $out/bin/waved $out/bin/waved2 \
      --add-flags "-web-dir ${ui}/www/"
  '';

  doCheck = true;

  meta = with lib; {
    platforms = platforms.unix;
    license = licenses.asl20;
    maintainers = with maintainers; [ sarcasticadmin matthewcroughan ];
  };
}

