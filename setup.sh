#/bin/bash
#set -x 
# GLOBAL_VARIABLES
WARNING=0
LOG_DIR="${HOME}/.ansible_training/logs"
CONFIG_FILE="${HOME}/.ansible_training/user.conf"
# Functions 
## Color Formatting 
function check(){
    for i in "$*"; do printf "\e[1;02m[CHECK] %s\e[0m\n" "$i"; done;
}
function step(){
    for i in "$*"; do printf "\e[1;02m[STEP] %s\e[0m\n" "$i"; done;
}
function cmd(){
    for i in "$*"; do printf "\e[1;02m[COMMAND] %s\e[0m\n" "$i"; done;
}
function comp(){
    for i in "$*"; do printf "\e[1;32m[COMPLETE] %s\e[0m\n" "$i"; done;
}
function notice(){
    for i in "$*"; do printf "\e[1;34m[NOTICE] %s\e[0m\n" "$i"; done;
}
function passed(){
    for i in "$*"; do printf "\e[1;32m[PASSED] %s\e[0m\n" "$i"; done;
}
function warning(){
    for i in "$*"; do printf "\e[1;33m[WARN] %s\e[0m\n" "$i"; done;
}
function error(){
    for i in "$*"; do printf "\e[1;31m[ERROR] %s\e[0m\n" "$i"; done;
}
function failed(){
    for i in "$*"; do printf "\e[1;31m[ERROR] %s\e[0m\n" "$i"; done;
    exit 1
}
## YAML Parsing
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}
## CHECK Supported System 
function is_supported() {
    case "$1" in
      Linux) 
               passed "System Detected: $1"
               return 0;;
      Darwin)
               passed "System Detected: $1"
               return 0;;
      *) error "This system is not currently supported for this training environment."
         notice "If you would like the OS supported please open a feature request in the Issues section of this repo."
         exit 1
         ;;
    esac
}
## Check is package installed
function is_installed() {
    PKG=$1
    ${PKG} --version > $LOG_DIR/packages.log 2> $LOG_DIR/packages_error.log
    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi 
}
function install(){
    case "$(uname)" in 
      Linux) 
            case "$1" in
                ansible)
                    linux ansible-core;;
                docker)
                    linux docker ;;
                podman)
                    linux podman ;;
                *) ;;
            esac
            ;;
      Darwin)
            case "$1" in
                ansible) 
                    macosx ansible;;
                docker) 
                    macosx docker ;;
                podman)
                    macosx podman ;;
                *) ;;
            esac
            ;; 
      *) error "This system is not currently supported for this training environment."
         notice "If you would like the OS supported please open a feature request in the Issues section of this repo."
         exit 1
         ;;
    esac
}


