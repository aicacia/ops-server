readme_file=$HOME/.cluster/CLUSTER_README.md

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

    echo "====================================================================" >> ${readme_file}
    echo " " >> ${readme_file}
    echo "${title}" >> ${readme_file}
    echo " " >> ${readme_file}
}

function end_readme_section() {
    echo " " >> ${readme_file}
    echo "====================================================================" >> ${readme_file}
}

function add_to_readme() {
    text=$2
    line_break=$3

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