# gw4xxx-bsp-docker
Creates Docker image with build system for IoTmaxx GW4xxx series board support package 

Please use the following commands to build and run the docker container:
```
docker build -t iotmaxx_bsp
docker run -it --security-opt seccomp=unconfined iotmaxx_bsp
```

For instructions on how to install the actual board support package please contact 
[IoTmaxx support](mailto:support@iotmaxx.de?subject=[BSP]%20Request%20for%20installation%20instructions)

