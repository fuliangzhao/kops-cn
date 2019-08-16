# customize the values below
TARGET_REGION ?= cn-northwest-1
AWS_PROFILE ?= default
KOPS_STATE_STORE ?= s3://
VPCID ?= vpc-0893cf720aca56c60
MASTER_COUNT ?= 3
MASTER_SIZE ?= t2.small
NODE_SIZE ?= t2.small
NODE_COUNT ?= 2
SSH_PUBLIC_KEY ?= ~/.ssh/kops
KUBERNETES_VERSION ?= v1.12.9
KOPS_VERSION ?= 1.12.3

# do not modify following values
AWS_DEFAULT_REGION ?= $(TARGET_REGION)
AWS_REGION ?= $(AWS_DEFAULT_REGION)
ifeq ($(TARGET_REGION) ,cn-north-1)
	CLUSTER_NAME ?= cluster.bjs.k8s.local
	# copy from kope.io/k8s-1.12-debian-stretch-amd64-hvm-ebs-2019-05-13
	# see https://github.com/nwcdlabs/kops-cn/issues/96
	AMI ?= ami-02dd4d384eb0e0b3a
	ZONES ?= cn-north-1a,cn-north-1b
endif

ifeq ($(TARGET_REGION) ,cn-northwest-1)
	CLUSTER_NAME ?= cluster1.zhy.k8s.local
	# copy from kope.io/k8s-1.12-debian-stretch-amd64-hvm-ebs-2019-05-13
	# see https://github.com/nwcdlabs/kops-cn/issues/96
	AMI ?= ami-068b32c3754324d44
	ZONES ?= cn-northwest-1a,cn-northwest-1b,cn-northwest-1c
endif

ifdef CUSTOM_CLUSTER_NAME
	CLUSTER_NAME = $(CUSTOM_CLUSTER_NAME)
endif

KUBERNETES_VERSION_URI ?= "https://s3.cn-north-1.amazonaws.com.cn/kubernetes-release/release/$(KUBERNETES_VERSION)"


.PHONY: create-cluster
create-cluster:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
	AWS_PROFILE=$(AWS_PROFILE) \
	AWS_REGION=$(AWS_REGION) \
	AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	kops create cluster \
     --cloud=aws \
     --name=$(CLUSTER_NAME) \
     --image=$(AMI) \
     --zones=$(ZONES) \
     --master-count=$(MASTER_COUNT) \
     --master-size=$(MASTER_SIZE) \
     --node-count=$(NODE_COUNT) \
     --node-size=$(NODE_SIZE)  \
     --vpc=$(VPCID) \
     --kubernetes-version=$(KUBERNETES_VERSION_URI) \
     --networking=amazon-vpc-routed-eni \
     --subnets=subnet-010116c49581f92f8,subnet-092ff0b5636001a24,subnet-04e50a37bf5c9037d \
     --ssh-public-key=$(SSH_PUBLIC_KEY)
          
.PHONY: edit-ig-nodes
edit-ig-nodes:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
	AWS_PROFILE=$(AWS_PROFILE) \
	AWS_REGION=$(AWS_REGION) \
	AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	kops edit ig --name=$(CLUSTER_NAME) nodes

.PHONY: edit-cluster
edit-cluster:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
	AWS_PROFILE=$(AWS_PROFILE) \
	AWS_REGION=$(AWS_REGION) \
	AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	kops edit cluster $(CLUSTER_NAME)
	
.PHONY: update-cluster
update-cluster:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
	AWS_PROFILE=$(AWS_PROFILE) \
	AWS_REGION=$(AWS_REGION) \
	AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	kops update cluster $(CLUSTER_NAME) --yes

.PHONY: validate-cluster
 validate-cluster:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
	AWS_PROFILE=$(AWS_PROFILE) \
	AWS_REGION=$(AWS_REGION) \
	AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	kops validate cluster
	
.PHONY: delete-cluster
 delete-cluster:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
	AWS_PROFILE=$(AWS_PROFILE) \
	AWS_REGION=$(AWS_REGION) \
	AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
	kops delete cluster --name $(CLUSTER_NAME) --yes
	
.PHONY: rolling-update-cluster
rolling-update-cluster:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
	AWS_PROFILE=$(AWS_PROFILE) \
        AWS_REGION=$(AWS_REGION) \
        AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
        kops rolling-update cluster --name $(CLUSTER_NAME) --yes --cloudonly


.PHONY: get-cluster
get-cluster:
	@KOPS_STATE_STORE=$(KOPS_STATE_STORE) \
        AWS_PROFILE=$(AWS_PROFILE) \
        AWS_REGION=$(AWS_REGION) \
        AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION) \
        kops get cluster --name $(CLUSTER_NAME)
