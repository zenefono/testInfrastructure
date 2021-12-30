#! /bin/bash

source ./.env

sedDomain(){ # usage: changeBjphosterDomain "${serviceName}" "${egDomain}" "${hostDomain}"
	egDomain0=$(echo "${egDomain}" | sed 's/\./\\\./g')
	egDomain1=$(echo "${egDomain}" | sed 's/\./_/g')
	egDomain2=$(echo "${egDomain}" | sed 's/\.//g')
	hostDomain0=$(echo "${hostDomain}" | sed 's/\./\\\./g')
	hostDomain1=$(echo "${hostDomain}" | sed 's/\./_/g')
	hostDomain2=$(echo "${hostDomain}" | sed 's/\.//g')
	for myFile in ./"${serviceName}"."${hostDomain}"/* ; do
		for mySed in "s/${egDomain0}/${hostDomain0}/g" "s/${egDomain1}/${hostDomain1}/g" \
		"s/${egDomain2}/${hostDomain2}/g" ; do
			sed -i "$mySed" "$myFile"
		done
	done
}

setupServiceTraefik(){	
	sedDomain "${serviceName}" "${hostDomain}"
	
	sed -i "s/1.2.3.4/${ENVadminClientData[ipaddr]}/g" ./"${serviceName}"."${hostDomain}"/"${dotEnvModel}"
	
	sed -i "s/HETZNER_API_KEY=/HETZNER_API_KEY=${ENVdnsProviderData[apikey]}/g" ./"${serviceName}"."${hostDomain}"/"${dotEnvModel}"
	
	touch ./"${serviceName}"."${hostDomain}"/le-certs.json
	
	chmod 600 ./"${serviceName}"."${hostDomain}"/le-certs.json
}

setupServiceGet(){
	
	sedDomain "${serviceName}" "${hostDomain}"
	
	sed -i "s|root /var/www/html;|root /var/www/html;\n  autoindex on;|" ./"${serviceName}"."${hostDomain}"/conf/site.conf
}

setupFromPublicRepo(){ # usage: setupFromPublicRepo "hostDomain" "serviceName" "publicRepoUri" "egDomain" "dotEnvModel" ["dataFolder" "configFolder"]
	hostDomain="${1}"
	serviceName="${2}"
	publicRepoUri="${3}"
	egDomain="${4}"
	dotEnvModel="${5}"
	
	echo "clone ${serviceName} service public repo for ${hostDomain}"
	
	git clone "${publicRepoUri}" ./"${serviceName}.${hostDomain}"
	
	rm -rf ./"${serviceName}.${hostDomain}"/.git
	
	setupService"${serviceName^}" # bash (v. 4+) capitalized variable
	
	mv ./"${serviceName}"."${hostDomain}"/"${dotEnvModel}" ./"${serviceName}"."${hostDomain}"/.env
}

##########################################

main() {
	setupFromPublicRepo "${ENVhostServerData[domain]}" "${ENVreverseProxyData[name]}" \
	"${ENVreverseProxyData[repo]}" "${ENVreverseProxyData[egdomain]}" "${ENVreverseProxyData[envmodel]}"
	
	setupFromPublicRepo "${ENVhostServerData[domain]}" "${ENVtestServiceData[name]}" \
	"${ENVtestServiceData[repo]}" "${ENVtestServiceData[egdomain]}" "${ENVtestServiceData[envmodel]}"
	
#	cd ./"${ENVreverseProxyData[name]}"."${hostDomain}" && docker-compose up -d
#	cd ../"${ENVtestServiceData[name]}"."${hostDomain}" && docker-compose up -d
#	cd ..
}

main
exit 0
