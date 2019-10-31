# Super SIMPLE docker-compose with mirroring (version 2019.3 and later)
This is a very simple docker-compose with a simple class that creates a mirror. 
It will create 2 folders (mirrorA and mirrorB) with the Iris installation files and mirror database MIRRORDB. Also creates a namespace **MIRRORNS**.


## Requirements
- docker & docker-compose
- IRIS image (or docker repository with IRIS) 
- iris.key

## How to 

Put the iris.key license in the same directory.

Regarding the Iris docker image, you can either download from Intersystems or use a docker hub repository:

- ### Download an image from Intersystems and load the image
    Download the version you need from Intersystems and use **docker load** command to load the image. You will need to have access to wrc.intersystems.com, then go to distributions and find the version you need. I recommend to download 2019.3 and later.
    When I was writing this the version "iris-2019.3.0.302.0-docker.tar.gz" was under the preview tag (where you can also get a preview License key)

    ```
    docker load -i iris-2019.3.0.302.0-docker.tar.gz

    docker-compose up -d
    ```
- ### Or use a docker hub to download the image
    If you have a docker hub with images, just change the image inside the docker-compose.yml.  For example: 

     *image: docker.iscinternal.com/intersystems/iris:2019.3.0-latest*

    you will need to be logged: 
    ``` 
    docker login docker.iscinternal.com
    ```

## Useful commands 

- Start a iris session in mirrorA (initially is primary)
```shell
docker exec -it mirrorA iris session iris
```
- Start a iris shell in mirrorA
```shell
docker exec -it mirrorA bash
```

- Connect to SMP mirror A
 http://127.0.0.1:9092/csp/sys/UtilHome.csp

- Connect to SMP mirror B
http://127.0.0.1:9093/csp/sys/UtilHome.csp

**The first time you login you will need to use default credentials: 
  - Username: SuperUser
  - Password: SYS

## To clean and try a different version

Stop the containers: 

```shell
docker-compose down
```
And remove the irisA and irisB folders

```shell
rm -R iris?
docker-compose up -d
```

## Notes
Starting with 2019.3 IRIS containers use "irisowner" instead of "root", so the installation is a Nonroot installation. 
See https://irisdocs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GCI_unix#GCI_unix_install_nonroot

This allow the scripts to be simpler and you don't need to pass credentials.
The folder "irismirror older versions" contains the same simple mirror working for older versions. See readme inside. 
