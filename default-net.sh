#!/bin/bash
# autor : Adrián Cabezuelo Expósito
# Esto es un script de bash para automatizar la configuracion de red de KVM
# Para la red default 

# FUNCIONES

menu(){

    clear
    echo "************************************"
    echo "Bienvenido al menu de configuracion de red"
    echo "************************************"
    echo "1. Consultar el estado de la red default"
    echo "2. Ver la configuracion de la red default"
    echo "3. Activar/Desactivar la red default"
    echo "4. Inicializar la red default/No-inicializar"
    echo "5. Mofidicar la configuracion de la red default"
    echo "6. Exit"
}

estado_red(){
    echo "El estado de la red default es: "
    virsh net-list --all | grep default
}

configuracion_red(){
    echo "La configuracion de la red default es: "
    virsh net-dumpxml default
    # tambien se puede hacer net-info default
}

activar_desactivas_red(){
    estado_red
    read -p  "Introduce 1 para activar la red default o 0 para desactivarla" opcion
    if [ $opcion -eq 1 ]; then
        virsh net-start default
        echo "La red default se ha activado"
    elif [ $opcion -eq 0 ]; then
        virsh net-destroy default
        echo "La red default se ha desactivado"
    else
        echo "Opción no valida"
    fi
}

inicializar_red(){
    estado_red
    read -p "Introduce 1 para inicializar la red default o 0 para no inicializarla" opcion
    if [ $opcion -eq 1 ]; then
        virsh net-autostart default
        echo "La red default se ha inicializado"
    elif [ $opcion -eq 0 ]; then
        virsh net-autostart --disable default
        echo "La red default no se ha inicializado"
    else
        echo "Opción no valida"
    fi
}

modificar_red(){
    echo "Modificando la red default..."
    echo " "
    virsh net-edit default
}

# INICIO

menu
read -p "Introduce una opcion: " opcion
while [ "$opcion" !=6 ]
do
    case $opcion in
        1)
            estado_red
            ;;
        2)
            configuracion_red
            ;;
        3)
            activar_desactivas_red
            ;;
        4)
            inicializar_red
            ;;
        5)
            modificar_red
            ;;
        *)
            echo "Opción inválida. Por favor, selecciona una opción válida."
            ;;
    esac
    read -p "Introduce una opcion: " intro
    menu
    read -p "Vuelve una opcion: " opcion
done




