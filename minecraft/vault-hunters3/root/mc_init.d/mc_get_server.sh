# get url for rl-craft install
get_rlcraft_url()   {
    local base_url="https://media.forgecdn.net/files"
    local forge1_18_2="https://maven.minecraftforge.net/net/minecraftforge/forge/1.18.2-40.2.1/forge-1.18.2-40.2.1-installer.jar"

    case $1 in 
        "9.0.3")
            MODPACK_URL="${base_url}/4516/817/Vault+Hunters+3rd+Edition-Update-9.0.3_Server-Files.zip"
            MC_FORGE=${forge1_18_2}

        ;;

        "8.0.1")
            MODPACK_URL="${base_url}/4433/689/Vault+Hunters+3rd+Edition-Update-8.0.1_Server-Files.zip"
            MC_FORGE=${forge1_18_2}
        ;;

        "7.7")
            MODPACK_URL="${base_url}/4395/726/Vault+Hunters+3rd+Edition-Update-7.7_Server-files.zip"
            MC_FORGE=${forge1_18_2}
        ;;
    esac
}

check_versions() {
    # check if MODPACK_URL is empty
    if [ -z "$MODPACK_URL" ]; then
        echo "This container does not support the version you requested or the version you requested is not valid." 
        echo "Supported versions are: 7.7"
        exit 1
    fi

    #check if MC_FORGE is empty
    if [ -z "$MC_FORGE" ]; then
        echo "Was not able to find the correct mc forge version"
        exit 1
    fi
}

download_rl_craft() {
    cd ${MC_INST_DIR}

    if [ -d "mods" ]; then
        echo "Removing old mods"
        rm -rf mods
    fi
    
    echo "Downloading Modpack"
    wget ${MODPACK_URL}
    echo "Unzipping Modpack"
    unzip -o *.zip          # overwrite existing files
    echo "Removing Modpack zip"
    rm *.zip

    # change back to previous directory
    cd -
}

download_forge() {
    cd ${MC_INST_DIR}

    if [ -e "server.jar" ]; then
        echo "Removing old forge"
        rm server.jar
    fi
    echo "Downloading Minecraft Forge"
    wget ${MC_FORGE} -o install.jar
    mv forge*.jar install.jar
    echo "Installing Minecraft Forge"
    java -jar install.jar --installServer
    mv forge*.jar server.jar
    echo "Removing Minecraft Forge installer"
    rm install.jar

    # change back to previous directory
    cd -
}