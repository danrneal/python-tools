.PHONY: all fast update lint typecheck clean

PYTHON_VERSION ?=

all: update lint typecheck clean

fast: lint typecheck clean

update:
	@echo "==> Updating tooling configurations from danrneal/python-tools..."
	curl -sSfL -z ruff.toml https://raw.githubusercontent.com/danrneal/python-tools/main/ruff.toml -o ruff.toml
	curl -sSfL -z pyrefly.toml https://raw.githubusercontent.com/danrneal/python-tools/main/pyrefly.toml -o pyrefly.toml
	curl -sSfL -z Makefile https://raw.githubusercontent.com/danrneal/python-tools/main/Makefile -o Makefile
	@echo "==> Installing latest CLI tools..."
	@if command -v uv >/dev/null 2>&1; then \
		uv self update 2>/dev/null || (command -v pipx >/dev/null 2>&1 && pipx upgrade uv) || true; \
	else \
		curl -LsSf https://astral.sh/uv/install.sh | sh; \
	fi
	uv tool install ruff
	uv tool upgrade ruff
	uv tool install pyrefly
	uv tool upgrade pyrefly
	@if [ -f pyproject.toml ]; then \
		echo "==> Upgrading Python and dependencies..."; \
		PY_VER="$(PYTHON_VERSION)"; \
		if [ -z "$$PY_VER" ]; then \
			PY_VER=$$(uv python list --only-downloads --output-format json cpython | jq -r '[.[] | select(.variant == "default" and (.version | test("^[0-9]+\\.[0-9]+\\.[0-9]+$$")))][0] | "\(.version_parts.major).\(.version_parts.minor)"'); \
		fi; \
		echo "==> Targeting Python $$PY_VER..."; \
		uv python install "$$PY_VER"; \
		uv python upgrade "$$PY_VER"; \
		uv python pin "$$PY_VER"; \
		python3 -c 'import pathlib, re, sys; p = pathlib.Path("pyproject.toml"); p.write_text(re.sub(r"(?m)^requires-python\s*=\s*\"[^\"]*\"", f"requires-python = \">={sys.argv[1]}\"", p.read_text()))' "$$PY_VER"; \
		uv sync --upgrade; \
	fi

lint:
	@echo "==> Running ruff..."
	ruff check --fix --exit-zero
	ruff format
	ruff check

typecheck:
	@echo "==> Running pyrefly..."
	pyrefly check

clean:
	@echo "==> Cleaning up artifacts..."
	rm -rf .coverage coverage.xml htmlcov
