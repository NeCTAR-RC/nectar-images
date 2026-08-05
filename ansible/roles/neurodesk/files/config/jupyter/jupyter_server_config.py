# Jupyter Server settings translated from the upstream Dockerfile (upstream
# appends these to the jupyter/base-notebook copy of this file).
c = get_config()  # noqa

# Allow deleting non-empty directories
c.FileContentsManager.always_delete_dir = True

# Detect dead WebSocket clients quickly (tab closed / network gone)
c.ServerApp.websocket_ping_interval = 30
c.ServerApp.websocket_ping_timeout = 60
