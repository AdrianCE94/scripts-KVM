# scripts-KVM
Automatización para KVM
# Descripción
Este script automatiza configuraciones importantes de kvm.
Encontramos los siguientes scripts:
- crearMaquina.sh: Crea una máquina virtual
- defaultNet.sh: Crea una red virtual por defecto
- bridgeKVM.sh : Crea una red virtual con puente estático
- pool.sh : gestión de pools
# Requisitos
- Tener instalado KVM
- Si quieres saber como instalar KVM --> ![instalacionKVM](https://github.com/AdrianCE94/instalacion-KVM)
- .iso del sistema operativo que se desea instalar

# Instalación
1. Clonar el repositorio
```bash
git clone https://github.com/AdrianCE94/scripts-KVM
cd scripts-KVM
```
2. Dar permisos de ejecución al script
```bash
chmod a+x crearMaquina.sh
chmod a+x defaultNet.sh
chmod a+x bridgeKVM.sh
chmod a+x pool.sh
```
3. Ejecutar el script
```bash
./crearMaquina.sh
```

# Contribuciones
Si deseas contribuir al proyecto, puedes hacer un fork del repositorio y enviar un pull request.


# Licencia
[MIT](https://choosealicense.com/licenses/mit/)

# Autor
* :pushpin: [Cabezuelo Expósito, Adrián](https://github.com/AdrianCE94)
