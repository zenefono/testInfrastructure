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


## Creazione ed impostazione della infrastruttura sull'host

Clono questo stesso repository pubblico da GitHub con il comando `git clone https://github.com/zenefono/test_bryanpedini-deployments.git`.
Entro nella cartella, do i permessi d'esecuzione al file install.sh con i comandi `cd ./test_bryanpedini-deployments && chmod +x ./install.sh`.
Copio il file d'esempio `example.env` in `.env` e lo modifico secondo le mie esigenze.
Eseguo il file `./install.sh` per scaricare i repo dell'infrastruttura ed impostarli secondo il mio file `.env`.
Mi reco nella cartella col file `docker-compose.yml` di Traefik e lo lancio con il comando `docker-compose up`.


## Condizione finale
Il container sembra avviarsi correttamente ma, puntando il browser alla dashboard...

