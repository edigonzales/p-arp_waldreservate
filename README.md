# p-arp_waldreservate

- Teilgebiet-Beispiel: 11.004A

## Manuelle Arbeiten nach SOGIS->Edit
- Code
- einige Flurnamen
- fehlende RRB und fehlende Attribute. Achtung es gibt ein Dummy-RRB. Dieser ist mit den Waldreservaten verknüpft. D.h. man kann nicht bloss diesen Dummy einmal ersetzen, sondern x-fach und die Beziehung muss mehrfach erfasst werden.


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

Im sogis/gretljobs-Repo-Ordner
```
docker-compose up
```

```
./start-gretl.sh --docker-image sogis/gretl:latest --docker-network gretljobs_default --job-directory $PWD/transfer_from_sogis tasks --all
./start-gretl.sh --docker-image sogis/gretl:latest --docker-network gretljobs_default --job-directory $PWD/transfer_from_sogis createSchema transferData
./start-gretl.sh --docker-image sogis/gretl:latest --docker-network gretljobs_default --job-directory $PWD/datenumbau tasks --all
./start-gretl.sh --docker-image sogis/gretl:latest --docker-network gretljobs_default --job-directory $PWD/datenumbau transferData exportData validateData
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

## Datenimport
```
java -jar ../apps/ili2pg-4.3.1/ili2pg-4.3.1.jar --dbhost geodb-t.rootso.org --dbport 5432 --dbdatabase edit --dbusr USERNAME --dbpwd PASSWORD --dbschema arp_waldreservate_v1 --models SO_ARP_Waldreservate_20220607 --dbparams db.properties --import ch.so.arp.waldreservate_edit.xtf
```