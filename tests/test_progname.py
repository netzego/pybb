import pybb


def test_progname(pyproject_toml):
    assert(pybb.__progname__ == pyproject_toml["project"]["name"])
