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

function get_node_port() {
    service_name=$1
    namespace=$2
    portname=$3

    if [[ "${portname}" ]]
    then
        port=$(kubectl get service ${service_name} -n ${namespace} -o jsonpath="{.spec.ports[?(@.name=='${portname}')]..nodePort}")
    else
        port=$(kubectl get service ${service_name} -n ${namespace} -o jsonpath="{.spec.ports..nodePort}")
    fi

    echo "${port}"
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