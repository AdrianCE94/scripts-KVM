#!/bin/bash
#!/bin/bash

#Función para visualizar pools
function visualizar_pools {
    virsh pool-list --all
}

#Crear discos duros
function crear_discos_duros {
    read -p "Número de discos a crear: " num_discos
    for ((i=1; i<=num_discos; i++)); do
        read -p "Nombre del disco $i: " nombre_disco
        read -p "Tamaño del disco $i (ej. 10G): " tamanio_disco
        virsh vol-create-as default $nombre_disco $tamanio_disco --format qcow2
    done
}

#Mostrar información de discos duros
function mostrar_info_discos {
    virsh vol-list default
}

#Agregar discos a una máquina virtual
function agregar_discos {
    read -p "Nombre de la máquina virtual: " nombre_mv
    read -p "Nombre del disco a agregar: " nombre_disco
    virsh attach-disk $nombre_mv /var/lib/libvirt/images/$nombre_disco --target vdb --persistent
}

#Configurar arranque automático del pool
function definir_arranque_automatico {
    read -p "Nombre del pool para arranque automático: " nombre_pool
    
    mkdir /var/lib/libvirt/$nombre_pool
    virsh pool-define-as $nombre_pool --type dir --target /var/lib/libvirt/$nombre_pool
    virsh pool-autostart $nombre_pool
}

#Función para configurar un pool
function configurar_pool {
    
    echo "Seleccione una opcion de configuración de pool:"
    echo "a) Crear discos duros"
    echo "b) Mostrar información de discos duros"
    echo "c) Agregar discos a máquina virtual"
    echo "d) Definir pools con arranque automático"
    read -p "Opción: " opcion

    case $opcion in
        a) 
        crear_discos_duros;;
        b) 
        mostrar_info_discos;;
        c) 
        agregar_discos;;
        d) 
        definir_arranque_automatico;;
        *) 
        echo "Opción no válida.";;
    esac
}

#Función para borrar pools
function borrar_pool {
    visualizar_pools
    read -p "Nombre del pool a borrar: " nombre_pool
    virsh pool-destroy $nombre_pool
    virsh pool-undefine $nombre_pool
}

#Función para generar informe
function generar_informe {
    pools_activos=$(virsh pool-list --all | grep -c "activo")
    pools_inactivos=$(virsh pool-list --inactive | wc -l)
    autostart_pools=$(virsh pool-list --autostart | wc -l)
    
    echo "Informe de Pools" > Informe_Pool.txt
    echo "Pools activos: $((pools_activos))" >> Informe_Pool.txt
    echo "Pools inactivos: $((pools_inactivos - 2))" >> Informe_Pool.txt
    echo "Pools con arranque automático: $((autostart_pools - 2))" >> Informe_Pool.txt
    echo "Informe generado en Informe_Pool.txt"
}

#Menú principal
function menu {
    while true; do
    
        echo "Menú de gestión de pools de almacenamiento en KVM"
        echo "1) Visualizar pools existentes"
        echo "2) Configurar un pool"
        echo "3) Borrar pools"
        echo "4) Generar informe de pools"
        echo "5) Salir"
        read -p "Seleccione una opción: " opcion

        case $opcion in
            1) 
            visualizar_pools;;
            2) 
            configurar_pool;;
            3) 
            borrar_pool;;
            4) 
            generar_informe;;
            5) 
            echo "Saliendo..."; exit;;
            *) 
            echo "Opción no válida. Intente de nuevo.";;
        esac
    done
}

#Iniciar el script con el menú principal
menu