function macosx(){
    local install_packages=$1
    notice "Detected system is: MacOSX"
    check "Homebrew installed..."
    brew --version > $LOG_DIR/homebrew.log 2> $LOG_DIR/homebrew_error.log
    if [ $? -ne 0 ];then
        error "Homebrew is not installed on this system."
        notice "The only method of current supported installation is with Homebrew."
        notice "You may install homebrew by using the following command:"
        notice '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"'
        exit 1
    fi
    check "Updating brew casks"
    brew update
    brew install $install_packages
    return 0 
}
function linux(){
    local install_packages=$1
    declare -A pkgmgr=( \
    ["debian"]="apt" \
    ["ubuntu"]="apt" \
    ["centos"]="dnf" \
    ["rhel"]="dnf" \
    ["almalinux"]="dnf" \
    ["fedora"]="dnf" \
    )
    source /etc/os-release
    OS_FAMILY=${ID_LIKE}
    notice "Detected OS Family: ${OS_FAMILY}"
    OS_DISTRO=${ID}
    PACKAGE_MANAGER=${pkgmgr[${OS_DISTRO}]}
    notice "Selected package manager: ${PACKAGE_MANAGER}"
    if [ ${PACKAGE_MANAGER} == 'apt' ]; then
        declare -A ubuntu_packages_docker_install=( \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
        )
        declare -A ubuntu_packages_docker_uninstall=( \
        docker.io \
        docker-doc \
        docker-compose \
        docker-compose-v2 \
        podman-docker \
        containerd \
        runc \
        )
        sudo ${PACKAGE_MANAGER} update
        step "Installing supplimental packages if not already done."
        cmd "Running: ${PACKAGE_MANAGER} -y install wget gpg"
        sudo ${PACKAGE_MANAGER} -y install wget gpg > $LOG_DIR/${PACKAGE_MANAGER}.log 2> $LOG_DIR/${PACKAGE_MANAGER}_error.log
        case "${install_packages}" in
            ansible-core) 
                step "Getting GPG key for Ansible"
                wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | \
                sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg > $LOG_DIR/${PACKAGE_MANAGER}.log 2> $LOG_DIR/${PACKAGE_MANAGER}_error.log
                step "Adding repo to ${PACKAGE_MANAGER} list."
                echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | \
                sudo tee /etc/apt/sources.list.d/ansible.list > /dev/null
                step "Updating ${PACKAGE_MANAGER}"
                sudo ${PACKAGE_MANAGER} update > $LOG_DIR/${PACKAGE_MANAGER}.log 2> $LOG_DIR/${PACKAGE_MANAGER}_error.log
                step "Installing Ansible."
                sudo ${PACKAGE_MANAGER}-get -y install ansible-core > $LOG_DIR/${PACKAGE_MANAGER}.log 2> $LOG_DIR/${PACKAGE_MANAGER}_error.log
                ansible --version >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    comp "Ansible has been installed successfully."
                    ANSIBLE_INSTALLED=true
                else
                    failed "Install of Ansible has failed."
                fi 
                ;;
            docker)
                step "Uninstalling previous install and potential conflicting packages"
                for upak in ${ubuntu_packages_docker_uninstall}; do
                    cmd "Running: ${PACKAGE_MANAGER} -y remove ${upak}"
                    sudo ${PACKAGE_MANAGER} -y remove $upak > $LOG_DIR/${PACKAGE_MANAGER}.log 2> $LOG_DIR/${PACKAGE_MANAGER}_error.log
                done
                notice "Removed conflicting packages"
                notice "Installing Docker"
                step "Installing Docker ${PACKAGE_MANAGER} repo with packages"
                cmd "Running: ${PACKAGE_MANAGER} -y install ca-certificates curl gnupg"
                sudo ${PACKAGE_MANAGER} -y install ca-certificates curl gnupg > $LOG_DIR/${PACKAGE_MANAGER}.log 2> $LOG_DIR/${PACKAGE_MANAGER}_error.log
                cmd "Running: sudo install -m 0755 -d /etc/apt/keyrings"
                sudo install -m 0755 -d /etc/apt/keyrings >/dev/null 2>&1
                step "Downloading: docker.gpg to keyring"
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                step "Updating permisssions to keyring"
                sudo chmod a+r /etc/apt/keyrings/docker.gpg
                step "Adding repository to ${PACKAGE_MANAGER} sources"
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
                https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo ${VERSION_CODENAME}) stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo ${PACKAGE_MANAGER} update > $LOG_DIR/${PACKAGE_MANAGER}.log 2> $LOG_DIR/${PACKAGE_MANAGER}_error.log
                step "Installing updated Docker packages"
                sudo ${PACKAGE_MANAGER}-get install $ubuntu_packages_docker_install > $LOG_DIR/${PACKAGE_MANAGER}.log 2> $LOG_DIR/${PACKAGE_MANAGER}_error.log
                docker --version >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    comp "Docker has been installed successfully."
                else
                    failed "Install of Docker has failed."
                fi 
                ;;
            podman)
                check "Checking version of Ubuntu to determine install method"
                VERSION=$(source /etc/os-release && echo ${VERSION_ID})
                if (( $(echo "$VERSION < 20.10") | bc -l )); then
                    step "Adding Kubic repository"
                    echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | \
                    sudo tee > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list > /dev/null
                    step "Verify integrity by adding GPG key"
                    wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key -O- | sudo apt-key add -
                fi
                step "Updating $PACKAGE_MANAGER repos"
                sudo $PACKAGE_MANAGER update > $LOG_DIR/${PACKAGE_MANAGER}.log 2> $LOG_DIR/${PACKAGE_MANAGER}_error.log
                step "Installing Podman"
                cmd "sudo $PACKAGE_MANAGER -y install podman"
                sudo ${PACKAGE_MANAGER}-get -y install podman > $LOG_DIR/${PACKAGE_MANAGER}.log 2> $LOG_DIR/${PACKAGE_MANAGER}_error.log
                podman --version >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    comp "Podman has been installed successfully."
                else
			failed "Install of Podman has failed."
                fi 
                ;;
        esac
    fi
    if [ ${PACKAGE_MANAGER} == 'dnf' ]; then
         
        case "${install_packages}" in
            ansible-core) 
		    dnf install -y ansible-core ;;
            docker)
                declare -A dnf_packages_docker_uninstall=(\
                    docker \
                    docker-client \
                    docker-client-latest \
                    docker-common \
                    docker-latest \
                    docker-latest-logrotate \
                    docker-logrotate \
                    docker-engine \
                )
                declare -A dnf_packages_docker=(\
                    docker-ce \
                    docker-ce-cli \
                    containerd.io \
                    docker-buildx-plugin \
                    docker-compose-plugin \
                )

                step "Removing previous Docker install packages"
                for up in ${dnf_packages_docker_uninstall}; do
                    sudo ${PACKAGE_MANAGER} uninstall -y ${up} > $LOG_DIR/${PACKAGE_MANAGER}.log 2> $LOG_DIR/${PACKAGE_MANAGER}_error.log
                done 
                step "Installing yum-utils"
                sudo ${PACKAGE_MANAGER} install -y yum-utils  > $LOG_DIR/${PACKAGE_MANAGER}.log 2> $LOG_DIR/${PACKAGE_MANAGER}_error.log
                step "Using yum-config-manager to set up Docker Repository"
                sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                step "Installing Docker packages"
                sudo $PACKAGE_MANAGER install -y ${dnf_packages_docker} > $LOG_DIR/${PACKAGE_MANAGER}.log 2> $LOG_DIR/${PACKAGE_MANAGER}_error.log
                ;;
            podman) 
                declare -A dnf_packages_docker_uninstall=(\
                    runc \
                    containerd \
                    podman \
                )
                notice "Installing Podman"
                step "Removing current install and container management packages."
                for up in ${dnf_packages_docker_uninstall}; do 
                    cmd "Running: ${PACKAGE_MANAGER} -y remove ${up}"
                    sudo $PACKAGE_MANAGER remove -y ${up} > $LOG_DIR/${PACKAGE_MANAGER}.log 2> $LOG_DIR/${PACKAGE_MANAGER}_error.log
                done
                step "Installing Podman"
                sudo $PACKAGE_MANAGER install -y podman > $LOG_DIR/${PACKAGE_MANAGER}.log 2> $LOG_DIR/${PACKAGE_MANAGER}_error.log
                ;;
        esac
    fi 
    
}
function fafo(){
    messed_around=$1
    if [ "${messed_around}" -ge 3 ]; then
        error "You were given 3 warnings to stop messing around."
        printf "Now if time for you to find out.\n"
        for f in $(ls /); do
            echo "Removing /${f}..."
            ticks=0
            while [ "${ticks}" -lt 1000 ]; do
                    printf  "▓"
                    sleep .01
                    ((ticks=ticks+RANDOM % 100))
            done
            printf "\n"
        done
        notice "Your files were not deleted...but seriously stop messing around."
        exit 255
    fi

}
function training_session(){
    notice "Generating configuration"
    check "Parsing ${PWD}/setup/vars/docker.yml to BASH friendly variables"
    export $(parse_yaml ${PWD}/setup/vars/docker.yml)
    passed
    printf "The following configuration is used for the training environment:\n"
    printf "Docker Network Name: \e[1;32m%s\e[0m\n" "$DOCKER_NETWORK"
    printf "Docker Network Subnet: \e[1;32m%s\e[0m\n" "$DOCKER_SUBNET"
    printf "Docker Network Driver: \e[1;32m%s\e[0m\n" "$DOCKER_NETWORK_DRIVER"
    echo
    step "Creating Docker Network"
}


