#!/bin/bash

#!/bin/bash

USERNAME=user
TOP_DIR=/home/${USERNAME}/work/display-safety/work

source /home/${USERNAME}/.cargo/env

cd /home/${USERNAME}/work/display-safety
pushd ./crates/framework/graphics/impeller-rs
./deps.sh
popd

./install-rust-toolchains.sh
./linux-build.sh

