# TODO add checks whether python, ubuntu versions are ok and whether logged in as root.

echo "\n\n\n Please add your Ethereum node endpoint url... \n"

read -p " 👉 " url

while [[ "$url" == "" ]]; do

    echo "\n Please add your ethereum node endpoint...\n\n You could use centralized services providing endpoints, such as Alchemy or Infura. \n After signing up and 'creating' an Ethereum node, paste your http endpoint/url (f.e. https://eth-mainnet.alchemyapi.io/v2/YOUR_API_KEY) \n"

    read -p " 👉 " url

done

exit

echo " 🚀 🚀 🚀 🚀 LFG! 🚀 🚀 🚀 🚀"

echo "\n only a couple of minutes until you will be a StarkNet node runner too! \n"

sudo apt update && sudo apt upgrade -y

sudo apt install curl git python3-pip build-essential libssl-dev libffi-dev python3-dev libgmp-dev pkg-config -y

pip3 install fastecdsa

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

sudo apt install cargo -y

source $HOME/.cargo/env

rustup update stable

cd

git clone --branch main https://github.com/eqlabs/pathfinder.git

sudo apt install python3.8-venv

cd pathfinder/py

python3 -m venv .venv

source .venv/bin/activate

PIP_REQUIRE_VIRTUALENV=true pip install --upgrade pip

PIP_REQUIRE_VIRTUALENV=true pip install -r requirements-dev.txt

pytest

RUST_LOG=debug PATHFINDER_HTTP_RPC_ADDRESS=0.0.0.0:9545 cargo build --release --bin pathfinder

sudo tee /etc/systemd/system/starknetd.service >/dev/null <<EOF
[Unit]
Description=StarkNet
After=network.target
[Service]
Type=simple
User=root
WorkingDirectory=/root/pathfinder/py
ExecStart=/bin/bash -c 'source /root/pathfinder/py/.venv/bin/activate && /root/.cargo/bin/cargo run --release --bin pathfinder -- --ethereum.url https://eth-mainnet.alchemyapi.io/v2/mtugw_03z8s_PKMlKyomVhdOtmNLcbse'
Restart=always
RestartSec=10
Environment=RUST_BACKTRACE=1
Environment=PATHFINDER_HTTP_RPC_ADDRESS=0.0.0.0:9545
Environment=RUST_LOG=debug
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload

sudo systemctl enable starknetd

echo "\n \n How does everything look? \n \n If everything looks good, then welcome to the fam! /n /n ♥️️🔥 \n"

echo "\n Watch your baby👼 grow up! They grow up sooo fast! \n 👀     👀     👀     👀     👀     👀     👀     👀     👀      👀     👀     👀 \n"

read -p "Lookin' juicy! Would you like to see your first Stark Net logs? [y/N]" show_logs

sudo systemctl start starknetd

if [[ "$show_logs" == "y" ]]; then

    journalctl -u starknetd -f -o cat

fi

exit