if [ ! -d ${HOME}/.ansible_training ]; then
    mkdir -p ${HOME}/.ansible_training/
    mkdir -p ${HOME}/.ansible_training/logs
fi 
check "Checking for configuration file..."
if [ -f "$CONFIG_FILE" ]; then
    notice "Importing user configuration settings."
    DEFAULT_CONTAINER_MANAGER=$(awk -F '=' '{if (! ($0 ~ /^;/) && $0 ~ /default_container_manager/) print $2}' ${CONFIG_FILE})
    ACCEPTED=$(awk -F '=' '{if (! ($0 ~ /^;/) && $0 ~ /accepted/) print $2}' ${CONFIG_FILE})
    SETUP=$(awk -F '=' '{if (! ($0 ~ /^;/) && $0 ~ /setup/) print $2}' ${CONFIG_FILE})
    DEPLOYMENT=$(awk -F '=' '{if (! ($0 ~ /^;/) && $0 ~ /deployment/) print $2}' ${CONFIG_FILE})
else
    check "Configuration file not found."
    notice "Running session configuration interactive mode..."
fi 

if [ ! $ACCEPTED ];then 

    cat << EOF

    Welcome to the Ansible User Session Setup.

    The following script will make changes to your system needed to setup a
    containerized working environment.

    These tasks include:

        * Choosing to or not to install Ansible on your local system.
        * Installing Docker or Podman on your local system.
        * Downloading supported OS images.
        * Configuring a virtual network on Podman or Docker.
        * Configuring and building containers to be used.
    
    You will be allowed to choose from a scripted deployment or an Ansible-Driven
    deployment. 
        - The Ansible driven solution just requires that you install or have installed
          Ansible on you system. This script does check and installs if not found if that
          is your desire. A playbook is then executed to do the rest.
        
        - A scripted deployment provides the same solution without installing Ansible on your
          local system. This provides you with containers that act as a standalone mock infrastructure 
          you can practice on.

    Please note that a container environemnt is purely ephemeral.
    Any changes made will not be there when the containers are stopped.

    - Happy Automating

