# Docker Cleanup script

This is a simple shell script for the Docker users that struggle with unused container volumes. Script simply looks up at container status from ``docker ps -a`` command, filters ``--filter status=running``, compares their volumes with all container volumes in ``/var/lib/docker/volumes`` directory and removes directories of not running containers.

*Don't use this script if you don't want volume data to be removed of 'not running at the moment' containers.* 
