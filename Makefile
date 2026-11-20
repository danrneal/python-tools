.PHONY: all fast update lint typecheck test mutate clean

PYTHON_VERSION ?=
PYTEST_SHARED_FLAGS := \
	--allow-hosts=127.0.0.1,::1,localhost \
	--allow-unix-socket \
	--disable-socket \
	--import-mode=importlib \
	--strict \
	-W error \
	-o empty_parameter_set_mark=fail_at_collect \
	-o tmp_path_retention_policy=failed

all: update lint typecheck test mutate clean

fast: lint typecheck test clean

update:
	@echo "==> Updating tooling configurations from danrneal/python-tools..."
	curl -sSfL -z ruff.toml https://raw.githubusercontent.com/danrneal/python-tools/main/ruff.toml -o ruff.toml
	curl -sSfL -z pyrefly.toml https://raw.githubusercontent.com/danrneal/python-tools/main/pyrefly.toml -o pyrefly.toml
	curl -sSfL -z setup.cfg https://raw.githubusercontent.com/danrneal/python-tools/main/setup.cfg -o setup.cfg
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
	uv tool install diff-cover
	uv tool upgrade diff-cover
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

test:
	@if [ -f pyproject.toml ]; then \
		echo "==> Running pytest with coverage..."; \
		uv run \
			--with pytest \
			--with pytest-cov \
			--with pytest-randomly \
			--with pytest-socket \
			--with pytest-timeout \
			--with pytest-xdist \
			pytest \
				$(PYTEST_SHARED_FLAGS) \
				-n auto \
				-ra \
				--timeout=60 \
				--ignore=mutants \
				--cov=. \
				--cov-branch \
				--cov-report=term-missing \
				--cov-report=xml \
				--cov-report=html:$(HOME)/Downloads/htmlcov; \
		if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then \
			BASE_BRANCH="origin/main"; \
			if ! git rev-parse --verify "$$BASE_BRANCH" >/dev/null 2>&1; then \
				BASE_BRANCH="HEAD"; \
			fi; \
			if git rev-parse --verify "$$BASE_BRANCH" >/dev/null 2>&1; then \
				echo "==> Checking coverage diff against $$BASE_BRANCH..."; \
				diff-cover coverage.xml --compare-branch="$$BASE_BRANCH" --include-untracked; \
			fi; \
		fi; \
	fi

mutate:
	@if [ -f pyproject.toml ]; then \
		echo "==> Running mutmut..."; \
		PYTEST_ADDOPTS="$(PYTEST_SHARED_FLAGS)" uv run \
			--with mutmut \
			--with pytest \
			--with pytest-socket \
			mutmut run; \
		uv run \
			--with mutmut \
			mutmut results; \
	fi

clean:
	@echo "==> Cleaning up artifacts..."
	rm -rf .coverage .coverage.* coverage.xml
