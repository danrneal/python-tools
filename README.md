# python-tools

A collection of custom Python development and testing tools to improve productivity, code quality, and testing insights.

## Features & Tools

### 1. `Makefile`, `ruff.toml`, `pyrefly.toml`, `pytest.toml`, & `.coveragerc.toml`

This repository provides centralized `Makefile`, `ruff.toml`, `pyrefly.toml`, `pytest.toml`, and `.coveragerc.toml` configurations. The `Makefile` orchestrates fetching the latest configurations, installing and upgrading CLI tools with `uv`, formatting and linting code with `ruff`, type checking with `pyrefly`, and running tests with `pytest`, branch coverage (`pytest-cov` / `coverage.py`), and `diff-cover`.

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

3. For faster development cycles (skipping tool and config updates), use:
   ```sh
   make fast
   ```

## License

python-tools is licensed under the [MIT License](LICENSE).
