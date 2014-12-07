#!/bin/bash
if [[ $0 == /dev/fd/* ]]; then
  mkdir -p /tmp/arch-drive/scripts
  curl https://bitbucket.org/sgtpep/arch-drive/get/master.tar.gz | tar -xz -C /tmp/arch-drive/scripts --strip-components=1

  exec bash -$- /tmp/arch-drive/scripts/run.sh
fi

bash -$- "$(dirname `readlink -f "${BASH_SOURCE[0]}"`)"/menu.sh
