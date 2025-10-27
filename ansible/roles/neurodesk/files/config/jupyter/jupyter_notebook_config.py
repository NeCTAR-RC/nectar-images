import os
import subprocess

c.ServerProxy.servers = {
  'neurodesktop': {
    'command': ['/opt/neurodesktop/guacamole.sh'],
    'port': 8080,
    'timeout': 60,
      'request_headers_override': {
          'Authorization': 'Basic am92eWFuOnBhc3N3b3Jk',
      },
      'launcher_entry': {
        'path_info' : 'neurodesktop',
        'title': 'Neurodesktop',
        'icon_path': '/opt/neurodesk_brain_logo.svg'
      }
    }
}
# c.ServerApp.root_dir = '/' # this causes an error when clicking on the little house icon when being located in the home directory
c.ServerApp.preferred_dir = os.getcwd()
c.FileContentsManager.allow_hidden = True

before_notebook = subprocess.call("/opt/neurodesktop/jupyterlab_startup.sh")
