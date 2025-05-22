# INSTALL EVERYTHING

# install:
# 	@echo "Installing CLI tools..."
# 	@echo "STEP 1: Installing Fonts..."
# 	bash installers/install_fonts.sh
# 	@echo "STEP : Installing NVM..."
# 	bash installers/install_nvm.sh
# 	@echo "STEP 3: Aliasing RC files..."
# 	bash installers/install_shell.sh

install_fonts:
	@echo "Installing Fonts..."
	bash installers/install_fonts.sh

install_nvm:
	@echo "Installing NVM..."
	bash installers/install_nvm.sh

install_shell:
	@echo "Aliasing RC files..."
	bash installers/install_shell.sh

install_oh_my_zsh:
	@echo "Installing Oh My Zsh..."
	bash installers/install_oh_my_zsh.sh

install_ripgrep:
	@echo "Installing ripgrep..."
	bash installers/install_ripgrep.sh

install_mac_specific:
	@echo "Installing Mac specific tools..."
	@if [ "$(shell uname)" = "Darwin" ]; then \
		bash installers/mac_specific/install_homebrew.sh && \
		bash installers/mac_specific/install_homebrew_packages.sh; \
	else \
		echo "Not a Mac system, skipping Mac specific installations."; \
	fi

install: install_fonts install_nvm install_shell install_ripgrep install_mac_specific
	@echo "All installations complete!"
	@echo "Please restart your terminal for changes to take effect."
