VENV			:= .venv
PIP_PACKAGES	:= packages.txt
PIP_LOCKFILE	:= lockfile.txt
SYS_PYTHON		!= which --all python | grep -v -F $(VENV)
PYTHON			:= $(VENV)/bin/python
PIP				:= $(VENV)/bin/pip
PIP_OPTIONS		:= --disable-pip-version-check --no-color --isolated

$(VENV):
	@$(SYS_PYTHON) -m venv $(VENV)

$(PIP_PACKAGES): | $(VENV)
	@touch $(PIP_PACKAGES)

$(PIP_LOCKFILE): $(PIP_PACKAGES) | $(VENV)
	@$(PIP) $(PIP_OPTIONS) install -r $<
	@$(PIP) $(PIP_OPTIONS) freeze -r $< > $@

pip_list: | $(VENV)
	@$(PIP) $(PIP_OPTIONS) list --format=freeze

pip_freeze: | $(VENV)
	@$(PIP) $(PIP_OPTIONS) freeze -r $(PIP_PACKAGES)

pip_upgrade: $(PIP_PACKAGES)
	@$(PIP) $(PIP_OPTIONS) install -r $< --upgrade

clean:
	@[[ -d "$(VENV)" ]] && rm -r $(VENV) || :

distclean: clean
	@[[ -e "$(PIP_PACKAGES)" ]] && rm $(PIP_PACKAGES) || :
	@[[ -e "$(PIP_LOCKFILE)" ]] && rm $(PIP_LOCKFILE) || :

init: $(PIP_LOCKFILE)
venv: $(VENV)
install: $(PIP_LOCKFILE)
upgrade: pip_upgrade
freeze: pip_freeze
list: pip_list

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
	upgrade \
	venv

.DEFAULT_GOAL := $(PIP_LOCKFILE)
