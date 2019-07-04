#! /bin/bash

## this script should be run on the production deployment server after you have copied and uncompressed the container tgz file
## this script loads each container.tgz file in the folder
## then gets the output to form the push command

#while read file
for file in ./*.tar
do
  ## insert your private registry target IP or name
  REGISTRY_ID="PRIVATE-REGISTRY-NAME-OR-IP"

# upon loading scrape the sha id
# can't pull images until you have ID... have to scrape after loading to get loaded image output


  LOADED_OUTPUT="$(sudo docker load -i $file | sed -n -e 's/^.*Loaded image: //p')"
  LOADED_REGISTRY_TAG="$(echo $LOADED_OUTPUT | sed 's/:[^:]*$//')"
  LOADED_VERSION="$(echo $LOADED_OUTPUT | sed -e 's/.*://')"
  IMAGE_ID="$(sudo docker images | grep -m1 $LOADED_REGISTRY_TAG.*$LOADED_VERSION | awk '{print $3}')"
  REGISTRY_TAG="$(sudo docker images --digests | grep -m1 $IMAGE_ID | awk '{print $1}' | cut -d'/' -f2-)"
  COMPONENT_NAME="$(sudo docker images --digests | grep -m1 $IMAGE_ID | awk '{print $1}' | sed 's:.*/::' | sed 's/\:.*//')"

  echo
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "LOADING $COMPONENT_NAME found image ID $IMAGE_ID"
  echo "command: sudo docker load -i $file"
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo
  sudo docker load -i $file
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "PUSHING $COMPONENT_NAME"
  echo "command: sudo docker push $LOADED_OUTPUT"
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo
  sudo docker push $LOADED_OUTPUT
  wait

done
