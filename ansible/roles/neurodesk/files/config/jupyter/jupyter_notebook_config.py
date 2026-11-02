import os

# c.ServerApp.root_dir = '/' # this causes an error when clicking on the little house icon when being located in the home directory
c.ServerApp.preferred_dir = os.getcwd()
c.FileContentsManager.allow_hidden = True
