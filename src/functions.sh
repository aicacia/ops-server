function cluster_home() {
    echo "${HOME}/clusters/${cluster_name}"
}
function variable_file() {
    echo "$(cluster_home)/variable_file.sh"
}
function envrc_file() {
    echo "$(cluster_home)/.envrc"
}
function readme_file() {
    echo "$(cluster_home)/README.md"
}
function nodes_file() {
    local node_type=$1
    echo "$(cluster_home)/${node_type}.nodes"
}

if [ -f $(envrc_file) ];
then
    source $(envrc_file)
fi
if [ -f $(variable_file) ];
then
    source $(variable_file)
fi

function init_callback() {
    mkdir -p $(cluster_home)
    touch $(variable_file)
    
    add_variable "home_dir" ${HOME}
    add_variable "user_name" ${USER}
}
function end_callback() {
    chown ${user_name}.${user_name} -R $(cluster_home)
}

function install_init_callback() {
    init_callback
}
function install_end_callback() {
    end_callback
}

function update_init_callback() {
    init_callback
}
function update_end_callback() {
    end_callback
}

function remove_init_callback() {
    init_callback
}
function remove_end_callback() {
    end_callback
    rm -rf $(cluster_home)
}

function exit_failure() {
    echo $1
    exit 1
}

function kubectl_with_environment() {
    local command=$1
    local file=$2
    local opts=FOO=${3:=""}

    envsubst < ${file} > ${file}.bak
    kubectl ${command} -f ${file}.bak ${opts}
    rm ${file}.bak
}

function wait_for_deployment() {
    local deployment=$1
    local namespace=$2

    echo "Ensuring ${deployment} is succesfully deployed..."
    while true
    do
        kubectl rollout status deploy/${deployment} -n ${namespace}
        if [[ $? -ne 0 ]]
        then
            sleep 5
        else
            break;
        fi
    done

    echo "${deployment} is available."
}

function add_variable() {
    local variable=$1
    local value=$2

    sed -i "/${variable}=/d" $(variable_file)
    echo "${variable}=\"${value}\"" >> $(variable_file)

    if [ -f $(variable_file) ];
    then
        source $(variable_file)
    fi
}

function add_environment_variable() {
    local variable=$1
    local value=$2
    local file=$3

    sed -i "/${variable}=/d" ${file}
    echo "export ${variable}=\"${value}\"" >> ${file}

    if [ -f ${file} ];
    then
        source ${file}
    fi
}

function begin_readme_section() {
    local title=$1

    echo "Executing ${title} installation process."

    echo "====================================================================" >> $(readme_file)
    echo " " >> $(readme_file)
    echo "${title}" >> $(readme_file)
    echo " " >> $(readme_file)
}

function end_readme_section() {
    local title=$1

    echo "${title} installation process complete."
    echo " " >> $(readme_file)
    echo "====================================================================" >> $(readme_file)
}

function add_to_readme() {
    local text=$1
    local line_break=$2

    if [[ "${line_break}" == "before" || "${line_break}" == "both" ]]
    then
        echo " " >> $(readme_file)
    fi

    echo "  ${text}" >> $(readme_file)

    if [[ "${line_break}" == "end" || "${line_break}" == "both" ]]
    then
        echo " " >> $(readme_file)
    fi    
}

function is_valid_ip() {
    local ip=$1
    local stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    
    return $stat
}

function execute_as_user() {
    local command=$1
    su -c "${command}" - ${user_name}
}

function get_host() {
    local node_type=$1
    local ssh_user=$2
    local nodes_file=$(nodes_file ${node_type})

    read -p "Host name/IP address for ${node_type}: " host
    if [[ ! -z "${host}" ]]
    then
        if is_valid_ip ${host};
        then
            echo "Checking access to host ${host}."
            nc -z ${host} 22
            if [[ "$?" == "0" ]]
            then
                echo "Validating sudo permissions."
                ssh ${ssh_user}@${host} sudo id 2>&1 > /dev/null
                if [[ "$?" == "0" ]]
                then
                    echo ${host} >> ${nodes_file}
                else
                    exit_failure "Unable to validate sudo permissions on host ${host}."
                fi 
            else
                exit_failure "Unable to access ssh port (22) on host ${host}."
            fi
        else
            exit_failure "Invalid hostname or IP address."
        fi
    fi
}

function get_hosts() {
    local node_type=$1
    local ssh_user=$2
    local nodes_file=$(nodes_file ${node_type})

    while true
    do
        read -p "Host name/IP address for ${node_type}: " host
        if [[ ! -z "${host}" ]]
        then
            if is_valid_ip ${host};
            then
                echo "Checking access to host ${host}."
                nc -z ${host} 22
                if [[ "$?" == "0" ]]
                then
                    echo "Validating sudo permissions."
                    ssh ${ssh_user}@${host} sudo id 2>&1 > /dev/null
                    if [[ "$?" == "0" ]]
                    then
                        echo ${host} >> ${nodes_file}
                        host_provided="true"
                    else
                        echo "Unable to validate sudo permissions on host ${host}."
                    fi 
                else
                    echo "Unable to access ssh port (22) on host ${host}."
                fi
            else
                echo "Invalid hostname or IP address."
            fi
        elif [[ "${host_provided}" == "false" ]]
        then
            exit_failure "At least one ${node_type} node must be specified."
        else
            break
        fi
    done
}