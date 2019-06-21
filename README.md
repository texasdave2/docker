# docker-private-registry-scripts
scripts to retag and save containers as well as load and push into private docker registry

It is highly likely that your production docker registry is private without direct connections to internet based repos therefore you need to transfer containers manually.  The pain point here is they need to be retagged with your new private registry meta data and then saved prior to moving them.  After saving them, you gotta compress them because they're typically large...  And then you need to copy them over to your private deploy host, then load and push them into the private registry...!  

These are the scripts I wrote in our production deployments to automate these tasks.  
1)  this scripts will save whatever containers appear in the list you give it.  The contents of my list file are made up of all kubernetes containers running in the default namespace.  You can edit this as you like.

2)  On the source host -- The retag-save script does what it says, retag with your new private docker registry address and then saves as a tarball.

3)  Transfer containers from your source host to your target deploy host with standard scp / ftp whatever works for you.

4)  Use the load-push script to load the container images one by one into the docker repo and then push them into the registry.

