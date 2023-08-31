SHELL			:= bash
.SHELLFLAGS		:= -eu -o pipefail -c
MAKEFLAGS		+= --warn-undefined-variables
MAKEFLAGS		+= --no-builtin-rules
PROGNAME		:= pybb
VENV_DIR		:= .venv
REQ_IN			:= requirements.in
REQ_TXT			:= requirements.txt
WORKTREE_ROOT   != git rev-parse --show-toplevel 2> /dev/null
SYS_PYTHON		!= which --all python | grep -v -F $(VENV_DIR)
PYTHON			:= $(VENV_DIR)/bin/python
PIP				:= $(VENV_DIR)/bin/pip
PIP_OPTIONS		:= --disable-pip-version-check --no-color --isolated
PYTEST			:= $(VENV_DIR)/bin/pytest
PYTEST_OPTIONS	:= --verbose --doctest-modules --capture=no

$(REQ_IN):
	@touch $(REQ_IN)

$(REQ_TXT): .FORCE $(REQ_IN) |$(VENV_DIR)
	@$(PIP) $(PIP_OPTIONS) freeze \
		--local \
		--exclude-editable \
		--requirement $(REQ_IN) \
		| tee $(REQ_TXT)

$(VENV_DIR):
	@$(SYS_PYTHON) -m venv $(VENV_DIR)
	@cat $(VENV_DIR)/pyvenv.cfg

list: |$(VENV_DIR)
	@$(PIP) $(PIP_OPTIONS) list --format=freeze

pip_freeze: | $(VENV_DIR)
	@$(PIP) $(PIP_OPTIONS) freeze -r $(REQ_IN)

upgrade: |$(REQ_IN)
	@$(PIP) $(PIP_OPTIONS) install -r $< --upgrade

clean_caches:
	@[[ -d ".pytest_cache" ]] && rm -r ".pytest_cache" || :
	@[[ -d ".ruff_cache" ]] && rm -r ".ruff_cache" || :

clean: clean_caches
	@[[ -d "$(VENV_DIR)" ]] && rm -r $(VENV_DIR) || :

distclean: clean
	@[[ -e "$(REQ_IN)" ]] && rm $(REQ_IN) || :
	@[[ -e "$(REQ_TXT)" ]] && rm $(REQ_TXT) || :

pytest:
	$(PYTEST) $(PYTEST_OPTIONS)

init: $(REQ_TXT)
venv: $(VENV_DIR)
install: $(REQ_TXT)
upgrade: pip_upgrade
freeze: pip_freeze
list: pip_list
test: pytest

.FORCE:

.PHONY: \
	clean \
	distclean \
	freeze \
	init \
	install \
	list \
	pip_freeze \
	pip_list \
	pip_upgrade \
	pytest \
	test \
	upgrade \
	venv

.DEFAULT_GOAL := $(REQ_TXT)
