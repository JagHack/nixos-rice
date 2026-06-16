#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3Packages.fritzconnection -I nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos
"""Reconnects the Fritz!Box to obtain a new external IP address."""

from fritzconnection import FritzConnection
from fritzconnection.lib.fritzstatus import FritzStatus
import time
import os
from pathlib import Path


def load_dotenv():
    """Simple .env loader for scripts without python-dotenv dependency."""
    env_path = Path(__file__).parent / ".env"
    if env_path.exists():
        for line in env_path.read_text().splitlines():
            if line.strip() and not line.startswith("#") and "=" in line:
                key, value = line.strip().split("=", 1)
                os.environ[key] = value.strip("\"'")


def censor_ip(ip: str) -> str:
    """Censor the first two octets for IPv4: **.***.111.111"""
    parts = ip.split(".")
    if len(parts) == 4:
        return f"**.**.{parts[2]}.{parts[3]}"
    return "**.**.**.**"


load_dotenv()

FC = FritzConnection(
    address=os.getenv("FRITZ_ADDRESS", "192.168.178.1"),
    user=os.getenv("FRITZ_USER"),
    password=os.getenv("FRITZ_PASSWORD"),
)

print(f"Connected to {FC.modelname}")

# Get old IP
old_ip = FritzStatus(FC).external_ip
print(f"Current external IP: {censor_ip(old_ip)}")

print("Triggering reconnection...")
FC.reconnect()

print("Waiting for new IP...")
time.sleep(10)

new_ip = FritzStatus(FC).external_ip
print(f"New external IP: {censor_ip(new_ip)}")
