#!/bin/sh
# Script for taking s6-log directories made in /run/log for read-only root mounts and migrating them to /var/log

if ! [ -d /run/log ]; then
	exit 0
fi

for path in /run/log/*/; do
	dir=$(basename "${path}")
	install -d -o s6log -g s6log /var/log/"${dir}"
	s_files=$(find /run/log/"${dir}" -type f -name "*.s" | wc -l)
	u_files=$(find /run/log/"${dir}" -type f -name "*.u" | wc -l)
	if [ "${s_files}" != 0 ]; then
		cp /run/log/"${dir}"/*.s /var/log/"${dir}"
	fi
	if [ "${u_files}" != 0 ]; then
		cp /run/log/"${dir}"/*.u /var/log/"${dir}"
	fi
	if [ -f /var/log/"${dir}"/current ]; then
		cat /run/log/"${dir}"/current >> /var/log/"${dir}"/current
	else
		install -m 0744 -o s6log -g s6log /run/log/"${dir}"/current /var/log/"${dir}"/current
	fi
	if [ -d /run/s6-rc/servicedirs/"${dir}"-log ]; then
		s6-svc -r /run/s6-rc/servicedirs/"${dir}"-log
	fi
done
