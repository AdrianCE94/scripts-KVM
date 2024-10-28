#!/bin/bash
# Autor : Adrián Cabezuelo Expósito
# Script de bash para automatizar la configuración de la red "default" en KVM

# FUNCIONES

menu() {
    clear
    echo "************************************"
    echo " Menú de Configuración de Red KVM "
    echo "************************************"
    echo "1) Consultar el estado de la red default"
    echo "2) Ver la configuración de la red default"
    echo "3) Activar/Desactivar la red default"
    echo "4) Inicializar/No-inicializar la red default"
    echo "5) Modificar la configuración de la red default"
    echo "6) Salir"
}

consultar_estado() {
    echo "Estado de la red default:"
    virsh net-list --all | awk 'NR==1 || /default/'
    echo "mostrando información adicional..."
    echo "----------------------------------------"
    virsh net-info default
}

config_red() {
    echo "Configuración de la red default:"
    virsh net-dumpxml default
}

activar_desactivar() {

echo ""
echo "Mostrando info de la red...."
echo " "
virsh net-list --all | awk 'NR==1 || /default/'
echo ""
read -p "Introduce 1 para activar y 0 para desactivar la red default :" accion
    if [ $accion -eq 1 ]; then
        virsh net-start default
        echo "Red activada"
        echo "mostrando la información de la red...."
        virsh net-info default
    elif [ $accion -eq 0 ]; then
        virsh net-destroy default
        echo "Red desactivada"
        echo "mostrando la información de la red...."
        virsh net-info default
    else
        echo "Opción no válida"
    fi
}

auto_inicializar() {
    echo ""
    echo "Mostrando info de la red...."
    echo " "
    virsh net-info default
    echo ""
    read -p "Introduce 1 para inicializar y 0 para no-inicializar la red default :" accion
    if [ $accion -eq 1 ]; then
        virsh net-autostart default
    elif [ $accion -eq 0 ]; then
        virsh net-autostart --disable default
    else
        echo "Opción no válida"
    fi
}

modificar_config() {
    virsh net-edit default
}

comprobarRoot () {
    existe=$(id -u)
    if [ $existe -eq 0 ]
    then
        echo "Puedes continuar"
    else
        echo "No eres root, pa tu casa"
        exit 1
    fi
}

# inicio script


comprobarRoot
menu
echo ""
read -p "Introce una opción del menú: " opcion
while [ "$opcion" != 6 ]
do
case "$opcion" in
1)
    consultar_estado
    ;;
2)
    config_red
    ;;
3)
    activar_desactivar
    ;;
4)
    auto_inicializar
    ;;
5)
    modificar_config
    ;;
*)
    echo "Opción no válida"
    ;;
esac
read -p "INTRO PARA CONTINUAR" INTRO
menu
read -p "Introce una opción del menú: " opcion
done
