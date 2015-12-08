MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

GIT_SCRIPT := $(MAKEFILE_DIR)git.sh
GIT_RSA    := $(HOME)/.ssh/ssh_github


clean:
	find $(MAKEFILE_DIR) -name .Ulysses-Group.plist -exec rm -rf {} \;
	find $(MAKEFILE_DIR) -name .DS_Store -exec rm -rf {} \;

update:
	$(GIT_SCRIPT) -i $(GIT_RSA) pull

push:
	$(GIT_SCRIPT) -i $(GIT_RSA) push -u origin master 

