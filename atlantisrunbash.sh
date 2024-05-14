#!/bin/bash

echo "This script expects Ubuntu Server 20.04.2 LTS (Focal Fossa)"
echo "Run Atlantis simulation"

sudo flip -uv *; sudo chmod +x amps_cal.sh; sudo sh ./amps_cal.sh

atlantisMerged -i AMPS.nc 0 -o AMPS_OUT.nc -r PugetSound_run.prm -f PugetSound_force.prm -p PugetSound_physics.prm -b AMPSbioparam_mv1_2022.prm  -h PugetSound_harvest_mfc_tuned.prm -e VMPA_setas_economics.prm -s PugetSoundAtlantisFunctionalGroups_salmon_rectype4_bf.csv -q PugetSound_fisheries.csv -m PugetMigrations_mod_bf.csv -d outputFolder 2>outamps    

if [ -d $HOME/bin ]; then
PATH=$PATH:$HOME/bin
fi
