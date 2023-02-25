# get url for rl-craft install
get_rlcraft_url()   {
    local rlcraft_base_url="https://media.forgecdn.net/files"
    local forge12_2="https://maven.minecraftforge.net/net/minecraftforge/forge/1.12.2-14.23.5.2860/forge-1.12.2-14.23.5.2860-installer.jar"
    local forge11_2="https://maven.minecraftforge.net/net/minecraftforge/forge/1.11.2-13.20.1.2588/forge-1.11.2-13.20.1.2588-installer.jar"

    case $1 in 
        "2.9.1c")
            RL_CRAFT_URL="${rlcraft_base_url}/3655/676/RLCraft+Server+Pack+1.12.2+-+Release+v2.9.1c.zip"
            MC_FORGE=${forge12_2}
        ;;

        "2.9")
            RL_CRAFT_URL="${rlcraft_base_url}/3575/916/RLCraft+Server+Pack+1.12.2+-+Release+v2.9.zip"
            MC_FORGE=${forge12_2}
        ;;

        "2.8.2")
            RL_CRAFT_URL="${rlcraft_base_url}/2935/323/RLCraft+Server+Pack+1.12.2+-+Beta+v2.8.2.zip"
            MC_FORGE=${forge12_2}
        ;;

        "2.8.1")
            RL_CRAFT_URL="${rlcraft_base_url}/2836/138/RLCraft+Server+Pack+1.12.2+-+Beta+v2.8.1.zip"
            MC_FORGE=${forge12_2}
        ;;

        "2.8")
            RL_CRAFT_URL="${rlcraft_base_url}/2833/1/RLCraft+Server+Pack+1.12.2+-+Beta+v2.8.zip"
            MC_FORGE=${forge12_2}
        ;;

        "2.7")
            RL_CRAFT_URL="${rlcraft_base_url}/2800/990/RLCraft+Server+Pack+1.12.2+-+Beta+v2.7.zip"
            MC_FORGE=${forge12_2}
        ;;

        "2.6.3")
            RL_CRAFT_URL="${rlcraft_base_url}/2791/783/RLCraft+Server+Pack+1.12.2+-+Beta+v2.6.3.zip"
            MC_FORGE=${forge12_2}
        ;;

        "2.5")
            RL_CRAFT_URL="${rlcraft_base_url}/2780/296/RLCraft+Server+Pack+1.12.2+-+Beta+v2.5.zip"
            MC_FORGE=${forge12_2}
        ;;

        "2.4")
            RL_CRAFT_URL=""
            MC_FORGE=${forge12_2}
        ;;

        "2.3")
            RL_CRAFT_URL=""
            MC_FORGE=${forge12_2}
        ;;

        "2.2")
            RL_CRAFT_URL=""
            MC_FORGE=${forge12_2}
        ;;

        "2.1")
            RL_CRAFT_URL=""
            MC_FORGE=${forge12_2}
        ;;

        "1.4")
            RL_CRAFT_URL="${rlcraft_base_url}/2533/561/RLCraft+Server+Pack+1.11.2+-+Beta+v1.4.zip"
            MC_FORGE=${forge11_2}
        ;;

        "1.3")
            RL_CRAFT_URL="${rlcraft_base_url}/2530/772/RLCraft+Server+Pack+1.11.2+-+Beta+v1.3.zip"
            MC_FORGE=${forge11_2}
        ;;

        "1.2")
            RL_CRAFT_URL="${rlcraft_base_url}/2525/512/RLCraft+Server+Pack+1.11.2+-+Beta+v1.2.zip"
            MC_FORGE=${forge11_2}
        ;;

        "1.1")
            RL_CRAFT_URL="${rlcraft_base_url}/2520/485/RLCraft+Server+Pack+1.11.2+-+Beta+v1.1.zip"
            MC_FORGE=${forge11_2}
        ;;

        "1.0")
            RL_CRAFT_URL=""
            MC_FORGE=${forge11_2}
        ;;
    esac
}

check_versions() {
    # check if RL_CRAFT_URL is empty
    if [ -z "$RL_CRAFT_URL" ]; then
        echo "Mod pack is not available for this version of RL-Craft" 
        echo "Supported versions are: 2.9.1c, 2.9, 2.8.2, 2.8.1, 2.8, 2.7, 2.6.3, 2.5, 2.4, 2.3, 2.2, 2.1, 1.4, 1.3, 1.2, 1.1"
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
    
    echo "Downloading RLCraft"
    wget ${RL_CRAFT_URL}
    echo "Unzipping RLCraft"
    unzip RLCraft*.zip
    echo "Removing RLCraft zip"
    rm RLCraft*.zip

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
    wget ${MC_FORGE}
    mv forge*.jar install.jar
    echo "Installing Minecraft Forge"
    java -jar install.jar --installServer
    mv forge*.jar server.jar
    echo "Removing Minecraft Forge installer"
    rm install.jar

    # change back to previous directory
    cd -
}