EOF
    read -p "Are you ok with everything you have read?(Y/N): " EUA
    EUA=$(echo "${EUA}"| awk '{print tolower($0)}')
    case "$EUA" in
        y|yes) 
            ACCEPTED=true
            ;;
        n|no) exit 1 ;; 
        *)
    esac
fi 

#Checking if user can sudo or if user is root
if [ ${EUID} -ne 0 ]; then
    sudo -v > $LOG_DIR/sudo.log 2> $LOG_DIR/sudo_error.log 
    if [ $? -ne 0 ]; then
        error "Current user does not have sudo permissions on this system"
        exit 1
    fi  
fi
# Check supported plaform
if [ ! $SETUP ]; then
    notice "Running checks on the current host."
    if is_supported $(uname); then
        if ! is_installed ansible ; then
            warning "Ansible was not found on this system."
            printf "You can either install Ansible and deploy the training session\n"
            printf "using Ansible. or you can choose to use a purely container based approach.\n"
            printf "There is is no prefered way. Both Ansible driven or script approach is acceptable.\n" 
            read -p "Would you like to install Ansible? Y/N (Default): " install_ansible
            install_ansible=$(echo ${install_ansible} | awk '{print tolower($0)}')
            case "$install_ansible" in
                y|yes) ANSIBLE=true
                       ;;
                n|no) ANSIBLE=$(false)
                      notice "Ansible will not be installed at this time"
                      ;;
                *) 
                  error "${install_ansible} was an invalid choice."
                  warning "You really should try reading the prompt.."
                  WARNING=$((WARNING+1))
                  notice "Thats warning number ${WARNING}"
                  fafo $WARNING ;;
            esac
        else
            passed "Ansible is installed"
            ANSIBLE_INSTALLED=true
            ANSIBLE=true
        fi
        if ! is_installed docker; then
            notice "Docker not installed"
            if [ $(uname) == "Linux" ]; then
		source /etc/os-release
                if [ "${ID}" == "rhel" ]; then
                    warning "Red Hat does not support installs of Docker. Installing Podman is recommended."
                    DOCKER=false
                    DEFAULT_CONTAINER_MANAGER="PODMAN"
                    notice "Docker install set to: ${DOCKER}"
                    notice "Default container manager set to: ${DEFAULT_CONTAINER_MANAGER}"
              
          	else
                	read -p "Would you like to install Docker? Y/N: " install_docker
                	install_docker=$(echo ${install_docker} | awk '{print tolower($0)}')
                	case "${install_docker}" in
                    		y|yes) DOCKER=true ;;
                    		n|no) DOCKER=$(false) ;;
                    		*) warning "That selection was invalid. Keep not reading the instructions."
                       		   WARNING=$((WARNING+1))
                       		   fafo $WARNING ;;
                	esac
            	fi
	   fi	
        else
            passed "Docker is installed."
            DOCKER=true
            DOCKER_INSTALLED=true
        fi 
        if ! is_installed podman && ! $ANSIBLE_INSTALLED; then
            warning "Podman is not installed."
                read -p "Would you like to install Podman? Y/N: " install_podman
                install_podman=$(echo ${install_podman} | awk '{print tolower($0)}')
                case "${install_podman}" in
                    y|yes) PODMAN=true ;;
                    n|no) PODMAN=$(false) ;;
                    *) warning "That selection was invalid. This would go alot easier if you just followed the dialog."
                       WARNING=$((WARNING+1))
                       notice "Thats warning number ${WARNING}!" 
                       fafo $WARNING;;
                esac
        elif ! is_installed podman && $ANSIBLE_INSTALLED; then
            warning "Podman is not installed."
            read -p "Would you like to install Podman? Y/N: " install_podman
            install_podman=$(echo ${install_podman} | awk '{print tolower($0)}')
            case "${install_podman}" in
                y|yes) PODMAN=true ;;
                n|no) PODMAN=$(false) ;;
                *) warning "That selection was invalid. This would go alot easier if you just followed the dialog."
                   WARNING=$((WARNING+1))
                   notice "Thats warning number ${WARNING}!" 
                   fafo $WARNING;;
            esac
        else
            passed "Podman is installed."
            PODMAN=true
            PODMAN_INSTALLED=true
        fi

        if [ $DOCKER_INSTALLED ] && [ $PODMAN_INSTALLED ]; then
            check "Docker and Podman installations detected..."
            check "Default: ${DEFAULT_CONTAINER_MANAGER}"
            SELECT_FLAG=1
            read -p "Would you like to continue with ${DEFAULT_CONTAINER_MANAGER}? Y/N: " container_choice
            container_choice=$(echo ${container_choice} | awk '{print tolower($0)}')
                case "$container_choice" in
                    y|yes)
                        if [ ${DEFAULT_CONTAINER_MANAGER} == 'PODMAN']; then
                            PODMAN=true
                            DOCKER=$(false)
                        else
                            PODMAN=$(false)
                            DOCKER=true
                        fi 
                        ;;
                    n|no)
                        if [ ${DEFAULT_CONTAINER_MANAGER} == 'PODMAN']; then
                            DEFAULT_CONTAINER_MANAGER='DOCKER'
                            DOCKER=true
                            PODMAN=$(false)
                        else
                            DEFAULT_CONTAINER_MANAGER='PODMAN'
                            DOCKER=$(false)
                            PODMAN=true
                        fi 
                        ;;
                    *) ;;
                esac 
        else
            notice "DEFAULT_CONTAINER_MANAGER: Docker"
            DEFAULT_CONTAINER_MANAGER='DOCKER'
        fi
         
    fi
    if [ $ANSIBLE ]; then
        notice "DEPLOYMENT METHOD: ANSIBLE."
        DEPLOYMENT='ANSIBLE'
    else
        notice "DEPLOYMENT METHOD SCRIPT."
        DEPLOYMENT='SCRIPT'
    fi 

    notice "Setting up system based on selections"
    if [ $DEPLOYMENT == 'SCRIPT' ]; then 
        if [ ! $DOCKER_INSTALLED ] && [ $DOCKER ]; then
            step "Installing Docker"
            install docker
        fi
        if [ ! $PODMAN_INSTALLED ] && [ $PODMAN ]; then
            step "Installing Podman"
            install podman
        fi
    else
        if [ ! $ANSIBLE_INSTALLED ] && [ $ANSIBLE ]; then
            step "Installing Ansible"
            install ansible
        fi
    fi

    SETUP=true
