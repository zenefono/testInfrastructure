# testInfrastructure

![Non funziona, piango](https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/160/mozilla/36/loudly-crying-face_1f62d.png)


## Condizione iniziale

- Account su https://freenom.com
- Account su https://hetzner.com
- VPS Debian su https://contabo.com/ (ha già preinstallato Docker e docker-compose)


## Creazione ed impostazione del dominio gratuito

### Creazione ed impostazione del dominio gratuito su Freenom

Dopo aver effettuato il login al sito, creo un nuovo dominio gratuito dalla pagina https://my.freenom.com/domains.php

Dalla pagina https://my.freenom.com/clientarea.php?action=domains accedo al pannello di controllo del dominio cliccando sul tasto "Manage Domain", poi dal menù "Management Tools" seleziono la voce "Nameservers" e qui "Use custom nameservers (enter below)" dove imposto:
- Nameserver 1: HELIUM.NS.HETZNER.DE
- Nameserver 2: HYDROGEN.NS.HETZNER.COM
- Nameserver 3: OXYGEN.NS.HETZNER.COM

Salvo le impostazioni cliccando su "Change Nameservers"


### Impostazione dei server DNS su Hetzner

Mi reco sulla pagina https://dns.hetzner.com/add-zone , effettuo il login, inserisco il nome della zona DNS e clicco "Continue" senza modificare alcuna impostazione.
Una volta che ha importato tutti i record imposto i valori dei record di tipo A con l'indirizzo IPv4 del mio host e clicco "Continue".
Avendo già impostato i nameservers su Freenom, termino la procedura cliccando su "Finished, go to Dashboard", seleziono dal menù "..." corrispondente alla zona DNS interessata la voce "Edit zone file" ed aggiungo per sicurezza 
```
; Others
@    IN  CAA  0 issue "letsencrypt.org"
```
in coda per dare l'autorizzazione a rilasciare certificati per la mia intera zona DNS solo a Let's Encrypt.
Confermo cliccando su "Save changes". Lo zone file risulta simile a [questo](./zonefile-host.domain.txt)


### Verifica della propagazione dei DNS

Con il comando `dig @1.1.1.1 NS host.domain` verifico nella "ANSWER SECTION" che il dominio punti ai nameservers di Hetzner.


## Installazione ed impostazione del firewall

Dopo essermi connesso tramite SSH al server host, installo UFW (Uncomplicated Firewall) con il comando `sudo apt install ufw`.
Poi abilito le regole per aprire le porte standard per SSG, HTTP e HTTPS con i seguenti comandi:
```
sudo ufw allow OpenSSH
sudo ufw allow http
sudo ufw allow https
```
Infine abilito il firewall con `sudo ufw enable` e verifico l'effettiva attivazione con `sudo ufw status` ottenendo in risposta:
```
Status: active

To                         Action      From
--                         ------      ----
OpenSSH                    ALLOW       Anywhere         
80/tcp                     ALLOW       Anywhere                  
443/tcp                    ALLOW       Anywhere                  
OpenSSH (v6)               ALLOW       Anywhere (v6)             
80/tcp (v6)                ALLOW       Anywhere (v6)             
443/tcp (v6)               ALLOW       Anywhere (v6)
```

## Creazione ed impostazione della infrastruttura sull'host

Per semplificare la ripetizione della procedura ho creato un semplice script, fate riferimento al contenuto di questo stesso repository pubblico, il cui file `install.sh` vi farà poi scaricare due repo altrettanto pubblici da https://github.com/bryanpedini-deployments .

Clono questo repository da GitHub con il comando `git clone https://github.com/zenefono/testInfrastructure.git`.
Entro nella cartella, do i permessi d'esecuzione al file install.sh con i comandi `cd ./test_bryanpedini-deployments && chmod +x ./install.sh`.
Copio il file d'esempio `example.env` in `.env` e lo modifico secondo le mie esigenze.
Eseguo il file `./install.sh` per scaricare i repo dell'infrastruttura ed impostarli secondo il mio file `.env`.
Mi reco nella cartella col file `docker-compose.yml` di Traefik e lo lancio con il comando `docker-compose up`.


## Condizione finale

Il container sembra avviarsi correttamente, questo il log che restituisce:
```
$ docker-compose up
[+] Running 5/5
 ⠿ traefik Pulled                                                          4.3s
   ⠿ ddad3d7c1e96 Pull complete                                            1.0s
   ⠿ 5f6722e60c2f Pull complete                                            1.4s
   ⠿ 3abdcd3bb40c Pull complete                                            3.1s
   ⠿ fe4701c53ae5 Pull complete                                            3.3s
[+] Running 1/1
 ⠿ Container traefik.host.domain  Creat...                                 0.2s
Attaching to traefik.host.domain
traefik.billodog.ga  | time="2021-12-30T13:56:33Z" level=info msg="Configuration loaded from flags."
traefik.billodog.ga  | time="2021-12-30T13:56:33Z" level=info msg="Traefik version 2.4.14 built on 2021-08-16T15:29:25Z"
traefik.billodog.ga  | time="2021-12-30T13:56:33Z" level=info msg="\nStats collection is disabled.\nHelp us improve Traefik by turning this feature on :)\nMore details on: https://doc.traefik.io/traefik/contributing/data-collection/\n"
traefik.billodog.ga  | time="2021-12-30T13:56:33Z" level=info msg="Starting provider aggregator.ProviderAggregator {}"
traefik.billodog.ga  | time="2021-12-30T13:56:33Z" level=info msg="Starting provider *file.Provider {\"directory\":\"/dynamic-config\",\"watch\":true}"
traefik.billodog.ga  | time="2021-12-30T13:56:33Z" level=info msg="Starting provider *traefik.Provider {}"
traefik.billodog.ga  | time="2021-12-30T13:56:33Z" level=info msg="Starting provider *docker.Provider {\"watch\":true,\"endpoint\":\"unix:///var/run/docker.sock\",\"defaultRule\":\"Host(`{{ normalize .Name }}`)\",\"swarmModeRefreshSeconds\":\"15s\"}"
traefik.billodog.ga  | time="2021-12-30T13:56:33Z" level=info msg="Starting provider *acme.Provider {\"email\":\"admin@mydomain.com\",\"caServer\":\"https://acme-v02.api.letsencrypt.org/directory\",\"storage\":\"/le-certs.json\",\"keyType\":\"RSA4096\",\"dnsChallenge\":{\"provider\":\"hetzner\"},\"ResolverName\":\"letsencrypt\",\"store\":{},\"TLSChallengeProvider\":{\"Timeout\":4000000000},\"HTTPChallengeProvider\":{}}"
traefik.billodog.ga  | time="2021-12-30T13:56:33Z" level=info msg="Testing certificate renew..." providerName=letsencrypt.acme
traefik.billodog.ga  | time="2021-12-30T13:56:33Z" level=info msg="Starting provider *acme.ChallengeTLSALPN {\"Timeout\":4000000000}"
traefik.billodog.ga  | time="2021-12-30T14:06:34Z" level=warning msg="A new release has been found: 2.5.6. Please consider updating."
```
ma puntando il browser alla dashboard ottengo solo "Unable to connect" :sob:


### Ulteriori test

Se eseguo i comandi `ping host.domain` o `ping 123.456.78.9` il server risponde adeguatamente, se provo invece uno dei seguenti comandi:
```
ping host.domain:1234
ping host.domain:80
ping 123.456.78.9:80
ping host.domain:443
ping 123.456.78.9:443
```
ottengo sempre `ping: unknown host ...`
