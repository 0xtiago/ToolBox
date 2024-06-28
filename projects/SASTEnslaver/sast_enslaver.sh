#!/bin/bash

# Configurations
config_file="config.yml"

#Clean logs
# rm -rf log/*.log


# Validations

## Create log folder
if [ ! -d log ]; then
  mkdir log
fi

#END_VALIDATION




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
eval $(parse_yaml $config_file)

print_usage(){
    echo "-> $ ./sast_stress.sh -t {checkmarx|veracode} -s {PASTA DO PROJETO} -p {NOME DO PROJETO} -n {QTDE DE SCANS}"
}

multipleScanCX () {
    i=1
    while [ $i -le $number_of_scans ]; do
        echo -e "Checkmarx Scan #$i"
        $checkmarx_bin --tenant $checkmarx_tenant --agent $checkmarx_agent --apikey  $checkmarx_apikey --base-uri $checkmarx_base_uri --base-auth-uri $checkmarx_base_auth_uri \
                scan create --project-name $project_name-$i -s $source -b main \
                 --tags $checkmarx_tags --agent $checkmarx_agent --async >> log/checkmarx.log 2>&1 &
        i=$((i+1))
    done
}


multipleScanVeracode () {

    #Configure veracode bin

    if [ ! -f bin/veracode/veracode ]; then
        echo "I N S T A L A N D O   V E R A C O D E   C L I!!!"
        cd $veracode_bin
        curl -fsS https://tools.veracode.com/veracode-cli/install | sh
        cd ../..
    fi
    



    #Packaging source and extract location
    $veracode_bin/veracode package --source $source --output $veracode_package_folder --trust --debug 2>&1  | tee $veracode_package_log
    
    veracode_package_file=$(cat tee $veracode_package_log | grep "Created zip file:" | cut -d " " -f4)

    

    if [ ! -f $veracode_bin/veracode-wrapper.jar ]; then
        #Preparing Wrapper
        wget --backups=1 https://repo1.maven.org/maven2/com/veracode/vosp/api/wrappers/vosp-api-wrappers-java/maven-metadata.xml -P $veracode_bin
            veracodeWrapperVersion=$(xmlstarlet select --template \
                        --value-of /metadata/versioning/latest \
                        --nl $veracode_bin/maven-metadata.xml)
    
        wget --backups=1 https://repo1.maven.org/maven2/com/veracode/vosp/api/wrappers/vosp-api-wrappers-java/$veracodeWrapperVersion/vosp-api-wrappers-java-$veracodeWrapperVersion.jar \
         -O $veracode_bin/veracode-wrapper.jar
    fi

    


    i=1
    while [ $i -le $number_of_scans ]; do
        versao=$(date +%Y%m%d%H%M%S%N)
        echo -e "Veracode Scan #$i"
        java -jar $veracode_bin/veracode-wrapper.jar -vid $veracode_api_key_id -vkey $veracode_api_key_secret \
             -tags $veracode_tags -custom1 $veracode_custom1 -customfieldname $veracode_customfieldname -customfieldvalue $veracode_customfieldvalue \
            -action uploadandscan -appname $project_name-$i -createprofile true -filepath "$veracode_package_file"  \
            -debug -version $versao  true -deleteincompletescan 2  -logfilepath $veracode_wrapper_log &

        i=$((i+1))
    done


    #COM PROXY PARA TESTES
    # i=1
    # while [ $i -le $number_of_scans ]; do
    #     versao=$(date +%Y%m%d%H%M%S%N)
    #     echo -e "Veracode Scan #$i"
    #     java -jar $veracode_bin/veracode-wrapper.jar -vid $veracode_api_key_id -vkey $veracode_api_key_secret \
    #         -action uploadandscan -appname $project_name-$i -createprofile true -filepath "$veracode_package_file" -tags $veracode_tags -customfieldname $veracode_customfieldname -customfieldvalue $veracode_customfieldvalue -phost "localhost" -pport 8080 \
    #         -debug -version $versao  true -deleteincompletescan 2  -logfilepath $veracode_wrapper_log &

    #     i=$((i+1))
    # done

}

while getopts ":t:s:p:n:" opt;
do
    case "${opt}" in
        t)
            tool=${OPTARG}
            ;;
        s) 
            source=${OPTARG}
            ;;
        p) 
            project_name=${OPTARG}
            ;;
        n) 
            number_of_scans=${OPTARG}
            ;;
        
        :)
            echo "Opção -${OPTARG} requer um argumento."
            print_usage
            exit 1
            ;;

        ?)
            echo "Opção inválida: -${OPTARG}."
            print_usage
            exit 1
            ;;
    esac
done





if [[ "$tool" == "checkmarx" ]]; then
    multipleScanCX
elif [[ "$tool" == "veracode" ]]; then
    multipleScanVeracode
else
    echo "Ferramenta não encontrada"
    print_usage
fi
