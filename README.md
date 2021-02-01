# **Grafana Buildpack**

This build pack deploys the specified version of Grana to your cloud foundry and, it is designed to work with GDS PaaS 

## **Features**
- It can install user specified version of grafana
- It can automatically select between sqllite3 or compitable database ( Postgres ) to bind or It connect to user specified database 

## **Limitations**
- supports only Postgres and Sqlite3

## **Note**
Use postgres db if you would like to preserve your configuration and , dashboards between deployments 

## **Example manifest.yml**

```yaml
---
applications:
  - buildpacks:
      - https://github.com/uktrade/grafana-buildpack.git
```

cf v2 command
```bash
cf push 
```

cf v3 command
```bash
cf v3-push -b https://github.com/uktrade/grafana-buildpack.git
```


## **Configu variables**

| Variable                | Default Value |
|:------------------------|:--------------|
| $APP_MODE               | production    |
| $ADMIN_USER             | admin         |
| $ADMIN_PASSWORD         | admin         |
| $SECRET_KEY             | space guid    |
| $AUTO_DB_SETUP          | false         |
| $GRAFANA_DB_SERVICE_NAME| null          |
| $ENABLE_ANONYMOUS_ACCESS| false         |
| $ANONYMOUS_USER_ROLE    | Viewer        |
| $ANONYMOUS_USER_ORG_NAME| Main Org.     |
| $AUTO_ASSIGN_ORG        | true          |
| $AUTO_ASSIGN_ORG_ROLE   | Viewer        |

## **Custom Config Files**
- **runtime.txt**: User can specify the version of Grafana that needs to be installed , current default version is 6.3.5

- **grafana.ini**: With this file , user can override the default configuration

## Todo
- Validate downloaded file with checksum
- make it work with mysql, currently Grafana seems to have trouble with useSSL=True in mysql URI and, suggested work around is to use ClOUD SQL PROXY , which is something needs to be done if need arises