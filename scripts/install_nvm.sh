cd ~/
git clone https://github.com/nvm-sh/nvm.git .nvm
cd ~/.nvm
git fetch --tags origin
git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`