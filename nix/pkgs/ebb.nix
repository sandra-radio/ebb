{ lib
, python3
, h2o_wave
}:

let
  pname = "ebb";
  version = "0.0.0";
in
python3.pkgs.buildPythonApplication {
  inherit pname version;

  src = ./../..;
  format = "pyproject";

  nativeBuildInputs = [
    python3.pkgs.pythonRelaxDepsHook
  ];

  buildInputs = [
    python3.pkgs.setuptools
  ];

  propagatedBuildInputs = [
    python3.pkgs.requests
    python3.pkgs.docopt-ng
    h2o_wave
  ];

  meta = {
    mainProgram = "ebb";
  };
}
