#!/bin/python
import sys
import json
import libvirt
from terraform_external_data import terraform_external_data


config = open("spec.json", "r")
json_spec = json.loads(config.read())
domains = json_spec['domains']
defaults = json_spec['defaults']


definitions = []

def libvirt_callback(userdata, err):
    pass

class libvirt_communications:
    def __init__(self):
        libvirt.registerErrorHandler(f=libvirt_callback, ctx=None)
        conn = libvirt.open('qemu:///system')
        if conn == "None":
            #print("Failed to open connection to qemu:///system")
            exit(1)
        #print("Connected")
        self.conn = conn

    def _get_volume_path(self, _pool, _volume, conn):
        pool = conn.storagePoolLookupByName(_pool)
        #print("Refreshing volumes")
        pool.refresh()
        volume = pool.storageVolLookupByName(_volume)
        return volume

    def create_empty_volume(self,_pool, _volume,capacity, conn):
        pool = conn.storagePoolLookupByName(_pool)
        destination_xml = """
            <volume>
              <name>"""+str(_volume)+"""</name>
              <allocation>0</allocation>
              <capacity unit="G">"""+capacity+"""</capacity>
            </volume>"""
        stgvol = pool.createXML(destination_xml, 0)

    def _clone_template(self, _pool, _template, _vm_template_image, conn):
        pool = conn.storagePoolLookupByName(_pool)
        #print("Refreshing volumes")
        pool.refresh()
        self._pool = _pool
        self._template = _template
        self._vm_template_image = _vm_template_image
        volume = pool.storageVolLookupByName(_template)
        source_path = volume.path()
        destination_xml = """
          <volume>
            <name>"""+str(_vm_template_image)+"""</name>
            <target>
                <path>"""+str(source_path)+"""</path>
                <format type='qcow2'/>
                <compat>1.1</compat>
            </target>
          </volume>"""
        #print('Cloning ' + str(_template) + " to " + str(_vm_template_image))
        stgvol = pool.createXMLFrom(destination_xml, volume, 0)

    def _volume_exist(self, _pool, _volume, conn):
        pool = conn.storagePoolLookupByName(_pool)
        pool.refresh()
        try:
            volume = pool.storageVolLookupByName(_volume)
        except libvirt.libvirtError as e:
            return False
        else:
            return True


def get_disks(root_disk_template):
    OSDisk = root_disk_template
    #print("Received disks: " + str(OSDisk))

vm = libvirt_communications()
for VM in domains:
    additionals = ""
    VMName = VM['name']
    print("Working on VM: " + str(VMName))
    if "root_disk_template" not in  VM:
        #print("Using default OS template: " + str(defaults['default_os_disk_template']))
        root_template = defaults['default_os_disk_template']
        root_template_pool = defaults['default_os_disk_template_pool']
    else:
        root_template = VM['root_disk_template']
        root_template_pool = VM['root_disk_pool']
    cpu = VM['cpu']
    memory = VM['memory']
    if "additional_disks" in VM:
        additionals = VM['additional_disks']
        #for disk in additionals: 
        #    #print(disk)
    FullDiskName = str(VMName) + "-" + str(root_template) + ".qcow2"
    print("Will create OS disk with name: " + str(FullDiskName) + ".qcow2 in pool: " + str(root_template_pool))
    if vm._volume_exist(root_template_pool, root_template, vm.conn):
        if vm._volume_exist(root_template_pool, FullDiskName, vm.conn):
            print("OS disk: " + str(FullDiskName) + " already exists")
            volume = vm._get_volume_path(root_template_pool, FullDiskName, vm.conn)
            path = volume.path()
        else: 
            vm._clone_template(root_template_pool, root_template, FullDiskName, vm.conn)
            volume = vm._get_volume_path(root_template_pool, FullDiskName, vm.conn)
            path = volume.path()
    else:
        pass
        print("Template volume does not exists")
    disks = {}
    disks = {}
    diskMap = []
    for additional in additionals:
        print(additional)
        diskName = VMName + "-" + str(additional['name'] + ".qcow2")
        capacity = additional['size']
        if "pool" in additional:
            pool = additional['pool']
        else:
            pool = root_template_pool
        #print("Will create additional disk with name: " + str(diskName) + " in pool: " + str(pool))
        if vm._volume_exist(pool, diskName, vm.conn):
        #    print("Additional disk: " + str(diskName) + " already exists")
            volume = vm._get_volume_path(pool, diskName, vm.conn)
            path_disk = volume.path()
        else: 
            vm.create_empty_volume(pool, diskName, capacity, vm.conn)
            volume = vm._get_volume_path(pool, diskName, vm.conn)
            path_disk = volume.path()
        disks.update({additional['name']: {'name':  path_disk }})
        #disks.update({'name':path_disk})
    definitions.append({'name': VMName, 'memory': memory, 'cpu': cpu, "OSDisk": path,"additional_disks":[disks] })

specification = json.dumps(definitions)
print(type(specification))
print(type(definitions))
f = open("definitions.json", "w")
f.write(specification)
f.close()



