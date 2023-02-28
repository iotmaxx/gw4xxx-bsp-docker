MAJOR=1
MINOR=0
VENDOR=iotmaxx
IMAGE=build_agent

TIMESTAMP:=$(shell date +%s)

.PHONY: image
image:
	docker build -t $(IMAGE):$(MAJOR).$(MINOR)-devel .

.PHONY: push
push:
	docker tag $(IMAGE):$(MAJOR).$(MINOR)-devel $(VENDOR)/$(IMAGE):$(MAJOR).$(MINOR)-$(TIMESTAMP)
	docker tag $(IMAGE):$(MAJOR).$(MINOR)-devel $(VENDOR)/$(IMAGE):$(MAJOR).$(MINOR)
	docker tag $(IMAGE):$(MAJOR).$(MINOR)-devel $(VENDOR)/$(IMAGE):latest
	docker push $(VENDOR)/$(IMAGE):$(MAJOR).$(MINOR)-$(TIMESTAMP)
	docker push $(VENDOR)/$(IMAGE):$(MAJOR).$(MINOR) 
	docker push $(VENDOR)/$(IMAGE):latest

.PHONY: date
date:
	echo $(TIMESTAMP)


