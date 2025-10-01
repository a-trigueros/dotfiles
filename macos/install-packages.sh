#!/bin/bash

# Dossier contenant les packages
PACKAGES_DIR="$(dirname "$0")/packages"

# Liste des packages avec descriptions
declare -a package_names=("cli.brew" "dotnet.brew" "gaming.brew" "gui.brew" "java.brew" "javascript.brew" "python.brew" "rust.brew")
declare -a package_descriptions=("Outils en ligne de commande" "Environnement .NET" "Applications de gaming" "Applications graphiques" "Environnement Java" "Environnement JavaScript/Node.js" "Environnement Python" "Environnement Rust")

declare -a selected

for i in "${!package_names[@]}"; do
    selected[$i]=false
done

show_interface() {
    clear
    echo "🍺 === Installation sélective de packages Homebrew ==="
    echo ""
    echo "Utilisez les touches suivantes :"
    echo "  ↑/↓ ou j/k : Naviguer"
    echo "  Espace     : Cocher/Décocher"
    echo "  a          : Tout sélectionner"
    echo "  n          : Tout désélectionner"
    echo "  Entrée     : Confirmer et installer"
    echo "  q          : Quitter"
    echo ""
    echo "Packages disponibles :"
    echo ""
    
    for i in "${!package_names[@]}"; do
        local checkbox
        if [ "${selected[$i]}" = "true" ]; then
            checkbox="[✓]"
        else
            checkbox="[ ]"
        fi
        
        local indicator=" "
        if [ $i -eq $current_selection ]; then
            indicator=">"
        fi
        
        printf "%s %s %s - %s\n" "$indicator" "$checkbox" "${package_names[$i]}" "${package_descriptions[$i]}"
    done
    
    echo ""
    local selected_count=0
    for i in "${!package_names[@]}"; do
        if [ "${selected[$i]}" = "true" ]; then
            ((selected_count++))
        fi
    done
    echo "Packages sélectionnés : $selected_count/${#package_names[@]}"
}

# Variables pour la navigation
current_selection=0
max_selection=$((${#package_names[@]} - 1))

while true; do
    show_interface

    IFS= read -rsn1 key
    
    case $key in
        'k')
            if [ $current_selection -gt 0 ]; then
                ((current_selection--))
            fi
            ;;
        'j')
            if [ $current_selection -lt $max_selection ]; then
                ((current_selection++))
            fi
            ;;
        $'\033')
            read -rsn2 arrow_key
            case "$arrow_key" in
                '[A') 
                    if [ $current_selection -gt 0 ]; then
                        ((current_selection--))
                    fi
                    ;;
                '[B') 
                    if [ $current_selection -lt $max_selection ]; then
                        ((current_selection++))
                    fi
                    ;;
            esac
            ;;
        
        'a')
            for i in "${!package_names[@]}"; do
                selected[$i]=true
            done
            ;;
        
        'n')
            for i in "${!package_names[@]}"; do
                selected[$i]=false
            done
            ;;
        
        'q')
            clear
            echo "Installation annulée."
            exit 0
            ;;
        
        $'\n'|'')
            
            if [ -z "$key" ]; then
                break
            fi
            ;;
        *)
            
            if [ "$key" = " " ]; then
                if [ "${selected[$current_selection]}" = "true" ]; then
                    selected[$current_selection]=false
                else
                    selected[$current_selection]=true
                fi
            fi
            ;;
    esac
done


selected_packages=""
for i in "${!package_names[@]}"; do
    if [ "${selected[$i]}" = "true" ]; then
        selected_packages="$selected_packages ${package_names[$i]}"
    fi
done

if [ -z "$selected_packages" ]; then
    clear
    echo "Aucun package sélectionné. Installation annulée."
    exit 0
fi

clear
echo "🍺 Installation des packages sélectionnés..."
echo ""

for package in $selected_packages; do
    description=""
    for i in "${!package_names[@]}"; do
        if [ "${package_names[$i]}" = "$package" ]; then
            description="${package_descriptions[$i]}"
            break
        fi
    done
    
    echo "📦 Installation de $package ($description)..."
    brew bundle install --file="$PACKAGES_DIR/$package"
    echo ""
done

echo "✅ Installation terminée !"
echo ""
echo "Packages installés :"
for package in $selected_packages; do
    description=""
    for i in "${!package_names[@]}"; do
        if [ "${package_names[$i]}" = "$package" ]; then
            description="${package_descriptions[$i]}"
            break
        fi
    done
    echo "  • $package ($description)"
done
