# Docker Redmine
* Debian
* nginx
* RVM
* SQLite3

## Build
Use ./build.sh script.

## Commands

Create container
```
docker run -t --name redmine -p 80:80 redmine-img
```

Start/stop container
```
docker start redmine
docker stop redmine
```

Connect to running container
```
docker exec -it redmine /bin/bash
```

# Copy database
```
docker cp redmine_18-12-03_14-15-01.sq3.bak redmine:/home/redmine/redmine-3.4.6/db/redmine.sqlite3
```

# Install plugins
```
cd /usr/share/redmine/plugins/
tar cvfz plugins.tar.gz financial_management time_logger
docker cp plugins.tar.gz redmine:/home/redmine/redmine-3.4.6/plugins/

# Inside Redmine container
su redmine
cd redmine-3.4.6/plugins
tar xvfz plugins.tar.gz
rm plugins.tar.gz
cd ..
source /usr/local/rvm/scripts/rvm
bundle install --without development test
```
