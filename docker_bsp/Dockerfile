FROM iotmaxx/bsp_agent:0.1.0

USER ptx

RUN mkdir -p /home/ptx/bsp && \
	cd /home/ptx/bsp && \
	git clone https://github.com/iotmaxx/gw41XX-firmware.git && \
	cd gw41XX-firmware && \
	git checkout -b release && \
	ptxdist select configs/ptxconfig && \
	ptxdist platform configs/platform-iotmaxx-gateway/platformconfig 

WORKDIR /home/ptx/bsp/gw41XX-firmware
 

