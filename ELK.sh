#!/bin/bash

# Fonction pour afficher un message
function log {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log "Mise à jour du système..."
apt update && apt upgrade -y

log "Installation de Java requis par Elasticsearch..."
apt install apt-transport-https openjdk-11-jdk -y

log "Ajout de la clé GPG publique d'Elasticsearch..."
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -

log "Ajout du dépôt Elasticsearch..."
sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'

log "Installation d'Elasticsearch..."
apt update && apt install elasticsearch -y

log "Démarrage et activation d'Elasticsearch..."
systemctl start elasticsearch
systemctl enable elasticsearch

log "Vérification du fonctionnement d'Elasticsearch..."
curl -X GET "localhost:9200/"

log "Installation de Logstash..."
apt install logstash -y

log "Création de fichier de configuration Logstash pour les entrées Beats..."
cat <<EOF > /etc/logstash/conf.d/02-beats-input.conf
input {
  beats {
    port => 5044
  }
}
EOF

log "Création de fichier de configuration Logstash pour la sortie Elasticsearch..."
cat <<EOF > /etc/logstash/conf.d/30-elasticsearch-output.conf
output {
  elasticsearch {
    hosts => ["localhost:9200"]
    manage_template => false
    index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
  }
}
EOF

log "Démarrage et activation de Logstash..."
systemctl start logstash
systemctl enable logstash

log "Installation de Kibana..."
apt install kibana -y

log "Configuration de Kibana..."
cat <<EOF > /etc/kibana/kibana.yml
server.port: 5601
server.host: "172.16.50.78"
elasticsearch.hosts: ["http://localhost:9200"]
EOF

log "Démarrage et activation de Kibana..."
systemctl start kibana
systemctl enable kibana

log "Configuration du pare-feu..."
ufw allow 5044/tcp
ufw allow 5601/tcp
ufw allow 9200/tcp

log "Installation et configuration de l'ensemble ELK terminée."
