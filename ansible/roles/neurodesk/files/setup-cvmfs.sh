#!/bin/bash -x

# Mounting CVMFS
mkdir /cvmfs/neurodesk.ardc.edu.au
mount -t cvmfs neurodesk.ardc.edu.au /cvmfs/neurodesk.ardc.edu.au

# Testing which CVMFS server is fastest
cvmfs_talk -i neurodesk.ardc.edu.au host probe
cvmfs_talk -i neurodesk.ardc.edu.au host info
