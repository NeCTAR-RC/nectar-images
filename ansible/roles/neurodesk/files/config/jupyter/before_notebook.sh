# This script runs in local Jupyterlab only (e.g. Docker, Neurodeskapp)
# This script does NOT run on stock JupterHub/BinderHub instances (e.g. kubernetes)
# For global startup script, see ./config/jupyter/jupterlab_startup.sh

# Overrides Dockerfile changes to NB_USER
/usr/bin/printf '%s\n%s\n' 'password' 'password' | passwd ${NB_USER}
usermod --shell /bin/bash ${NB_USER}

if [ ! -d "/cvmfs/neurodesk.ardc.edu.au/neurodesk-modules/" ]; then
    # the cvmfs directory is not yet mounted
    if [ -z "$CVMFS_DISABLE" ]; then
        # CVMFS is not disabled

        # try to list the directory in case it's autofs mounted outside
        ls /cvmfs/neurodesk.ardc.edu.au/neurodesk-modules/ 2>/dev/null && echo "CVMFS is ready" || echo "CVMFS directory not there. Trying internal fuse mount next."

        if [ ! -d "/cvmfs/neurodesk.ardc.edu.au/neurodesk-modules/" ]; then
            # it is not available outside, so try mounting with fuse inside container

            echo "probing if the latency of direct connection or the latency of a CDN is better"
            DIRECT=cvmfs-geoproximity.neurodesk.org
            DIRECT_url="http://${DIRECT}/cvmfs/neurodesk.ardc.edu.au/.cvmfspublished" 
            CDN=cvmfs.neurodesk.org
            CDN_url="http://${CDN}/cvmfs/neurodesk.ardc.edu.au/.cvmfspublished"

            echo testing $CDN_url
            echo "Resolving DNS name"
            resolved_dns=$(dig +short $CDN)
            echo "[DEBUG]: Resolved DNS for $CDN: $resolved_dns"
            CDN_url_latency=$(curl -s -w %{time_total}\\n -o /dev/null "$CDN_url")
            echo $CDN_url_latency
            
            echo testing $DIRECT_url
            echo "Resolving DNS name"
            resolved_dns=$(dig +short $DIRECT)
            echo "[DEBUG]: Resolved DNS for $DIRECT: $resolved_dns"
            DIRECT_url_latency=$(curl -s -w %{time_total}\\n -o /dev/null "$DIRECT_url")
            echo $DIRECT_url_latency

            if (( $(echo "$DIRECT_url_latency < $CDN_url_latency" |bc -l) )); then
                echo "Direct connection is faster"
                cp /etc/cvmfs/config.d/neurodesk.ardc.edu.au.conf.direct /etc/cvmfs/config.d/neurodesk.ardc.edu.au.conf
            else
                echo "CDN is faster"
                cp /etc/cvmfs/config.d/neurodesk.ardc.edu.au.conf.cdn /etc/cvmfs/config.d/neurodesk.ardc.edu.au.conf
            fi

            echo "\
            ==================================================================
            Mounting CVMFS"
            if ( service autofs status > /dev/null ); then
                 echo "autofs is running - not attempting to mount manually:"
                 ls /cvmfs/neurodesk.ardc.edu.au/neurodesk-modules/ 2>/dev/null && echo "CVMFS is ready after autofs mount" || echo "AutoFS not working!"
            else
                echo "autofs is NOT running - attempting to mount manually:"
                mkdir -p /cvmfs/neurodesk.ardc.edu.au
                mount -t cvmfs neurodesk.ardc.edu.au /cvmfs/neurodesk.ardc.edu.au

                ls /cvmfs/neurodesk.ardc.edu.au/neurodesk-modules/ 2>/dev/null && echo "CVMFS is ready after manual mount" || echo "Manual CVMFS mount not successful"

                echo "\
                ==================================================================
                CVMFS servers:"
                cvmfs_talk -i neurodesk.ardc.edu.au host info
            fi
        fi
    fi
fi