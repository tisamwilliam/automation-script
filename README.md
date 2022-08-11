# automation-script
工作上的自動腳本

## Shutdown Unregister
**腳本用途**  
在關機前執行RHEL unregister，避免刪除虛擬機前忘記解除註冊造成資源占用

**腳本設定**  
shutdown-unregister.service path: /etc/systemd/system/  
shutdown-unregister-rhel.sh path: /usr/bin  

```shell
cp shutdown-unregister.service /etc/systemd/system
cp shutdown-unregister-rhel.sh /usr/bin

systemctl daemon-reload
systemctl enable shutdown-unregister.service
```
## Coreos-install input helper
**腳本用途**  
在沒有開啟copy paste的虛擬機環境快速設定coreos-install的kernel參數  
**腳本設定**   
```shell
python coreos-install.py
``` 