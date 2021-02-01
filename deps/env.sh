#!/user/bin/env bash
export_app_env(){

    export APP_ROOT="${HOME}"
    export APP_MODE="${APP_MODE:-production}"
    export APP_DATA_DIR="${APP_ROOT}/data"
    export APP_PLUGINS_DIR="${APP_DATA_DIR}/plugins"
    export APP_LOGS_DIR="${APP_DATA_DIR}/log"

    export APP_PROVISIONING_DIR="${APP_ROOT}/conf/provisioning"

    export DOMAIN=${DOMAIN:-$(jq -r '.uris[0]' <<<"${VCAP_APPLICATION}")}
    export URL="${URL:-https://${DOMAIN}}"

    export ADMIN_USER="${ADMIN_USER:-admin}"
    export ADMIN_PASS="${ADMIN_PASS:-admin}"
    export SECRET_KEY=${SECRET_KEY:-$(jq -r '.space_id' <<<"${VCAP_APPLICATION}")}
    export APP_LOG_MODE="${APP_LOG_MODE:-console}"

    export ENABLE_ANONYMOUS_ACCESS="${ENABLE_ANONYMOUS_ACCESS:-false}"
    export ANONYMOUS_USER_ROLE="${ANONYMOUS_USER_ROLE:-Viewer}"
    export ANONYMOUS_USER_ORG_NAME="${ANONYMOUS_USER_ORG_NAME:-Main Org.}"
    export AUTO_ASSIGN_ORG="${AUTO_ASSIGN_ORG:-true}"
    export AUTO_ASSIGN_ORG_ROLE="${AUTO_ASSIGN_ORG_ROLE:-Viewer}"
}

export_db_env(){

    export AUTO_DB_SETUP="${AUTO_DB_SETUP:-fale}"
    export GRAFANA_DB_SERVICE_NAME="${GRAFANA_DB_SERVICE_NAME:-null}"

    local db=''

    if [ "${GRAFANA_DB_SERVICE_NAME}" != null ] 
    then 
        export AUTO_DB_SETUP=false
        db=$(jq -r --arg instance_name $GRAFANA_DB_SERVICE_NAME '.[][] | select(.instance_name == $instance_name)' <<<  "${VCAP_SERVICES}")
        #if DB is not found , let user know 
        if [ -z "${db}" ]
        then
            echo "Service ${GRAFANA_DB_SERVICE_NAME} not found"
        fi
    fi

    if [[ "${AUTO_DB_SETUP}" == true || "${AUTO_DB_SETUP}" == True || "${AUTO_DB_SETUP}" == TRUE || "${AUTO_DB_SETUP}" == 1 ]] 
    then
        db=$(jq -r '.[][] | select(.label == ("postgres","mysql"))' <<<  "${VCAP_SERVICES}")
        #if DB is not found , let user know 
        if [ -z "${db}" ]
        then
            echo "AUTO_DB_SETUP did not find any supported databases"
        fi
    fi

    local dbtype=$(jq -r '.label' <<< "${db}")
    local dbname=$(jq -r '.credentials.database' <<< "${db}")
    local dbuser=$(jq -r '.credentials.username' <<< "${db}")
    local dbpass=$(jq -r '.credentials.password' <<< "${db}")
    local dbhost=$(jq -r '.credentials.hostname' <<< "${db}")
    local dbport=$(jq -r '.credentials.port' <<< "${db}")
    local dburi=$(jq -r '.credentials.uri' <<< "${db}")

    export DB_TYPE="${dbtype:-sqlite3}"
    export DB_NAME="${dbname:-grafana}"
    export DB_USER="${dbuser:-root}"
    export DB_PASSWORD="${dbpass:-}"
    export DB_HOSTNAME="${dbhost:-}"
    export DB_PORT="${dbport:-}"
    export DB_URI="${dburi:-${DB_TYPE}://${DB_USER}:${DB_PASSWORD}@${DB_HOSTNAME}:${DB_PORT}/${DB_NAME}}"

    export DB_SSL_MODE=""
    export CA_CERT_PATH=""
    
    if [[ ${DB_TYPE} == "postgres" ]]
    then
        export DB_SSL_MODE="require"
    fi
    
    if [[ ${DB_TYPE} == "mysql" ]]
    then
        export DB_SSL_MODE="skip-verify"
        export CA_CERT_PATH="/etc/ssl/certs/ca-certificates.crt"
    fi
}

main(){
    export_app_env
    export_db_env
}

main