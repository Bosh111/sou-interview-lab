# sou-interview-lab

----------ITA----------
Ciao,

In questo README troverete:

1) Richiesta e Riluzione (codice necessario commentato).
2) Come testare la soluzione.
3) Commenti progetto.

----------Richiesta e Riluzione----------

Richiesta: Creare un progetto Vagrant in cui due nodi Linux, con docker, si alternano ogni 60 secondi nell'eseguire il seguente container https://hub.docker.com/r/ealen/echo-server.

Risoluzione: sono stati identificati 2 step per risolvere la richiesta:

1) creazione di un progetto vagrant per creare i due nodi--> Vagrantfile dove indicare come creare i due nodi, di seguito commentato:


Vagrant.configure("2") do |config|                      #il 2 specifica la configuration version,"do config" definisce la configurazione dell'ambiente Vagrant
  config.vm.define "ping" do |node1|                    #chiamiamo il primo nodo "ping". La variabile locale "node 1" è usata per configurarlo.
    node1.vm.box = "ubuntu/bionic64"                    #Indichiamo il Vagrant box da utilizzare. E' un pacchetto contenente un immagine di SO base. 
    node1.vm.network "private_network", type: "dhcp"    #Definiamo che la VM usi private network con DHCP. In questo caso un IP è assegnato automaticamente. 
    node1.vm.provision "docker"                         #La VM potrà comunicare con l'host e tutte le altre VM, ma non con il pubblico.
  end                                                   #Infine linea 25 indica di installare docker sul nodo. "provision" permette di definire software
                                                        #da installare sul nodo una volta creato.
  config.vm.define "pong" do |node2|                    
    node2.vm.box = "ubuntu/bionic64"
    node2.vm.network "private_network", type: "dhcp"
    node2.vm.provision "docker"
  end
end

2) creazione di uno script in bash che alterni l'esecuzione del container sui due nodi. Di seguito lo script commentato:

#!/bin/bash

CONTAINER_NAME="Ping_Pong"
IMAGE_NAME="ealen/echo-server"

start_container() {
  local node=$1
  vagrant ssh $node -c "docker pull $IMAGE_NAME && docker run -d -p 3000:80 --name $CONTAINER_NAME $IMAGE_NAME"
}

stop_container() {
  local node=$1
  vagrant ssh $node -c "docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME"
}

cleanup() {
  echo "Stopping and removing containers on Ping and Pong"
  stop_container "Ping"
  stop_container "Pong"
  exit 0
}

# Set up trap to catch SIGINT (Ctrl + C) and run the cleanup function
trap cleanup SIGINT

while true; do
  echo "Starting container on Ping"
  start_container "Ping"
  sleep 60

  echo "Stopping container on Ping"
  stop_container "Ping"
  echo "container stopped"

  echo "Starting container on Pong"
  start_container "Pong"
  sleep 60

  echo "Stopping container on Pong"
  stop_container "Pong"
  echo "container stopped"
done

----------TEST----------

Necessario:
-Vagrant
-VirtualBox (o simili).
-IP dei due nodi Ping e Pong    
    #vagrant ssh <Ping o Pong> -c "ip a" 
    
comando per testare dal proprio pc:
    vagrant init
    vagrant up
    ./container_switch.sh

    curl <ip Ping o Pong>:3000
------------------------

-------workprocess-------
Di seguito la serie di step che sono stati eseguiti:

1) Comprensione rishiesta
2) Mi sono informato sulle tecnologie che non conoscevo
3) Schematizzazionione risoluzione --> VMS Linux con Vagrant (+VirtalBox) + Docker + container preso da dockerhub + bash per switch
4) Stesura primo codice
5) Test
6) Modifiche codice --> Risoluzione issue su rerun consecutive + migliorati output di console
7) test --> OK
8) Stesura README.md
9) Creazione repo Github & Push