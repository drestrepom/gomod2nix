{
  runCommand,
  buildGoApplication,
}:

let
  args = {
    pname = "hello";
    version = "0.0.1";
    src = ./.;
    pwd = ./hello;
    modules = ./gomod2nix.toml;
    workspaceModule = "example.com/hello";
  };

  drv = buildGoApplication (args // { doCheck = false; });

  # go-cmp is imported only by hello's tests: it must land in testDeps, stay
  # out of the production vendor tree, and be vendored with includeTestDeps.
  tested = buildGoApplication (
    args
    // {
      doCheck = true;
      includeTestDeps = true;
    }
  );
in
runCommand "workspace-hello-assert" { } ''
  if ! test -f ${drv}/bin/hello; then
    echo "hello binary not found!"
    exit 1
  fi

  result=$(${drv}/bin/hello)
  expected="Olleh"
  if [ "$result" != "$expected" ]; then
    echo "Expected '$expected' but got '$result'"
    exit 1
  fi

  if test -e ${drv.vendorEnv}/github.com/google/go-cmp; then
    echo "test-only dependency leaked into the production vendor tree"
    exit 1
  fi

  if ! test -e ${tested.vendorEnv}/github.com/google/go-cmp; then
    echo "includeTestDeps did not vendor the test-only dependency"
    exit 1
  fi

  test -f ${tested}/bin/hello

  ln -s ${drv} $out
''
