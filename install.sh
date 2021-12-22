#! /bin/bash

source ./.env

# TODO: sostituire bjphoster[ecc...] con variabili da ./.env;
#+ anche in ./traefik[ecc..]/docker-compose.yml bisognerebbe sempre usare variabili,
#+ in /get[ecc..]/docker-compose.yml sembra a posto ma ricontrolla

changeBjphosterDomain(){ # usage: changeBjphoster "${serviceName}"
	for i in ./"${serviceName}"."${hostDomain}"/* ; do
		for myCmd in "s/.bjphoster.com/.host.domain/g" "s/_bjphoster_com/_host_domain/g" \
		"s/bjphostercom/hostdomain/g" ; do
			sed -i "$myCmd" "$i"
		done
	done
}

setupServiceTraefik(){
	
	changeBjphosterDomain "${serviceName}"
	
	sed -i "s/1.2.3.4/${ENVadminClientData[ipaddr]}/g" ./"${serviceName}"."${hostDomain}"/"${dotEnvModel}"
	
	sed -i "s/HETZNER_API_KEY=/HETZNER_API_KEY=${ENVcertificateProviderData[apykey]}/g" ./"${serviceName}"."${hostDomain}"/"${dotEnvModel}"
	
	touch ./"${serviceName}"."${hostDomain}"/le-certs.json
	
	chmod 600 ./"${serviceName}"."${hostDomain}"/le-certs.json
}

setupServiceGet(){
	
	changeBjphosterDomain "${serviceName}"
	
	sed -i "s|root /var/www/html;|root /var/www/html;\n  autoindex on;|" ./"${serviceName}"."${hostDomain}"/conf/site.conf
}

setupFromPublicRepo(){ # usage: setupFromPublicRepo "hostDomain" "serviceName" "publicRepoUri" "dotEnvModel" "dataFolder" "configFolder"
	hostDomain="${1}"
	serviceName="${2}"
	publicRepoUri="${3}"
	dotEnvModel="${4}"
	
	echo "clone ${serviceName} service public repo for ${hostDomain}"
	
	git clone "${publicRepoUri}" ./"${serviceName}.${hostDomain}"
	
	rm -rf ./"${serviceName}.${hostDomain}"/.git
	
	mv ./"${serviceName}"."${hostDomain}"/"${dotEnvModel}" ./"${serviceName}"."${hostDomain}"/.env
	
	setupService"${serviceName^}" # bash (v. 4+) capitalized variable
}

##########################################

main() {
	setupFromPublicRepo "${ENVhostServerData[domain]}" "${ENVreverseProxyData[name]}" "${ENVreverseProxyData[repo]}" "${ENVreverseProxyData[envmodel]}"
	
	setupFromPublicRepo "${ENVhostServerData[domain]}" "${ENVtestServiceData[name]}" "${ENVtestServiceData[repo]}" "${ENVtestServiceData[envmodel]}"
}

main
exit 0
