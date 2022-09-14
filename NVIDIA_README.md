# Instructions for NVIDIA GPUs
- Setup NVIDIA repository (run in terminal):
  ```
  distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
  ```
- Update repository and install the package:
  ```
  sudo apt update && sudo apt install -y nvidia-docker2
  ```
- Restart Docker Engine (ignore the warning if you see one):
  ```
  sudo systemctl restart docker
  ```