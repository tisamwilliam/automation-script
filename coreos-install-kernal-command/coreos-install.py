import pyautogui
import time

waiting_time = 5

# secure and device
if_insecure = True
install_dev = "sda"

# image config
download_image_server = "http://10.250.128.15:8080"
image_name = "rhcos-45.raw.gz"

# ignition config
download_ignition_server = "http://10.250.128.15:8080"
ignition_name = "test.ign"

# network
network_interface = "ens18"
ip_addr = "192.168.50.58"
gateway = "192.168.50.253"
net_mask = "255.255.255.0"
nameserver = "8.8.8.8"

# hostname
hostname = "master9.ocp.satellite.com"


time.sleep(waiting_time)

if if_insecure:
    pyautogui.write(f'coreos.inst.insecure coreos.inst.install_dev={install_dev} coreos.inst.image_url={download_image_server}/{image_name} coreos.inst.ignition_url={download_ignition_server}/{ignition_name} ip={ip_addr}::{gateway}:{net_mask}:{hostname}:{network_interface}:none nameserver={nameserver}', interval=0.01)
else:
    pyautogui.write(f'coreos.inst.install_dev={install_dev} coreos.inst.image_url={download_image_server}/{image_name} coreos.inst.ignition_url={download_ignition_server}/{ignition_name} ip={ip_addr}::{gateway}:{net_mask}:{hostname}:{network_interface}:none nameserver={nameserver}', interval=0.01)