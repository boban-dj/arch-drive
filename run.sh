#!/bin/bash
. "$(dirname `readlink -f "${BASH_SOURCE[0]}"`)"/common.sh

if [[ $0 == /dev/fd/* ]]; then
  mkdir -p /tmp/arch-drive/scripts
  curl https://bitbucket.org/sgtpep/arch-drive/get/master.tar.gz | tar -xz -C /tmp/arch-drive/scripts

  exec bash -$- /tmp/arch-drive/scripts/run.sh
fi

run-script menu
