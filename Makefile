VENV			:= .venv
PIP_PACKAGES	:= packages.txt
PIP_LOCKFILE	:= lockfile.txt
SYS_PYTHON		!= which --all python | grep -v -F $(VENV)
PYTHON			:= $(VENV)/bin/python
PIP				:= $(VENV)/bin/pip
PIP_OPTIONS		:= --disable-pip-version-check --no-color --isolated

$(VENV):
	@$(SYS_PYTHON) -m venv $(VENV)

venv: $(VENV)

pip_install: $(PIP_PACKAGES)
	@$(PIP) $(PIP_OPTIONS) install -r $(PIP_PACKAGES)

pip_freeze: $(PIP_PACKAGES)
	@$(PIP) $(PIP_OPTIONS) freeze --all -r $(PIP_PACKAGES) > $(PIP_LOCKFILE)

pip_upgrade: $(PIP_PACKAGES)
	@$(PIP) $(PIP_OPTIONS) install -r $(PIP_PACKAGES) --upgrade

$(PIP_PACKAGES): $(VENV)
	@touch $(PIP_PACKAGES)

$(PIP_LOCKFILE): $(VENV) pip_freeze

clean:
	@[[ -d "$(VENV)" ]] && rm -r $(VENV) || :

distclean: clean
	@[[ -e "$(PIP_PACKAGES)" ]] && rm $(PIP_PACKAGES) || :
	@[[ -e "$(PIP_LOCKFILE)" ]] && rm $(PIP_LOCKFILE) || :

init: venv pip_install
install: pip_install
upgrade: pip_upgrade
freeze: pip_freeze

.PHONY: \
	clean \
	distclean \
	freeze \
	init \
	install \
	pip_freeze \
	pip_install \
	pip_upgrade \
	upgrade \
	venv

.DEFAULT_GOAL := venv
