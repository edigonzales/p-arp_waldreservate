# p-arp_waldreservate

- Teilgebiet-Beispiel: 11.004A


## GRETL-Jobs
```
export ORG_GRADLE_PROJECT_dbUriSogis="jdbc:postgresql://geodb.verw.rootso.org:5432/sogis"
export ORG_GRADLE_PROJECT_dbUserSogis="aaaaa"
export ORG_GRADLE_PROJECT_dbPwdSogis="bbbbbb"
export ORG_GRADLE_PROJECT_dbUriEdit=jdbc:postgresql://edit-db/edit
export ORG_GRADLE_PROJECT_dbUserEdit=admin
export ORG_GRADLE_PROJECT_dbPwdEdit=admin
export ORG_GRADLE_PROJECT_dbUriPub=jdbc:postgresql://pub-db/pub
export ORG_GRADLE_PROJECT_dbUserPub=admin
export ORG_GRADLE_PROJECT_dbPwdPub=admin
```

Im gretljobs-Repo-Ordner
```
docker-compose up
```

```
./start-gretl.sh --docker-image sogis/gretl:latest --docker-network gretljobs_default --job-directory $PWD/transfer_from_sogis tasks --all
```

## Schema-Jobs
```
export ORG_GRADLE_PROJECT_dbUriEdit=jdbc:postgresql://edit-db/edit
export ORG_GRADLE_PROJECT_dbUserEditDdl=admin
export ORG_GRADLE_PROJECT_dbPwdEditDdl=admin
export ORG_GRADLE_PROJECT_dbUriPub=jdbc:postgresql://pub-db/pub
export ORG_GRADLE_PROJECT_dbUserPubDdl=admin
export ORG_GRADLE_PROJECT_dbPwdPubDdl=admin
```

Mit Docker-DB der GRETL-Jobs (siehe Netzwerk):
```
./start-gretl.sh --docker-image sogis/gretl:latest --docker-network gretljobs_default --topic-name arp_waldreservate --schema-dirname schema dropSchemaShared
./start-gretl.sh --docker-image sogis/gretl:latest --docker-network gretljobs_default --topic-name arp_waldreservate --schema-dirname schema createRolesDevelopment
./start-gretl.sh --docker-image sogis/gretl:latest --docker-network gretljobs_default --topic-name arp_waldreservate --schema-dirname schema createSchema configureSchema grantPrivileges
```