```
# 安装依赖
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients virt-manager openvswitch-switch

# 启动服务
sudo systemctl enable --now libvirtd
sudo systemctl enable --now openvswitch-switch

# 查看 OVS 桥
sudo ovs-vsctl show
cat br-int.yaml
<network>
  <name>br-int</name>
  <forward mode='bridge'/>
  <bridge name='br-int'/>
</network>



virsh net-define br-int.yaml
virsh net-start br-int
virsh net-autostart br-int


virt-install --name cirros-vm1 --ram 512 --vcpus 1 --disk path=/var/lib/libvirt/images/cirros-0.6.3-x86_64-disk.img,format=qcow2 --network network=br-int,model=virtio,virtualport_type=openvswitch,target=vtap1 --import --graphics none --noautoconsole --os-variant=cirros0.5.2
WARNING  KVM acceleration not available, using 'qemu'

Starting install...
Creating domain...                                                                                                                                                                       |    0 B  00:00:00
Domain creation completed.


virsh console cirros-vm1
sudo ip route add default via 192.168.1.1
sudo ip addr add 192.168.1.100 dev eth0
ping 8.8.8.8

```
