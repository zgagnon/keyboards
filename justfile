# Set fallback to true to enable searching parent directories for justfiles
set fallback

# Define default recipe to run when just is invoked without arguments
default:
  @just waterfowl-36

create-iris:
  mkdir -p qmk_firmware/keyboards/keebio/iris/keymaps/zgagnon/

create-waterfowl: qmk_firmware
  mkdir -p qmk_firmware/keyboards/waterfowl/keymaps/zgagnon/

tangle layout:
  #!/bin/bash
  echo "Tangling layout: {{layout}}"
  cd {{layout}}
  emacs --batch --eval "(require 'org)" --eval "(org-babel-tangle-file \"{{layout}}.org\")"

insert-iris layout: (tangle layout) create-iris
  #!/bin/bash
  echo "Inserting layout: {{layout}}"
  cd {{layout}}
  ls
  pwd
  cp keymap.json ../qmk_firmware/keyboards/keebio/iris/keymaps/zgagnon/

insert-layout layout: (tangle layout) create-waterfowl
  #!/bin/bash
  echo "Inserting layout: {{layout}}"
  cd {{layout}}
  ls
  cp keymap.c ../qmk_firmware/keyboards/waterfowl/keymaps/zgagnon/
  cp rules.mk ../qmk_firmware/keyboards/waterfowl/
  cp waterfowl.c ../qmk_firmware/keyboards/waterfowl/
  cp config.h ../qmk_firmware/keyboards/waterfowl/
  
iris: qmk_firmware setup  (insert-iris 'iris')
  #!/bin/bash
  echo "Building iris"
  cd qmk_firmware
  nix run nixpkgs#qmk -- compile -kb keebio/iris/rev6 -km zgagnon

waterfowl-36: qmk_firmware setup  (insert-layout 'waterfowl-36')
  #!/bin/bash
  echo "Building waterfowl-36"
  cd qmk_firmware
  nix run nixpkgs#qmk -- compile -kb waterfowl -km zgagnon

waterfowl-26: qmk_firmware setup  (insert-layout 'waterfowl-26')
  #!/bin/bash
  echo "Building waterfowl-26"
  cd qmk_firmware
  nix run nixpkgs#qmk -- compile -kb waterfowl -km zgagnon


# Clone the qmk_firmware repository
qmk_firmware: 
  #!/bin/bash
  echo "Cloning qmk_firmware, if it doesn't exist"
  if [ ! -d "./qmk_firmware" ]; then
    git clone --depth 1 https://github.com/qmk/qmk_firmware.git
  fi
  cd qmk_firmware
  git submodule update --init --recursive

setup: clean-hex
  #!/bin/bash
  echo "Setting up"
  cd qmk_firmware
  nix run nixpkgs#qmk -- setup

clean-hex:
  @echo "Cleaning up hex files"
  rm -rf qmk_firmware/*.hex

clean:
  @echo "Cleaning up"
  rm -rf qmk_firmware
