import logging
import socket
import subprocess
import threading
import time

import requests

from helpers import resolve_path


def get_host_ip():
    """Get the host machine's IP address."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Use Google's public DNS to determine the external IP
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"
    finally:
        s.close()
    return ip

# Function to start TensorBoard
def start_tensorboard():
    logdir = resolve_path("logs")
    logging.debug(f"starting tensorboard at {logdir}")

    def run_tensorboard():
        subprocess.run(
            ["tensorboard", "--logdir", logdir, "--host", "0.0.0.0", "--port", "6006"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
    threading.Thread(target=run_tensorboard, daemon=True).start()
    ip = get_host_ip()
    return ip, 6006

def wait_for_tensorboard(hostname, port, retries=10, delay=2):
    """Wait until the TensorBoard server is accessible."""
    url = f"http://{hostname}:{port}"
    for attempt in range(retries):
        try:
            response = requests.get(url, timeout=2)
            if response.status_code == 200:
                logging.debug("TensorBoard is ready.")
                return url
        except requests.exceptions.RequestException:
            logging.debug(f"Waiting for TensorBoard... (Attempt {attempt + 1}/{retries})")
        time.sleep(delay)
    logging.warning("TensorBoard did not start within the expected time.")
    return url  # Return the URL even if it is not ready for the iframe to try


# Function to display TensorBoard iframe
def tensorboard_ui(logdir):
    tensorboard_message = start_tensorboard(logdir)
    ip = get_host_ip()
    iframe_html = f"<iframe src='http://{ip}:6006' width='100%' height='600px'></iframe>"
    return tensorboard_message + "<br>" + iframe_html

# Function to generate the iframe dynamically
def get_tensorboard_iframe(hostname, port):
    tensorboard_url = f"http://{hostname}:{port}"
    iframe_html = f"<iframe src='{tensorboard_url}' width='100%' height='600px'></iframe>"
    return iframe_html
