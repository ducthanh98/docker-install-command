# docker-install-command

# MSSQL
```
docker volume create vmssql
docker run -e 'ACCEPT_EULA=Y' --name mssql-2019 -e 'SA_PASSWORD=16151472aA!' -p 1433:1433 -v vmssql:/var/opt/mssql -d mcr.microsoft.com/mssql/server:2019-latestD
```
# MONGODB
```
docker volume create vmongo
docker run -p 27017:27017 --name=mongodb -v vmongo:/data/db -d -e 'ME_CONFIG_MONGODB_ADMINUSERNAME=root' -e 'ME_CONFIG_MONGODB_ADMINPASSWORD:16151472aA!' mongo
```