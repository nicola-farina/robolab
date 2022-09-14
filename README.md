# Docker environment for Robotics
A Docker image and container setup for having an environment with ROS and other robotics packages already setup, designed specifically for the master course Optimisation Based Robot Control at the University of Trento.

## Known limitations
- This does not work with WSL on Windows.
- This *probably* does not work with NVIDIA GPUs (I cannot test it).

## How to use
### Prerequisites
- A Linux machine.
- Docker Engine. Refer to the official documentation available online.
  - **Important:** make sure that you can run docker commands without `sudo` (for Linux, follow *Manage Docker as non-root user* in [this guide](https://docs.docker.com/engine/install/linux-postinstall/)).
  
### Setup
- Open a terminal and open your `.bashrc` file with the following command:
  ```
  gedit ~/.bashrc
  ```
  Now append the following lines at the end of the file, **substituting `your-user` with your user name**:
  ```
  ROBOLAB_PATH="/home/<your-user>/robolab"
  ROBOLAB_HOME_PATH="/home/<your-user>/robolab/home"
  alias robolab="$ROBOLAB_PATH/setup.sh $ROBOLAB_HOME_PATH"
  alias robolab-f="$ROBOLAB_PATH/setup.sh -f $ROBOLAB_HOME_PATH"
  alias robolab-root="docker exec -it --user='root' robolab bash"
  ```
  - To find out your user name, type the command `whoami` in a terminal.

- Exit and reopen the terminal in order to load those changes.
  
- Clone this repository in your home:
  ```
  cd ~
  git clone https://github.com/nicola-farina/robolab.git
  ```
  This will create the folder `robolab` with all required files.

- Move into the `robolab` folder and create a `home` folder:
  ```
  cd ~/robolab
  mkdir home
  ```
- Done!

### Usage
- To run the Docker container, open a terminal and input the following command:
  ```
  robolab
  ```
  **NB:** the first time you run `robolab`, the Docker image will be downloaded. It is ~3GB, so it may take a while. The progress is not shown, so don't worry if it looks like nothing happens. Eventually the download will finish.
  
- Once inside the container, you will find a folder `src`. This is where you will put/create the `orc` folder.

- If you want to move files from your machine to your container, you can move them to the folder `/home/<your-user>/robolab/home`. This folder on your machine is mapped to the home folder in your container (for example, you will find the `src` folder).

### Troubleshooting
In most cases, if you are experiencing problems in the container, the best thing to try is the following:
- Enter your container by running the command `robolab`.
- Execute this command:
  ```
  rm .bashrc
  ```
- Exit the container.
- Re-run the container by running the command `robolab-f`.
