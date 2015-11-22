# docker-openemm
OpenEMM 2015 R2 dockerized

### Installation

Create two databases with the same prefix, e.g.:

```bash
   mysqladmin create openemm_docker
   mysqladmin create openemm_docker_cms
```

Import the databases:

```bash
   wget "http://downloads.sourceforge.net/project/openemm/OpenEMM%20software/OpenEMM%202015/OpenEMM-2015_R2-bin_x64.tar.gz" -O OpenEMM-2015_R2-bin_x64.tar.gz
   tar xvzf OpenEMM-2015_R2-bin_x64.tar.gz ./USR_SHARE/openemm-2015_R2.sql
   tar xvzf OpenEMM-2015_R2-bin_x64.tar.gz ./USR_SHARE/openemm_cms-2015.sql
   mysql openemm_docker <./USR_SHARE/openemm-2015_R2.sql
   mysql openemm_docker_cms <./USR_SHARE/openemm_cms-2015.sql
```

Grant openemm access to its databases:

```bash
   GRANT ALL ON openemm_docker.* TO openemm_docker@'%' IDENTIFIED BY 'yourpass';
   GRANT ALL ON openemm_docker_cms.* TO openemm_docker@'%' IDENTIFIED BY 'yourpass';
```

Pull image:

```bash
   docker pull nervous/openemm
```
	
### Usage 

Assumptions:

* The URL of OpenEMM will be: http://myemmhostname:8080
* MySQL is running on the Docker host and listening on 172.17.42.1:3306
* The DB names are openemm_docker and openemm_docker_cms
* The DB user is openemm_docker and pass is 'yourpass'.
* You don't want to use the SMTP built into OpenEMM, you will use a pre-configured SMTP relay at smtp-relay-hostname:25
* The app will be installed on a volume, to make sure that logs, spool dir are persistent.

```bash
   docker run -p 8080:8080 -v /home/openemm:/home/openemm \
      -e OPENEMM_HOST=myemmhostname -e OPENEMM_PORT=8080 \
      -e MYSQL_USER=openemm_docker -e MYSQL_PASS=yourpass -e MYSQL_HOST=172.17.42.1 -e MYSQL_DB=openemm_docker \
      -e SMTP_HOST=smtp-relay-hostname \
      --name openemm -d --restart=always openemm
```

### DEBUGGING

Check the logs:

```bash
   docker logs -f openemm
```

Or dig into /home/openemm/logs on the Docker host.

### TODO

* Handle async bounces automatically.
* Only put logs and spool dirs on persistent storage

### Credits

Originally based on the work of https://registry.hub.docker.com/u/bulktrade/openemm/
