awk -F'=| ' '$0!~/masters|workers/ {print $1, $3}' provisioning/inventory/production | while read hostname ip;do
  sh vmware-do.sh $hostname $ip
done
