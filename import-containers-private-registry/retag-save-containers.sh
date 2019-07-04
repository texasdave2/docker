#! /bin/bash

## script for retagging and saving containers to a production private registry
## it is made to quickly and accurately retag containers in the existing deploy server registry
## and then save them as tar files for easy transport to your production private docker registry

## INSTRUCTIONS
## 1) you must first create a "container-list.txt" text file as a source to use for this script by
## running this command below on your control node to get a list of 'default' namespace containers:

## IMPORTANT COMMAND FOR GENERATING CONTAINER-LIST.TXT
## sudo kubectl get pods --namespace default -o go-template --template="{{range .items}}{{range .spec.containers}}{{.image}} {{end}}{{end}}" | awk -v FS="[ ]" '{for (i=1;i<=NF;i++) printf ""$i"\n"}' | awk '!NF || !seen[$0]++'

## 2) copy the "container-list.txt" file to your deploy server
## 3) inside your deploy server, create a working directory for the build containers, ex. containers-to-production
## 4) copy this script to your source deploy server, into the working directory you made
## 5) this script will iterate over each line in the "container-list.txt" file you created

## If a container image and version already exists in docker host, it will not pull a new one, it is safe to
## run this script over and over, it will not delete anything.


while read item
do
  ## insert your private registry location, this will be used for building the new tag
  REGISTRY_ID="MY-PRIVATE-REGISTRY-NAME-OR-IP-ADDRESS"

  DIGEST_ID="$(sudo docker pull $item | sed -n -e 's/^.*Digest: //p')"
  IMAGE_ID="$(sudo docker images --digests | grep $DIGEST_ID | awk '{print $4}')"
  REGISTRY_TAG="$(sudo docker images --digests | grep $DIGEST_ID | awk '{print $1}' | cut -d'/' -f2-)"
  VERSION_TAG="$(sudo docker images --digests | grep $DIGEST_ID | awk '{print $2}')"
  COMPONENT_NAME="$(sudo docker images --digests | grep $DIGEST_ID | awk '{print $1}' | sed 's:.*/::' | sed 's/\:.*//')"

  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "+++ RETAGGING $COMPONENT_NAME"
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  sudo docker tag $IMAGE_ID $REGISTRY_ID:5000/$REGISTRY_TAG:$VERSION_TAG

  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "+++ SAVING AS TAR FILE $COMPONENT_NAME"
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  sudo docker save -o $COMPONENT_NAME.tar $REGISTRY_ID:5000/$REGISTRY_TAG:$VERSION_TAG

  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "Saved as $COMPONENT_NAME.tar with new docker registry tag $REGISTRY_ID:5000/$REGISTRY_TAG:$VERSION_TAG"
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"

  wait
done < container-list.txt
