{ lib
, python3
, fetchFromGitHub
}:

let
  version = "1.1.1";
  src = fetchFromGitHub {
    owner = "h2oai";
    repo = "wave";
    rev = "v${version}";
    sha256 = "sha256-fINuoJx7dPN613wLLzcC2aar5vz6L6qzAWm/bWgj9bo=";
  };
in
python3.pkgs.buildPythonPackage {
  inherit src version;
  pname = "h2o_wave";
  format = "pyproject";

  sourceRoot = "${src.name}/py/h2o_wave";

  nativeBuildInputs = with python3.pkgs; [
    hatchling
    pythonRelaxDepsHook
  ];

  propagatedBuildInputs = with python3.pkgs; [
    click
    inquirer
    httpx
    starlette
    uvicorn
  ];

  pythonImportsCheck = [ "h2o_wave" ];

  meta = with lib; {
    homepage = "https://wave.h2o.ai/";
    description = "Build beautiful, low-latency, realtime, browser-based applications and dashboards entirely in Python";
    license = licenses.asl20;
    maintainers = with maintainers; [ sarcasticadmin ];
    mainProgram = "wave";
  };
}
