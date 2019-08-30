cluster_home=$HOME/.cluster
readme_file=$cluster_home/README.md
variable_file=$cluster_home/variable_file.sh
envrc_file=$cluster_home/.envrc

if [ -f ${variable_file} ];
then
    source ${variable_file}
fi

if [ -f ${envrc_file} ];
then
    source ${envrc_file}
fi

function init_callback() {
    mkdir -p ${cluster_home}
    touch ${variable_file}
    
    add_variable "tiller_namespace" "kube-system"
    add_variable "node_type" "master"
    add_variable "cluster_name" "master"
}
function end_callback() {
    rm ${variable_file}
    chown $USER.$USER -R $cluster_home
}

function install_init_callback() {
    init_callback
    touch ${readme_file}
}
function install_end_callback() {
    end_callback
}

function remove_init_callback() {
    init_callback
}
function remove_end_callback() {
    end_callback
    rm -rf ${cluster_home}
}

function exit_failure() {
    echo $1
    exit 1
}

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

function add_variable() {
    variable=$1
    value=$2

    sed -i "/${variable}=\"${value}\"/d" ${variable_file}
    echo "${variable}=\"${value}\"" >> ${variable_file}

    source ${variable_file}
}

function add_environment_variable() {
    variable=$1
    value=$2
    file=$3

    sed -i "/${variable}=\"${value}\"/d" ${file}
    echo "export ${variable}=\"${value}\"" >> ${file}

    source ${envrc_file}
}

function begin_readme_section() {
    title=$1

    echo "Executing ${title} installation process."

    echo "====================================================================" >> ${readme_file}
    echo " " >> ${readme_file}
    echo "${title}" >> ${readme_file}
    echo " " >> ${readme_file}
}

function end_readme_section() {
    title=$1

    echo "${title} installation process complete."
    echo " " >> ${readme_file}
    echo "====================================================================" >> ${readme_file}
}

function add_to_readme() {
    text=$1
    line_break=$2

    if [[ "${line_break}" == "before" || "${line_break}" == "both" ]]
    then
        echo " " >> ${readme_file}
    fi

    echo "  ${text}" >> ${readme_file}

    if [[ "${line_break}" == "end" || "${line_break}" == "both" ]]
    then
        echo " " >> ${readme_file}
    fi    
}