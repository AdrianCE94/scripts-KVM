#!/bin/bash

# Autor : Adrián Cabezuelo Expósito
# Este script de bash automatiza la creación de un pool en KVM

# FUNCIONES

#comprobar si kvm esta instalad
comprobarKVM () {
    if [ -z $(which virsh) ]; then
        echo "KVM no está instalado"
        exit 1
    else
        echo "KVM está instalado"
        echo "====================="
    fi
}
comprobarRoot () {
    existe=$(id -u)
    if [ $existe -eq 0 ]; then
        echo "Puedes continuar,eres ROOT"
        echo "================================"
    else
        echo "Debes ser Root para ejecutar este script"
        exit 1
    fi
}
menu(){

    echo "1.Visualizar los pools existentes "
    echo "2.Crear pool "
    echo "3.Creacion de discos duros "
    echo "4.Mostrar información de los discos "
    echo "5.Agregar discos a máquina virtual"
    echo "6.Definir pools con arranque automático "    
    echo "7.Borrado pool "
    echo "8.Generar archivo de pools creados "
    echo "9.salir"
}

option1(){
    virsh pool-list --all
}

option2(){

    read -p "Introduce el nombre del pool: " nombrePool
    echo "Creando pool $nombrePool...."
    mkdir /var/lib/libvirt/$nombrePool
    virsh pool-define-as $nombrePool --type dir --target /var/lib/libvirt/$nombrePool
    virsh pool-start $nombrePool
}


option3(){
    # se le pedira al usuario el numero de discos  y el nombre
    read -p "Introduce el numero de discos duros que quieres crear: " numDiscos
    read -p "Escribe el nombre del pool: " nPool
    for i in $(seq 1 "$numDiscos"); do
        read -p "Introduce el nombre del disco duro $i: " nombreDisco
        read -p "Introduce el tamaño del disco duro $i (en GB): " tamanoDisco
        virsh vol-create-as --pool "$nPool" --format qcow2 "$nombreDisco".qcow2 "$tamanoDisco"G
    done
}

option4(){
    read -p "Introduce el nombre del pool para ver los volumenes: " miPool
    echo "Refrescando pool $miPool...."
    virsh pool-refresh $miPool
    echo "Mostrando información de los discos duros del pool $miPool...."
    virsh vol-list $miPool --details
}

option5(){
    #ver discos disponibles
    #pool disponibles
    virsh pool-list --all
    read -p "Introduce el nombre del pool: " namePool
    virsh vol-list $namePool --details
    read -p "Introduce el nombre de la máquina virtual: " nombreMV
    read -p "Introduce el nombre del disco a agregar(sin la extension): " nombreDisco
    virsh attach-disk "$nombreMV" --source /var/lib/libvirt/$namePool/$nombreDisco.qcow2  vdb --persistent --subdriver qcow2
}

option6(){
    read -p "Introduce el nombre del pool para arranque automático: " poool
    virsh pool-autostart "$poool"
}

option7(){
    echo "Pools existentes"
    virsh pool-list --all
    echo "----------------------------------"
    read -p "Introduce el nombre del pool a borrar: " pool
    virsh pool-destroy $pool
    virsh pool-undefine $pool
    rm -r /var/lib/libvirt/$pool
}

option8(){
    virsh pool-list --all > pools.txt
    echo "Archivo generado con exito"
}


# inicio

comprobarRoot
comprobarKVM
menu
echo ""
read -p "Introduce una opción del menú : " opcion
while [ "$opcion" != 9 ]; do
    case "$opcion" in
        1)
            option1
            ;;
        2)
            option2
            ;;
        3)
            option3
            ;;
        4)
            option4
            ;;
        5)
            option5
            ;;
        6)
            option6
            ;;
        7)
            option7
            ;;
        8)
            option8
            ;;
        *)
            echo "Opción no válida"
            ;;
    esac
    
    read -p "INTRO PARA CONTINUAR " INTRO
    echo " "
    menu
    echo " "
    read -p "Introduce una opción del menú : " opcion
    
done