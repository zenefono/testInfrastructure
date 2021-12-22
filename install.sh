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

setupService"${ENVreverseProxyData[name]^}"(){
	
	changeBjphosterDomain "${ENVreverseProxyData[name]}"
	
	sed -i "s/1.2.3.4/${ENVadminClientData[ipaddr]}/g" ./"${ENVreverseProxyData[name]}"."${hostDomain}"/"${dotEnvModel}"
	
	sed -i "s/HETZNER_API_KEY=/HETZNER_API_KEY=${ENVcertificateProviderData[apykey]}/g" ./"${ENVreverseProxyData[name]}"."${hostDomain}"/"${dotEnvModel}"
	
	mv ./"${ENVreverseProxyData[name]}"."${hostDomain}"/"${dotEnvModel}" ./"${ENVreverseProxyData[name]}"."${hostDomain}"/.env
	
	touch ./"${ENVreverseProxyData[name]}"."${hostDomain}"/le-certs.json
	
	chmod 600 ./"${ENVreverseProxyData[name]}"."${hostDomain}"/le-certs.json
}

setupService"${ENVtestServiceData[name]^}"(){
	
	changeBjphosterDomain "${ENVtestServiceData[name]}"
	
	sed -i "s|root /var/www/html;|root /var/www/html;\n  autoindex on;|" ./"${ENVtestServiceData[name]}"."${hostDomain}"/conf/site.conf
}

setupFromPublicRepo(){ # usage: setupFromPublicRepo "hostDomain" "serviceName" "publicRepoUri" "dotEnvModel" "dataFolder" "configFolder"
	hostDomain="${1}"
	serviceName="${2}"
	publicRepoUri="${3}"
	dotEnvModel="${4}"
	
	echo "clone ${serviceName} service public repo for ${hostDomain}"
	
	git clone "${publicRepoUri}" ./"${serviceName}.${hostDomain}"
	
	rm -rf ./"${serviceName}.${hostDomain}"/.git
	
	setupService"${serviceName^}" # bash (v. 4+) capitalized variable
}

##########################################

main() {
	setupFromPublicRepo "${ENVhostServerData[domain]}" "${ENVreverseProxyData[name]}" "${ENVreverseProxyData[repo]}" "${ENVreverseProxyData[envmodel]}"
	
	setupFromPublicRepo "${ENVhostServerData[domain]}" "${ENVreverseProxyData[name]}" "${ENVreverseProxyData[repo]}" "${ENVreverseProxyData[envmodel]}"
}

main
exit 0
