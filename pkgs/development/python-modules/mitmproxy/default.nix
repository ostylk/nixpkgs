{ lib
, fetchFromGitHub
, fetchpatch
, buildPythonPackage
, pythonOlder
  # Mitmproxy requirements
, asgiref
, blinker
, brotli
, certifi
, click
, cryptography
, flask
, h11
, h2
, hyperframe
, kaitaistruct
, ldap3
, msgpack
, passlib
, protobuf
, publicsuffix2
, pyopenssl
, pyparsing
, pyperclip
, ruamel-yaml
, setuptools
, sortedcontainers
, tornado
, urwid
, wsproto
, zstandard
  # Additional check requirements
, hypothesis
, parver
, pytest-asyncio
, pytest-timeout
, pytest-xdist
, pytestCheckHook
, requests
}:

buildPythonPackage rec {
  pname = "mitmproxy";
  version = "8.1.1";
  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "refs/tags/v${version}";
    sha256 = "sha256-nW/WfiY6uF67qNa95tvNvSv/alP2WmzTk34LEBma/04=";
  };

  patches = [
    # Fix onboarding addon tests failing with Flask >= v2.2
    (fetchpatch {
      url = "https://github.com/mitmproxy/mitmproxy/commit/bc370276a19c1d1039e7a45ecdc23c362626c81a.patch";
      hash = "sha256-Cp7RnYpZEuRhlWYOk8BOnAKBAUa7Vy296UmQi3/ufes=";
    })
  ];

  propagatedBuildInputs = [
    setuptools
    # setup.py
    asgiref
    blinker
    brotli
    certifi
    click
    cryptography
    flask
    h11
    h2
    hyperframe
    kaitaistruct
    ldap3
    msgpack
    passlib
    protobuf
    publicsuffix2
    pyopenssl
    pyparsing
    pyperclip
    ruamel-yaml
    sortedcontainers
    tornado
    urwid
    wsproto
    zstandard
  ];

  checkInputs = [
    hypothesis
    parver
    pytest-asyncio
    pytest-timeout
    pytest-xdist
    pytestCheckHook
    requests
  ];

  postPatch = ''
    # remove dependency constraints
    sed 's/>=\([0-9]\.\?\)\+\( \?, \?<\([0-9]\.\?\)\+\)\?\( \?, \?!=\([0-9]\.\?\)\+\)\?//' -i setup.py
  '';

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  disabledTests = [
    # Tests require a git repository
    "test_get_version"
    # https://github.com/mitmproxy/mitmproxy/commit/36ebf11916704b3cdaf4be840eaafa66a115ac03
    # Tests require terminal
    "test_integration"
    "test_contentview_flowview"
    "test_flowview"
  ];
  dontUsePytestXdist = true;

  pythonImportsCheck = [ "mitmproxy" ];

  meta = with lib; {
    description = "Man-in-the-middle proxy";
    homepage = "https://mitmproxy.org/";
    license = licenses.mit;
    maintainers = with maintainers; [ kamilchm SuperSandro2000 ];
  };
}
