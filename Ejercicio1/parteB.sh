#!/bin/bash

ARCHIVO_FLOTA="flota.csv"
  
USUARIO_ACTUAL=""

if [ ! -f "$ARCHIVO_FLOTA" ]; then
    echo "Error: no se encuentra $ARCHIVO_FLOTA"
    exit 1
fi



menu_sesion() {
    local OPCION
    while true; do
        echo
        echo "Menu de inicio"
        echo "1) Iniciar sesión"
        echo "2) Registarse"
        echo "3) Salir"
        read -r -p "Opción: " OPCION
        case $OPCION in
            1) iniciar_sesion && return 0 ;;
            2) registrar_usuario ;;
            3) exit 0 ;;
            *) echo "Opción inválida." ;;
        esac
    done
}
iniciar_sesion() {
    read -p "Usuario: " USR
    read -s -p "Clave: " CLAVE
    echo
    if grep -q "^$USR,$CLAVE$" "$ARCHIVO_USUARIOS" ; then
        USUARIO_ACTUAL="$USR"
        return 0
    fi
    echo "Error al ingresar datos"
    return 1
}

registrar_usuario(){
   read -p "Ingrese usuario:" USR; 
   read -s -p "Clave: " CLAVE;
    if grep -q "^$USR" "$ARCHIVO_USUARIOS" ; then
        echo "Usuario existente, ingrese otro";
        return 1
    fi
    if [ -z "$USR" ] || [ -z "$CLAVE" ]; then
        echo "Los campos no pueden estar vacíos"
        return 1
    fi
    echo "$USR,$CLAVE" >> "$ARCHIVO_USUARIOS"
}

menu_principal() {
    local OPCION ID
    while true; do
        echo
        echo "===== DON DRONES - MENÚ PRINCIPAL ($USUARIO_ACTUAL) ====="
        echo "1) Ingresar dron"
        echo "2) Asignar dron a reparto"
        echo "3) "
        echo "4)"
        echo "5)"
        echo "6) Cerrar sesión"
        read -r -p "Opción: " OPCION
        case $OPCION in
            1) ingresarDron ;;
            #ver como asignar el ID
            2) asignar ;;
            3) actualizarDron ;;
            4)
            5) echo "Falta" ;;
            6) USUARIO_ACTUAL=""; exit 0 ;;
            *) echo "Opción inválida." ;;
        esac
    done
}

ingresarDron(){
    read -p "Ingrese categoría: " CATEGORIA
    if [[ "$CATEGORIA" != "Scout" && "$CATEGORIA" != "Cargo" && "$CATEGORIA" != "Heavy" && "$CATEGORIA" != "Cooler" && "$CATEGORIA" != "Racer" ]]; then
        echo "Ingrese categoría válida"
        return
    fi
    read -p "Ingrese modelo: " MODELO
    read -p "Ingrese porcentaje de batería: " BATERIA
    if [[ "$BATERIA" -gt 100 || "$BATERIA" -lt 0 ]]; then
        echo "El porcentaje de batería debe estar entre 0 y 100"
        return
    fi
    read -p "Está disponible?: " DISPONIBLE
    while [[ "$DISPONIBLE" != "Si" && "$DISPONIBLE" != "No"  ]]; then
        echo -p "Ingrese Si/No" DISPONIBLE
        return
    fi
    if [["$DISPONIBLE" =="Si"]]; then
        DISPONIBLE = "Disponible"
    else
        DISPONIBLE = "No disponible"
    fi
    
    echo "$ID,$CATEGORIA,$MODELO,$BATERIA,$DISPONIBLE" >> "$ARCHIVO_FLOTA"
}
asignar(){
    read -p "Ingrese el ID del dron: " ID
    DRON=$(grep "^$ID," "$ARCHIVO_FLOTA")
    if [ -z "$DRON" ]; then
        echo "Error: el dron no existe."
        return 1
    fi
    DISPONIBLE=$(echo "$DRON" | cut -d',' -f5)
    if [ "$DISPONIBLE" != "Si" ]; then
        echo "Error: el dron $ID no está disponible."
        return 1
    fi

    BATERIA_ACTUAL=$(echo "$DRON" | cut -d',' -f4)

   
    if [ "$BATERIA_ACTUAL" -gt 20 ]; then
        sed -i "s/^$ID,\(.*\),Si$/$ID,\1,No/" "$ARCHIVO_FLOTA"
        echo "Dron $ID asignado exitosamente."
    else
        echo "Error: Batería insuficiente."
        return 1
    fi
}

actualizarDron(){
    read -p "Ingrese el ID del dron: " ID;
    DRON=$(grep "^$ID," "$ARCHIVO_FLOTA")
    if [ -z "$DRON" ]; then
        echo "Error: el dron no existe."
        return 1
    fi
    BATERIA=$(echo "$DRON" | cut -d' - ' -f4)
}

while true; do
    menu_sesion
    menu_principal
done
        