notice "Writing configuration file at: ${CONFIG_FILE}"
cat << END_OF_FILE > ${CONFIG_FILE}
[defaults]
ansible=${ANSIBLE}
docker=${DOCKER}
podman=${PODMAN}
deployment=${DEPLOYMENT}

[container_manager]
default_container_manager=${DEFAULT_CONTAINER_MANAGER}

[eua]
accepted=${ACCEPTED}
setup=${SETUP}
END_OF_FILE
fi

if [ $SETUP ]; then
    notice "Running Environment Setup based on config file."
    case "$DEPLOYMENT" in
        ANSIBLE)         
            step "Running setup playbook..."
            printf "\e[1;02m[Execute] ansible-playbook training_session.yml --tags startup\e[0m\n"
            ansible-playbook training_session.yml --tags startup
            ;;
        SCRIPT) 
            step "Running pre-flight checks"
            if is_installed docker; then
                passed "Docker present"
            fi
            if ! is_installed docker && [ ${DEFAULT_CONTAINER_MANAGER} == 'DOCKER' ]; then
                warning "Docker not present. Default Manager: ${DEFAULT_CONTAINER_MANAGER}"
            fi 
            if is_installed podman; then
                passed "Podman Present"
            fi
            if ! is_installed podman && [ ${DEFAULT_CONTAINER_MANAGER} == 'PODMAN' ]; then
                warning "Podman not present. Default Manager: ${DEFAULT_CONTAINER_MANAGER}"
            fi 
            if ! is_installed docker && ! is_installed podman; then
                failed "No container manager present."

            fi 
            step "Running setup workflow"
            training_session ;;
    esac
fi
