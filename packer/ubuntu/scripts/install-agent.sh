/opt/agent/config.sh --unattended \
                     --url 'https://dev.azure.com/GilmanLab' \
                     --auth pat \
                     --token $TOKEN \
                     --pool Lab \
                     --agent UBAgent \
                     --replace \
                     --acceptTeeEula
sudo /opt/agent/svc.sh install
sudo /opt/agent/svc.sh start