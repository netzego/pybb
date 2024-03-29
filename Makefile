SHELL			:= bash
.SHELLFLAGS		:= -eu -o pipefail -c
MAKEFLAGS		+= --warn-undefined-variables
MAKEFLAGS		+= --no-builtin-rules
PROGNAME		:= pybb
VENV_DIR		:= .venv
REQ_IN			:= requirements.in
REQ_TXT			:= requirements.txt
WORKTREE_ROOT	!= git rev-parse --show-toplevel 2> /dev/null
SYS_PYTHON		!= which --all python | grep -v -F $(VENV_DIR)
PYTHON			:= $(VENV_DIR)/bin/python
PIP				:= $(VENV_DIR)/bin/pip
PIP_OPTIONS		:= --disable-pip-version-check --no-color --isolated
PYTEST			:= $(VENV_DIR)/bin/pytest
PYTEST_OPTIONS	:= --verbose --doctest-modules --capture=no

$(REQ_IN):
	@touch $@

$(REQ_TXT): .FORCE $(REQ_IN) |$(VENV_DIR)
	@$(PIP) $(PIP_OPTIONS) freeze \
		--local \
		--exclude-editable \
		--requirement $(REQ_IN) \
		| tee $(REQ_TXT)

$(VENV_DIR):
	@$(SYS_PYTHON) -m venv $(VENV_DIR)
	@cat $(VENV_DIR)/pyvenv.cfg

install_packages: $(REQ_IN) |$(VENV_DIR)
	@$(PIP) $(PIP_OPTIONS) install -r $<

src/$(PROGNAME).egg-info: .FORCE
	@$(PIP) $(PIP_OPTIONS) install --force-reinstall --editable .

list: |$(VENV_DIR)
	@$(PIP) $(PIP_OPTIONS) list --format=freeze

upgrade: |$(REQ_IN)
	@$(PIP) $(PIP_OPTIONS) install -r $< --upgrade

clean_caches:
	@fd -I -H "\..*_cache" -x rm -r {}

clean: clean_caches
	@[[ -d "$(VENV_DIR)" ]] && rm -r $(VENV_DIR) || :
	@[[ -d "src/$(PROGNAME).egg-info" ]] && rm -r "src/$(PROGNAME).egg-info" || :

distclean: clean
	@[[ -e "$(REQ_TXT)" ]] && rm $(REQ_TXT) || :

test:
	@$(PYTEST) $(PYTEST_OPTIONS)

watch_test:
	@fd -t f \.py | entr -c $(MAKE) --no-print-directory test

info:
	@cat $(VENV_DIR)/pyvenv.cfg
	@$(MAKE) --no-print-directory list

venv: |$(VENV_DIR)
install_project: src/$(PROGNAME).egg-info
install: install_packages install_project
init: |$(VENV_DIR) install
freeze: $(REQ_TXT)

.FORCE:

.PHONY: \
	clean \
	clean_caches \
	distclean \
	freeze \
	init \
	install_packages \
	install_project \
	list \
	test \
	watch_test \
	upgrade \
	venv

.DEFAULT_GOAL := init
