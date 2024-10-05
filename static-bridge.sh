## autor : Adrián Cabezuelo Expósito

# Esto es un script de bash para automatizar la configuracion de red de KVM
# Para la bridge-static

# FUNCIONES

menu(){
    
        clear
        echo "Bienvenido al menu de configuracion de red"
        echo "************************************"
        echo "1. Ver configuración de la red"
        echo "2. Definir la red"
        echo "3. Ver que existe un bridge y que esta asociado a una interfaz ensXX"
        echo "4. Activar/Apagar la red"
        echo "5. Mofidicar la configuracion de la red bridge-static"
        echo "6. Exit"
}

ver_configuracion(){
    echo "La configuracion de la red bridge-static es: "
    virsh net-list --all
}

definir_red(){
    read -p "Introduce el nombre del bridge: " nombre
    read -p "Introduce la interfaz a asociar(ensXX): " interfaz
    cat <<EOF > /tmp/$nombre.xml
<network>
    <name>$nombre</name>
    <forward mode='bridge'/>
    <bridge name='$nombre'/>
</network>
EOF
    virsh net-define /tmp/$nombre.xml
    virsh net-start $nombre
    virsh net-autostart $nombre
    virsh net-list --all
    echo "Creando....."
    echo "La red bridge-static se ha definido"
}

ver_bridge(){
    read -p "Introduce el nombre del bridge: " nombre
    brctl show $nombre
    echo "************************************"
    virsh net-info $nombre
}

activar_red(){
    read -p "Introduce el nombre de la red: " nombre
    read -p "Desea activar o desactivar la red? (start/destroy): " opcion
    virsh net-start $opcion $nombre
    virsh net-list --all
    echo "************************************"
    echo "La red $nombre ha sido $opcion"
}

modificar_red(){
    read -p "Introduce el nombre de la red que quiere modificar: " nombre
    virsh net-edit $nombre
}

# INICIO

menu
read -p "Introduce una opcion: " opcion
while [ $opcion !=6 ]
do
    case $opcion in
        1) ver_configuracion;;
        2) definir_red;;
        3) ver_bridge;;
        4) activar_red;;
        5) modificar_red;;
        *) echo "Opción no valida";;
    esac
    read -p "Introduce una opcion: " opcion
    menu
    read -p "Introduce una opcion: " opcion
done