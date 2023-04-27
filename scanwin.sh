#!/bin/bash

# Define o endereço IP do gateway padrão da rede
GATEWAY_IP="192.168.1.1"

# Define o nome do arquivo de log para registrar as atividades do teste
LOG_FILE="test_log.txt"

# Escaneia a rede para identificar todos os dispositivos ativos usando o nmap e o arp-scan
nmap -sn $GATEWAY_IP/24 | grep "report for" | cut -d " " -f 5 | sed 's/(//' | sed 's/)//' > active_hosts.txt
arp-scan -l | grep -v "Interface" | grep -v "Starting" | grep -v "packets" | cut -f 2 > active_hosts.txt

# Adiciona uma entrada de log com a data e hora atuais
echo "$(date) - Varredura de rede concluída" >> $LOG_FILE

# Loop que executa o teste de penetração em cada dispositivo identificado
while read -r target_ip; do
    echo "$(date) - Iniciando teste de penetração em $target_ip" >> $LOG_FILE
    # Executa o Metasploit ou outras ferramentas de teste de penetração no dispositivo
    msfconsole -q -x "use auxiliary/scanner/smb/smb_ms17_010; set RHOSTS $target_ip; run"
    msfconsole -q -x "use auxiliary/scanner/http/robots_txt; set RHOSTS $target_ip; run"
    msfconsole -q -x "use auxiliary/scanner/http/title; set RHOSTS $target_ip; run"
    msfconsole -q -x "use auxiliary/scanner/http/webdav_scanner; set RHOSTS $target_ip; run"
    msfconsole -q -x "use auxiliary/scanner/http/wp_admin_urls; set RHOSTS $target_ip; run"
    echo "$(date) - Teste de penetração concluído em $target_ip" >> $LOG_FILE
done < active_hosts.txt

# Exibe uma mensagem indicando que o teste foi concluído
echo "Teste de penetração em todos os dispositivos ativos na rede concluído. Veja o arquivo de log para mais detalhes."
