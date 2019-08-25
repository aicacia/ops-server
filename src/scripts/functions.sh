function kubectl_with_environment() {
    command=$1
    file=$2

    envsubst < ${file} > ${file}.bak
    kubectl ${command} -f ${file}.bak
    rm ${file}.bak
}

function wait_for_deployment() {
    deployment=$1
    namespace=$2
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

function add_environment_variable() {
    variable=$1
    value=$2
    file=$3

    grep -q -F "export ${variable}=\"${value}\"" ${file} || echo "export ${variable}=\"${value}\"" >> ${file}
}

function begin_readme_section() {
    title=$1
    readme_file=$2

    echo "====================================================================" >> ${readme_file}
    echo " " >> ${readme_file}
    echo "${title}" >> ${readme_file}
    echo " " >> ${readme_file}
}

function end_readme_section() {
    readme_file=$1

    echo " " >> ${readme_file}
    echo "====================================================================" >> ${readme_file}
}

function add_to_readme() {
    text=$1
    line_break=$2
    readme_file=$3

    if [[ "${line_break}" == "before" || "${line_break}" == "both" ]]
    then
        echo " " >> ${readme_file}
    fi

    echo "   ${text}" >> ${readme_file}

    if [[ "${line_break}" == "end" || "${line_break}" == "both" ]]
    then
        echo " " >> ${readme_file}
    fi    
}

function get_ssh_key() {
    local user_home=$1

    if [[ -d "${user_home}/.ssh" ]]
    then
        mkdir -p ${HOME}/.ssh
        cp -r ${user_home}/.ssh/* ${HOME}/.ssh
        chmod 600 ${HOME}/.ssh/*
    fi

    selected_key_path=""
    if [[ -d "${HOME}/.ssh" ]]
    then
        key_files=$(ls -1 ${HOME}/.ssh | grep -v ".pub" | grep -v "known_hosts")
        if [[ ! -z "${key_files}" ]]
        then
            echo " "
            echo "Select a private ssh key file to be used to access nodes within the cluster, or press return"
            echo "to be prompted for the path to a private ssh key file."
            echo " "
            index=0
            items=()
            for key_file in ${key_files}
            do
                index=$((${index}+1))
                items+=(${key_file})
                echo "${index}. ${key_file}"
            done
            echo " "
            read -p "Enter a value between 1 and ${index}, or press return to be prompted for the path to a private ssh key file: " selected_index

            if [[ ! -z "${selected_index}" ]]
            then
                selected_key_path=${HOME}/.ssh/${items[$((${selected_index}-1))]}
            fi
        fi
    fi

    if [[ -z "${selected_key_path}" ]]
    then
        echo " "
        echo "To interact with the Kubernetes cluster, a private ssh key file is required. This ssh key should already"
        echo "be configured as an authorized key to access all nodes in the Kubernetes cluster. No private ssh key"
        echo "files were found in \${HOME}/.ssh. You will be prompted to enter the full path to the ssh key file to"
        echo "be used when accessing the cluster."
        echo " "
        echo "This script accesses your workstation's HOME directory through a Docker volume mount point. You may"
        echo "reference a private ssh key file available on your home directory by specifying the path relatrive to your"
        echo "home directory. For example, if your private ssh key file is located at \${HOME}/mykeys/private_key, you"
        echo "would enter mykeys/private_key in the prompt below."
        echo " "
        while true
        do
            echo "Please enter the full path to the private ssh key file to be used. If you do not have a private ssh key file,"
            echo "at the prompt, press return without an entry."
            echo " "
            read -p "Full path to the private ssh key file to be used: " selected_key_path
            if [[ ! -z "${selected_key_path}" && -e "/setup/home/${selected_keypair_path}" ]]
            then
                selected_key_path="/setup/home/${selected_key_path}"
                mkdir -p /root/.ssh
                ssh_key_file=$(basename ${selected_key_path})
                cp ${selected_key_path} ${HOME}/.ssh/${ssh_key_file}
                selected_key_path=${HOME}/.ssh/${aws_key_file}
                chmod 600 ${HOME}/.ssh/*
                break
            else
                if [[ -z ${selected_key_path} ]]
                then
                    echo " "
                    echo "Once you have a private ssh key file, you can restart this script to complete the process."
                    exit
                else
                    echo " "
                    echo "The file ${selected_key_path} does not exist."
                fi
            fi
        done
    fi

    if [[ ! -z ${selected_key_path} ]]
    then
        permissions=$(stat -c %a ${selected_key_path})
        if [[ "${permissions}" != "600" ]]
        then
            echo " "
            echo "The ssh key file, ${selected_key_path} has incorrect permissions. SSH key files cannot be"
            echo "accessible by other users."
            echo " "
            echo "This script will attempt to set the permissions on ${selected_key_path}."
            echo " "
            chmod 600 ${selected_key_path}
            permissions=$(stat ${stat_options} ${selected_key_path})
            if [[ ! "${permissions}" == "600" ]]
            then
                echo "The script is unable to set the private ssh key file permissions."
                echo "Please correct the permissions (600) and restart the script."
                echo " "
                exit
            else
                echo "Permissions have been set correctly. The cluster creation process will continue."
                echo " "
            fi
        fi
    fi
}

function get_hosts() {
    local cluster_name=$1
    local node_type=$2
    local user_home=$3
    local ssh_user=$4
    local ssh_key=$5

    echo " "
    echo "The following will prompt for ${node_type} host names and/or IP addreses. Multiple hosts may be supplied. The"
    echo "ssh information previously provided will be used to validate that each server is accessible and that the ssh"
    echo "credentials can be used to log into the host. The user associated with the ssh credentials must have sudo"
    echo "permissions on each specified host."

    nodes_file=${node_type}.nodes
    local host_provided="false"
    while true
    do
        echo " "
        read -p "Host name/IP address for ${node_type}: " host
        if [[ ! -z "${host}" ]]
        then
            is_valid=$(python3 /root/k8s/kubeadm/kubeadm-regex-test.py ${host})
            if [[ "${is_valid}" == "true" ]]
            then
                echo "Checking access to host ${host}."
                nc -z ${host} 22
                if [[ "$?" == "0" ]]
                then
                    echo "Validating login access."
                    ssh -i ${ssh_key} ${ssh_user}@${host} ls 2>&1 > /dev/null
                    if [[ "$?" == "0" ]]
                    then
                        echo "Validating sudo permissions."
                        ssh -i ${ssh_key} ${ssh_user}@${host} sudo id 2>&1 > /dev/null
                        if [[ "$?" == "0" ]]
                        then
                            echo ${host} >> ${nodes_file}
                            host_provided="true"
                        else
                            echo "Unable to validate sudo permissions on host ${host}."
                        fi                   
                    else
                        echo "Unable to log into host ${host}."
                    fi
                else
                    echo "Unable to access ssh port (22) on host ${host}."
                fi
            else
                echo "Invalid hostname or IP address."
            fi
        elif [[ "${host_provided}" == "false" ]]
        then
            echo "At least one ${node_type} node must be specified."
        else
            break
        fi
   done
}