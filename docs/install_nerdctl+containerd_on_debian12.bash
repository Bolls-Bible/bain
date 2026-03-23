sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl tar ca-certificates

# Check the latest version on GitHub, currently 1.7.x or 2.x
wget https://github.com/containerd/containerd/releases/download/v2.2.1/containerd-2.2.1-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local  containerd-2.2.1-linux-amd64.tar.gz


sudo mkdir -p /usr/local/lib/systemd/system/
sudo wget -O /usr/local/lib/systemd/system/containerd.service https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

wget https://github.com/containernetworking/plugins/releases/download/v1.9.0/cni-plugins-linux-amd64-v1.9.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.9.0.tgz


wget https://github.com/containerd/nerdctl/releases/download/v2.2.1/nerdctl-full-2.2.1-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local nerdctl-full-2.2.1-linux-amd64.tar.gz

sudo systemctl enable --now buildkit