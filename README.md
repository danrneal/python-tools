# python-tools

A collection of custom Python development and testing tools to improve productivity, code quality, and testing insights.

## Features & Tools

### 1. `Makefile`, `ruff.toml`, `pyrefly.toml`, `pytest.toml`, `.coveragerc.toml`, & `setup.cfg`

This repository provides centralized `Makefile`, `ruff.toml`, `pyrefly.toml`, `pytest.toml`, `.coveragerc.toml`, and `setup.cfg` configurations. The `Makefile` orchestrates fetching the latest configurations, installing and upgrading CLI tools with `uv`, formatting and linting code with `ruff`, type checking with `pyrefly`, running tests with `pytest`, branch coverage (`pytest-cov` / `coverage.py`), and `diff-cover`, and running mutation testing with `mutmut`.

## Setup & Usage

To use these tools and configurations in a new repository, you only need to copy the `Makefile` over. The `Makefile` will handle downloading the latest configurations and installing the required CLI tools.

1. Download the `Makefile` to your project root:
   ```sh
   curl -sSfL https://raw.githubusercontent.com/danrneal/python-tools/main/Makefile -o Makefile
   ```

2. Run the complete pipeline to install tools, fetch configs, and run all checks:
   ```sh
   make all
   ```

3. For faster development cycles (skipping tool/config updates and mutation testing), use:
   ```sh
   make fast
   ```

4. To interactively inspect and re-run surviving mutants after `make all` (or `make mutate`), use:
   ```sh
   uv run --with mutmut --with pytest --with pytest-socket mutmut browse
   ```

5. If your tests `import pytest`, add `pytest>=9.0` under `[dependency-groups] dev` in `pyproject.toml` so `pyrefly` can resolve the import in `.venv`.

## License

python-tools is licensed under the [MIT License](LICENSE).
