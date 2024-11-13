#!/bin/bash
## autor : Adrián Cabezuelo Expósito

# Esto es un script de bash para automatizar la creacion de maquinas virtuales en KVM


# FUNCIONES

menu(){

    clear
    echo "Bienvenido al menu de creacion de maquinas virtuales"
    echo "************************************"
    echo "1. Crear una maquina virtual"
    echo "2. Ver las maquinas virtuales"
    echo "3. Eliminar una maquina virtual"
    echo "4. Salir"
}

crear_maquina(){
    #pedir datos necesarios para la maquina, nonmbre,RAM,HD,SO,numero cpus y red.Nos dará la posibilidad de crear otra maquina.
    read -p "Introduce el nombre de la maquina: " nombre
    read -p "Introduce la ruta completa de la imagen ISO: " iso
    read -p "Introduce la cantidad de HD en GB: " hd
    read -p "Introduce la cantidad de RAM en MB: " ram
    read -p "Introduce el numero de cpus: " cpu
    read -p "Introduce la red a la que se conectara: " red
    

    #creamos la maquina
    virt-install--connect qemu:///system--virt-typekvm--name $nombre --cdrom $iso --osinfo detect=on --disksize=$hd --memory $ram --vcpus $cpu 
    echo "Creando....."
    echo "La maquina $nombre se ha creado con exito"
    read -p "Desea crear otra maquina? (s/n): " opcion
    if [ $opcion == "s" ]; then
        crear_maquina
    fi
}

ver_maquinas(){
    #nos muestra las maquinas que tenemos creadas
    echo "Las maquinas virtuales que tenemos son: "
    virsh list --all

}

eliminar_maquina(){
    ver_maquinas
    echo "=======MAQUINAS DISPONIBLES PARA BORRAR=============="
    virsh list --all
    echo "*******************************************************"
    read -p "Introduce el nombre de la maquina a eliminar: " nombre
    virsh destroy $nombre 
    virsh undefine $nombre --remove-all-storage
    echo "Eliminando $nombre....."
    echo "La maquina $nombre se ha eliminado"
}

# INICIO

menu
read -p "Introduce una opcion: " opcion
while [ "$opcion" !=4 ]
do
    case $opcion in
        1)
            crear_maquina
            ;;
        2)
            ver_maquinas
            ;;
        3)
            eliminar_maquina
            ;;
        *)
            echo "Opción no valida"
            ;;
    esac
    read -p "Introduce una opcion: " opcion
    menu
    read -p "Introduce una opcion: " opcion
done