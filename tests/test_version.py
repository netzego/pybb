import pybb


def test_version(pyproject_toml):
    toml_version = ".".join(str(x) for x in pybb.__version__)
    init_version = pyproject_toml["project"]["version"]

    assert init_version == toml_version
