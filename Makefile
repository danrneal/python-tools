.PHONY: all fast update lint typecheck clean

all: update lint typecheck clean

fast: lint typecheck clean

update:
	@echo "==> Updating tooling configurations from danrneal/python-tools..."
	curl -sSfL -z ruff.toml https://raw.githubusercontent.com/danrneal/python-tools/main/ruff.toml -o ruff.toml
	curl -sSfL -z pyrefly.toml https://raw.githubusercontent.com/danrneal/python-tools/main/pyrefly.toml -o pyrefly.toml
	curl -sSfL -z Makefile https://raw.githubusercontent.com/danrneal/python-tools/main/Makefile -o Makefile
	@echo "==> Installing latest CLI tools..."
	@if command -v uv >/dev/null 2>&1; then \
		uv self update; \
	else \
		curl -LsSf https://astral.sh/uv/install.sh | sh; \
	fi
	uv tool install ruff
	uv tool upgrade ruff
	uv tool install pyrefly
	uv tool upgrade pyrefly
	@if [ -f pyproject.toml ]; then \
		echo "==> Upgrading Python and dependencies..."; \
		uv python install; \
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
