## RL-Craft Docker Image
GitHub Repo: [https://github.com/jjsuperpower/Minecraft_Plugins/tree/master/rl-craft-docker](https://github.com/jjsuperpower/Minecraft_Plugins/tree/master/rl-craft-docker)

This is a simple image for easy setup and deployment of a rl-craft Minecraft server. 
The first time this image is started, it downloads the rl-craft modpack and the corresponding forge version. Then it starts the server. The server can be configured to use a specific rl-craft version.

Supported versions: 2.9.3, 2.9.2d, 2.9.1c, 2.9, 2.8.2, 2.8.1, 2.8, 2.7, 2.6.3, 2.5, 1.4, 1.3, 1.2, 1.1

BTW, most of these versions are untested, good luck :)

&nbsp;

### THIS IS AN ALPHA RELEASE - EXPECT PROBLEMS
If you have issues, questions, or suggestions, please report them [here](https://github.com/jjsuperpower/Minecraft_Plugins/issues).
I will try my best to address them...

&nbsp;


#### Getting Started
To start the image, please run the following

    docker run --name rlc-server -e RLC_VERSION=<rl-craft version> -e EULA=TRUE -p 25565:25565 -d -it jjsuperpower/rl-craft:0.0.1

Please note: by setting EULA=TRUE you are agreeing to the EULA (duh)

This will (should) create a docker container named "rlc-server" with the desired rl-craft version. It will put "TRUE" in the eula.txt, open port 25565, and run the container interactively detached.
If you wish to be able to see what's going on and interact with the server, run the following

    docker attach rlc-server


&nbsp;


#### Suggestions
It is recommended that you bind mount the /minecraft directory. To do this, run this instead.

    mkdir "$(pwd)/rlc-server"

    docker run --name rlc-server -v "$(pwd)/rlc-server":/minecraft -e RLC_VERSION=<rl-craft version> -e EULA=TRUE -p 25565:25565 -d -it jjsuperpower/rl-craft:0.0.1

Note: volumes are preferred for docker containers, but bind mounts are easier to deal with and modify. This is my opinion though, so do whatever you like.

&nbsp;

#### Environment Variables

    RLC_VERSION             --RL-Craft version
    MEM_SIZE                --This is how much memory java is allowed to use, default = 4G
    RESTART_TIME            --This specifies at what time UTC the server will reboot, change to NEVER if you do not want it rebooting, default = 10:00
    REPLACE_CONFIG          --Replace server.properties with preconfigured one, defualts true
