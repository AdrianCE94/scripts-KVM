# scripts-KVM
Automatización para KVM
![portada](img/descarga.png)
# Descripción
Este script automatiza la creación de máquinas virtuales en KVM. Se puede crear una máquina virtual con un solo comando, y se puede elegir entre diferentes sistemas operativos.
Encontramos los siguientes scripts:
- crearMaquina.sh: Crea una máquina virtual
- default-net.sh: Crea una red virtual por defecto
- static-bridge.sh: Crea una red virtual con puente estático
# Requisitos
- Tener instalado KVM
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
chmod a+x default-net.sh
chmod a+x static-bridge.sh
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