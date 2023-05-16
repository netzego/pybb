VENV		:= .venv
SYS_PYTHON	!= which --all python | grep -v \\$(VENV)
PYTHON		:= $(PWD)/$(VENV)/bin/python

$(PWD)/$(VENV)/pyvenv.cfg:
	@$(SYS_PYTHON) -m venv $(VENV)

venv: $(PWD)/$(VENV)/pyvenv.cfg

clean:
	@[[ -d "$(VENV)" ]] && rm -frv $(VENV) || :

.PHONY: \
	clean \
	venv

.DEFAULT_GOAL := venv
