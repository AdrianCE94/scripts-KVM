#!/bin/bash
## autor : Adrián Cabezuelo Expósito

# Esto es un script de bash para automatizar la creacion de maquinas virtuales en KVM


# FUNCIONES

menu(){

    clear
    echo "Bienvenido al menú de creacion de maquinas virtuales"
    echo "************************************"
    echo "1. Crear una maquina virtual"
    echo "2. Eliminar una maquina virtual"
    echo "3. Salir"
}

crear_maquina(){
    #pedir datos necesarios para la maquina, nonmbre,RAM,HD,SO,numero cpus y red.Nos dará la posibilidad de crear otra maquina.
    read -p "Introduce el nombre de la maquina: " nombre
    read -p "Introduce la ruta completa de la imagen ISO: " iso
    read -p "Introduce la cantidad de HD en GB: " hd
    read -p "Introduce la cantidad de RAM en MB: " ram
    read -p "Introduce el numero de cpus: " cpu
    read -p "Introduce la red a la que se conectara: " red
    
    #comprobrobar ruta de la iso
    if [ ! -f "$iso" ]; then
        echo "La ruta de la imagen ISO no es correcta"
        exit 1
    fi
    #creamos la maquina
    virt-install --connect qemu:///system --virt-type kvm --name $nombre --cdrom $iso --osinfo detect=on --disk size=$hd --memory $ram --vcpus $cpu --network network=$red
    echo "Creando la maquina en KVM....."
    echo "La maquina $nombre se ha creado con exito"
    read -p "Desea crear otra maquina? (s/n): " opcion
    if [ "$opcion" == "s" ]; then
        crear_maquina
    fi
}

eliminar_maquina(){
    
    echo "=======MAQUINAS DISPONIBLES PARA BORRAR=============="
    virsh list --all
    echo "*******************************************************"
    read -p "Introduce el nombre de la máquina a eliminar: " nombre
    if virsh list --all | grep -q "$nombre"; then
        virsh destroy "$nombre"
        virsh undefine "$nombre" --remove-all-storage
        echo "La máquina $nombre ha sido eliminada."
    else
    echo "La máquina $nombre no existe."
    fi

}

# INICIO

menu
read -p "Introduce una opcion: " opcion
while [ "$opcion" != 3 ]
do
    case $opcion in
        1)
            crear_maquina
            ;;
        2)
            eliminar_maquina
            ;;
        *)
            echo "Opción no valida"
            ;;
    esac
    read -p "INTRO PARA CONTINUAR" INTRO
    menu
    read -p "Introce una opción del menú: " opcion
done