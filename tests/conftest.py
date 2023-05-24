from pathlib import Path

from pytest import fixture
import tomllib


@fixture
def pyproject_toml(request) -> dict:
    with open(Path(request.config.rootdir / "pyproject.toml"), "rb") as f:
        data = tomllib.load(f)

    return data
