#!/bin/bash

# Autor : Adrián Cabezuelo Expósito
# Este script de bash automatiza la configuración de la red bridge en KVM

# FUNCIONES

menu() {
    
    clear
    echo "********************************"
    echo " 1.Ver de Configuración de Red"
    echo "2.Definir una red bridge estática"
    echo "3.Verificar que existe un bridge y que esta asociado a una interfaz"
    echo "4.Activar/Desactivar la red bridge"
    echo "5.Modificar la configuración de la red bridge"
    echo "6.Salir"
    echo "********************************"
}

ver_config_red() {
    
    # Mostrar la configuración de todas las interfaces
    echo "Configuración de todas las interfaces de red:"
    ip addr show

    # Solicitar el nombre del bridge para verificar
    read -p "Ingrese el nombre del bridge que desea verificar (ej. br0): " nombre_bridge
    echo "Configuración de la red bridge '$nombre_bridge':"
    
    # Verificar y mostrar la configuración del bridge
    if ip addr show "$nombre_bridge" >/dev/null 2>&1; then
        ip addr show "$nombre_bridge"
    else
        echo "El bridge '$nombre_bridge' no existe."
    fi

    read -p "Presione Enter para volver al menú..."
    menu
}

definir_red() {
    # Solicitar el nombre del bridge
    read -p "Ingrese el nombre del bridge: " nombre
    # Solicitar el nombre de la interfaz a asociar
    read -p "Ingrese el nombre de la interfaz a asociar (ensXX): " interface_nombre
    # Solicitar dirección IP y máscara
    read -p "Ingrese la dirección IP estática (ej. 192.168.1.10): " ip_estatica
    read -p "Ingrese la máscara de red (ej. 255.255.255.0): " mascara_red
    read -p "Ingrese la puerta de enlace (ej. 192.168.1.1): " puerta_enlace

    # Crear archivo XML para la red bridge
    cat <<EOF > /tmp/$nombre.xml
<network>
    <name>$nombre</name>
    <forward mode='bridge'/>
    <bridge name='$nombre'/>
    <ip address='$ip_estatica' netmask='$mascara_red'>
        <dhcp>
            <range start='${ip_estatica%.*}.100' end='${ip_estatica%.*}.200'/>
        </dhcp>
    </ip>
</network>
EOF

    # Definir la red en KVM
    if virsh net-define /tmp/$nombre.xml; then
        echo "Red definida exitosamente: $nombre"
    else
        echo "Error al definir la red: $nombre"
        return 1
    fi

    # Iniciar la red
    if virsh net-start $nombre; then
        echo "Red iniciada: $nombre"
    else
        echo "Error al iniciar la red: $nombre"
        return 1
    fi

    # Hacer que la red se inicie automáticamente
    if virsh net-autostart $nombre; then
        echo "Red configurada para iniciar automáticamente: $nombre"
    else
        echo "Error al configurar el inicio automático para la red: $nombre"
        return 1
    fi

    # Mostrar las redes definidas
    echo "Redes definidas actualmente:"
    virsh net-list --all
}

verificar_bridge() {
    # Verificar que existe un bridge y que está asociado a una interfaz
   brctl show
}

on_off_bridge () {

    # Mostrar las redes definidas
    echo "Redes definidas actualmente:"
    virsh net-list --all

    # Solicitar el nombre de la red bridge
    read -p "Ingrese el nombre de la red bridge que desea activar/desactivar: " nombre_red

    # Preguntar al usuario si desea activar o desactivar la red
    read -p "¿Desea activar (A) o desactivar (D) la red? [A/D]: " accion
        case $accion in
            [Aa]*) 
                # Activar la red
                if virsh net-start "$nombre_red"; then
                    echo "Red '$nombre_red' activada."
                else
                    echo "Error al activar la red '$nombre_red'."
                fi
                ;;
            [Dd]*) 
                # Desactivar la red
                if virsh net-destroy "$nombre_red"; then
                    echo "Red '$nombre_red' desactivada."
                else
                    echo "Error al desactivar la red '$nombre_red'."
                fi
                ;;
            *) 
                echo "Opción no válida. Debe ingresar 'A' para activar o 'D' para desactivar."
                ;;
        esac
    else
        echo "La red '$nombre_red' no está definida."
    fi
}

modificar_red() {
# Solicitar el nombre de la red bridge a modificar
    read -p "Ingrese el nombre de la red bridge que desea modificar: " nombre_red

    # Verificar si la red está definida
    if virsh net-list --all | grep -q "$nombre_red"; then
        # Mostrar la configuración actual de la red
        echo "Configuración actual de la red '$nombre_red':"
        virsh net-dumpxml "$nombre_red"

        # Solicitar nuevas configuraciones
        read -p "Ingrese la nueva dirección IP estática (dejar en blanco para no modificar): " nueva_ip
        read -p "Ingrese la nueva máscara de red (dejar en blanco para no modificar): " nueva_mascara
        read -p "Ingrese la nueva puerta de enlace (dejar en blanco para no modificar): " nueva_puerta

        # Crear un archivo temporal para la nueva configuración
        cat <<EOF > /tmp/nueva_$nombre_red.xml
<network>
    <name>$nombre_red</name>
    <forward mode='bridge'/>
    <bridge name='$nombre_red'/>
EOF

        # Si se proporciona nueva IP, máscara o puerta, se añade al archivo
        if [[ -n $nueva_ip ]] || [[ -n $nueva_mascara ]]; then
            echo "    <ip" >> /tmp/nueva_$nombre_red.xml
            if [[ -n $nueva_ip ]]; then
                echo " address='$nueva_ip'" >> /tmp/nueva_$nombre_red.xml
            fi
            if [[ -n $nueva_mascara ]]; then
                echo " netmask='$nueva_mascara'>" >> /tmp/nueva_$nombre_red.xml
            fi
            echo "        <dhcp>" >> /tmp/nueva_$nombre_red.xml
            echo "            <range start='${nueva_ip%.*}.100' end='${nueva_ip%.*}.200'/>" >> /tmp/nueva_$nombre_red.xml
            echo "        </dhcp>" >> /tmp/nueva_$nombre_red.xml
            echo "    </ip>" >> /tmp/nueva_$nombre_red.xml
        fi

        # Cerrar el archivo XML
        echo "</network>" >> /tmp/nueva_$nombre_red.xml

        # Definir la nueva configuración en KVM
        if virsh net-define /tmp/nueva_$nombre_red.xml; then
            echo "Configuración de la red '$nombre_red' modificada exitosamente."
        else
            echo "Error al modificar la configuración de la red '$nombre_red'."
            return 1
        fi

        # Reiniciar la red
        virsh net-destroy "$nombre_red"
        virsh net-start "$nombre_red"

    else
        echo "La red '$nombre_red' no está definida."
    fi

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

# INICIO

comprobarRoot
menu
echo ""
read -p "Introce una opción del menú: " opcion
while [ "$opcion" != 6 ]
do
case "$opcion" in
1)
    ver_config_red
    ;;
2)
    definir_red
    ;;
3)
    verificar_bridge
    ;;
4)
    on_off_bridge
    ;;
5)
    modificar_red
    ;;
*)
    echo "Opción no válida"
    ;;
esac
read -p "INTRO PARA CONTINUAR" INTRO
menu
read -p "Introce una opción del menú: " opcion
done
