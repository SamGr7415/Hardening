#!/bin/bash

# Fonction pour afficher un message
function log {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log "Mise à jour du système..."
apt update && apt upgrade -y

log "Ajout de la clé GPG publique d'Elasticsearch..."
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -

log "Ajout du dépôt Filebeat..."
sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'

log "Installation de Filebeat..."
apt update && apt install filebeat -y

log "Configuration de Filebeat pour envoyer les journaux à Logstash..."
cat <<EOF > /etc/filebeat/filebeat.yml
output.logstash:
  hosts: ["172.16.50.78:5044"]
EOF

log "Activation des modules Filebeat (system)..."
filebeat modules enable system

log "Chargement du modèle Filebeat dans Elasticsearch..."
filebeat setup

log "Démarrage et activation de Filebeat..."
systemctl start filebeat
systemctl enable filebeat

log "Installation et configuration de Filebeat terminée."
