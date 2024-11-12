#!/bin/bash

# Autor : Adrián Cabezuelo Expósito

# script con un menú para automatizar la configuración de la red en KVM

# FUNCIONES

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
menu() {
    
    clear
    echo "********************************"
    echo "1.Ver de Configuración de Red"
    echo "2.Definir una red bridge estática"
    echo "3.Verificar que existe un bridge y que esta asociado a una interfaz"
    echo "4.Activar/Desactivar la red bridge"
    echo "5.Modificar la configuración de la red bridge"
    echo "6.Salir"
    echo "********************************"
}


# configuracion de red

configuracionRed(){

    echo "CONFIGURACION DE RED KVM: " 
    virsh net-list --all
    echo "CONFIGURACION DE TU HOST"
    ip addr show
    echo ".........................."
    echo " IP: $(hostname -I)"
    echo "=============================================="
    read -p  "Quieres informació sobre alguna red en particular(en caso afirmativo escribe si)? " res
    if [ $res = "si" ]; th
        virsh net-info $nombreRed
        read -p "Presiona Enter para volver al menu..." intro
    fi
    read -p "Presiona Enter para volver al menu..."
}

# Definir una red bridge estática

definir_bridge() {
    echo "BIENVENIDO A LA CONFIGURACION DE UNA RED EN KVM"
    echo "=========================================================="

# Solicitar información básica
read -p "Introduce el nombre de la red virtual: " nombreRed
read -p "Introduce el nombre del bridge (por ejemplo, br0): " nombreBridge
read -p "Introduce la interfaz física a asociar (por ejemplo, ensXX): " interfaz

echo "Creando el archivo de configuración de red virtual..."

    cat > /etc/libvirt/qemu/networks/$nombreRed.xml <<EOF
<network>
  <name>$nombreRed</name>
  <forward mode='bridge'/>
  <bridge name='$nombreBridge'/>
</network>
EOF

# Verificar si el archivo XML fue creado correctamente
if [ -f "/etc/libvirt/qemu/networks/$nombreRed.xml" ]; then
    echo "Archivo XML para la red de KVM creado correctamente."
else
    echo "Error al crear el archivo XML de la red de KVM."
    exit 1
fi

# Definir la red en KVM
echo "Definiendo la red en KVM..."
if ! virsh net-define /etc/libvirt/qemu/networks/$nombreRed.xml; then
        echo "Error al definir la red en KVM"
        return 1
fi

# Arrancar la red
echo "Arrancando la red..."
if ! virsh net-start "$nombreRed"; then
        echo "Error al arrancar la red"
        return 1
fi

#autostart
read -p "¿Quieres autoarrancar la red al inicio del sistema (si/no)? " res
if [ "$res" = "si" ]; then
        virsh net-autostart "$nombreRed"
fi

#Mostrar redes KVM
echo "\nRedes virtuales configuradas:"
virsh net-list --all | grep "$nombreRed"

# mas info
read -p "¿Quieres mas informacion sobre la red creada(si/no)? " redcreada
if [ "$redcreada" = "si" ]; then
        virsh net-info $nombreRed
fi

}

# Verificar que existe un bridge y que está asociado a una interfaz  
verificar_bridge() {
    brctl show
}

# Activar/Desactivar la red bridge

activar_desactivar_bridge() {
    echo "ACTIVAR/DESACTIVAR RED BRIDGE"
    echo "============================="
    virsh net-list --all
read -p "Ingrese el nombre del bridge para activar/desactivar: " bridge_name
read -p "¿Desea activar (start) o desactivar (destroy) el bridge? " accion
virsh net-$accion $name3
echo "El bridge $bridge_name ha sido $accion."
}

# Modificar la configuración de la red bridge

modificar_bridge() {
    echo "MODIFICAR LA CONFIGURACIÓN DE LA RED BRIDGE"
    echo "=========================================="
    virsh net-list --all
read -p "Introduce la red que deseas modificar: " red
virsh net-edit $red
}

# INICIO

comprobarRoot
menu
echo ""
read -p "Introce una opción del menú: " opcion
while [ "$opcion" != 6 ]
do
case "$opcion" in
    1)
        configuracionRed
        ;;
    2)
        definir_bridge
        ;;
    3)
        verificar_bridge
        ;;
    4)
        activar_desactivar_bridge
        ;;
    5)
        modificar_bridge
        ;;
    *)
        echo "Opción no válida"
        ;;
esac
read -p "INTRO PARA CONTINUAR" INTRO
menu
read -p "Introce una opción del menú: " opcion
done