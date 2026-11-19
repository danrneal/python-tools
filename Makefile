.PHONY: all fast update lint clean

all: update lint clean

fast: lint clean

update:
	@echo "==> Updating tooling configurations from danrneal/python-tools..."
	curl -sSfL -z ruff.toml https://raw.githubusercontent.com/danrneal/python-tools/main/ruff.toml -o ruff.toml
	curl -sSfL -z Makefile https://raw.githubusercontent.com/danrneal/python-tools/main/Makefile -o Makefile
	@echo "==> Installing latest CLI tools..."
	@if command -v uv >/dev/null 2>&1; then \
		uv self update; \
	else \
		curl -LsSf https://astral.sh/uv/install.sh | sh; \
	fi
	uv tool install ruff
	uv tool upgrade ruff
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

clean:
	@echo "==> Cleaning up artifacts..."
	rm -rf .coverage coverage.xml htmlcov
