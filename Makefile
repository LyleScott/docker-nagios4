APPNAME="nagios4"
HOST_PORT=4443
CONTAINER_PORT=443

build:
	docker build -t lylescott/${APPNAME} .

run:
	docker run -i -t -p ${HOST_PORT}:${CONTAINER_PORT} lylescott/${APPNAME}

shell:
	docker run -i -t -p ${HOST_PORT}:${CONTAINER_PORT} lylescott/${APPNAME} /bin/bash

clean:
	docker rmi -f lylescott/${APPNAME}
	#echo $(docker images | grep '<none>' | awk '{print $3}' | xargs)
	#docker rmi -f $(docker images | grep '<none>' | awk '{print $3}' | xargs) 
