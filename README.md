# sou-interview-lab
Ciao,

In questo README troverete:

1) Richiesta e Riluzione (con codice necessario commentato).
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
  config.vm.define "pong" do |node2|                    #Procedimento analogo per il secondo nodo, l'unica differenza è il nome: pong
    node2.vm.box = "ubuntu/bionic64"
    node2.vm.network "private_network", type: "dhcp"
    node2.vm.provision "docker"
  end
end

2) creazione di uno script in bash che alterni l'esecuzione del container sui due nodi. Di seguito lo script commentato:
#shebang - lo script deve essere runnato con bash shell
#!/bin/bash
#nome che vogliamo dare al nostro Docker container
CONTAINER_NAME="Ping_Pong"
#nome Docker image che vogliamo utilizzare                                                      
IMAGE_NAME="ealen/echo-server"

#funzione per startare il container su un nodo dato. Pull immagine richiesta, mappatura porta 3000 dell'host come la 80 del container.
start_container() {
  local node=$1
  vagrant ssh $node -c "docker pull $IMAGE_NAME && docker run -d -p 3000:80 --name $CONTAINER_NAME $IMAGE_NAME"
}

#funzione per stoppare il container su un nodo dato. Stoppa ed elimina il container. "> /dev/null" è stato inserito per pulire l'output in console.
stop_container() {
  local node=$1
  vagrant ssh $node -c "docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME > /dev/null""
}
 
#dopo la prima fase di test, mi sono accorto che nel caso lo script venisse fermato in qualsiasi fase, tranne quella di stop di un container, facendo partire #nuovamente lo script saremmo incappati in errore perchè il container risulta già esistente su uno dei due nodi.  
#di consguenza è stata creata la funzione cleanup, che viene trigerata quando viene stoppato lo script con ctrl+C. Semplicemente va a rimuovere il container #su entrambi i nodi. Anche qui "> /dev/null" è stato inserito per pulire l'output in console. 
cleanup() {
  echo "Stopping and removing containers on Ping and Pong"
  stop_container "ping" > /dev/null
  stop_container "pong" > /dev/null
  exit 0
}

#viene settata la "trap" per SIGINT (segnale generato da ctrl+C), che triggera la funzione cleanup.
trap cleanup SIGINT

#qui viene definito il loop, in questo caso infinito, che va ad eseguire i comandi di start e stop container sui due nodi, alternandosi ogni 60 secondi.
while true; do
  echo "Starting container on node ping"
  start_container "ping"
  echo "Started container on ping"
  sleep 60

  echo "Stopping container on node ping"
  stop_container "ping"
  echo "Container stopped"

  echo "Starting container on node pong"
  start_container "pong"
  echo "Started container on pong"
  sleep 60

  echo "Stopping container on node pong"
  stop_container "pong"
  echo "Container stopped"
done

----------Come Testare la soluzione----------

Necessario:
-Vagrant
-VirtualBox (o simili).
-IP dei due nodi ping e pong. Può essere estratto dall'output di questo comando: vagrant ssh <ping o pong> -c "ip a"  
    
Comandi per test:
    cd "cartella dove sono stati scaricati i file"
    vagrant up
    ./container_switch.sh (ctrl+C quando si vuole fermare l'esecuzione)

    test in un altra shell:
    curl <ip ping o pong>:3000/param?query=pingpong
    nell'output cercare il campo "query" e verificare che il valore sia "pingpong" 

----------Commenti progetto----------
Vagrant ci permette di costruire e gestire ambienti di macchine virtuali con un unico workflow. Per farlo, si appoggia lato provisioning su VirtualBox, VMware e tutti gli altri maggiori provider, in questo progetto è stato scelto VirtualBox. 
La comodità è che la configurazione dell'ambiente avviene tutta nel Vagrantfile, dove si indicano che nodi si vuole creare e che software installare su di essi. La persona che vorrà replicare l'ambiente sul proprio pc, dovrà solamente scaricare il Vagrantfile ed eseguire "vagrant up" per ritrovarsi tutte le VM pronte all'utilizzo. In questo progetto è stato scelto come VagrantBox ubuntu/bionic64 e Docker come software per la gestione dei container sui nodi.
Per la gestione del "pingpong" sui due nodi, è stato usato uno script in bash molto lineare.
Il codice è stato scritto in inglese per comodità personale.

Di seguito ho voluto inserire la serie di step che sono stati eseguiti per la risoluzione dell'esercizio:

1) Comprensione rishiesta
2) Mi sono informato sulle tecnologie che non conoscevo
3) Schematizzazione risoluzione --> VMS Linux con Vagrant (+VirtalBox) e Docker + container preso da dockerhub + script bash per switch fra nodi
4) Stesura primo codice
5) Test
6) Modifiche codice --> Risoluzione issue su rerun consecutive + migliorati output di console
7) Test2 --> OK
8) Stesura README.md
9) Creazione repo Github & Push