# Docker environment for Robotics
A Docker image and container setup for having an environment with ROS and other robotics packages already setup, designed especially for the master course `Optimisation Based Robot Control` at the University of Trento.

## How to use
### Prerequisites
- A Unix machine (since the image is based on Ubuntu 20.04), so this does not work on Windows.
- Bash available on your machine.
- Docker Engine. Refer to the official documentation available online.
  - **Important:** make sure that you can run docker commands without `sudo` (for Linux, follow `Manage Docker as non-root user` in [this guide](https://docs.docker.com/engine/install/linux-postinstall/)).
  
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
  - `ROBOLAB_PATH` is the path to the folder where you want to clone this repository.
  - `ROBOLAB_HOME_PATH` is the path to the folder which will be shared with the Docker container. Every file that you put there will be available inside your home folder in the container.
  - To find out your user name, type the command `whoami` in a terminal.
  - **NB:** You can change those paths to your liking. The proposed ones are just an example.
  
- Exit and reopen the terminal in order to load those changes.
  
- Move to the parent folder of the path that you have defined in `ROBOLAB_PATH`. For example:
  ```
  cd /home/<your-user>
  ```
  Clone this repository:
  ```
  git clone https://github.com/nicola-farina/robolab.git
  ```
  This will create the folder `robolab` with all required files.

- If you used the proposed `$ROBOLAB_HOME_PATH`, make sure to create the required folder:
  ```
  cd robolab
  mkdir home
  ```

- Now you are all set. In the first step, you have set some aliases in the `.bashrc` file to make running the container easier. In a terminal, you can run one of those commands:
  - `robolab`: generally use this. It setups and starts the container.
  - `robolab-f`: the same as the previous one, but forces the container to stop and creates a new one if one is already running.
  - `robolab-root`: attaches to the already running container as `root` user.
  - **NB:** the first time you run `robolab`, the Docker image will be downloaded. It is ~3GB, so it may take a while.
  
- Once inside the container, you will be in your home, where you will find a folder `src`. This is where you will put the folder `orc` for the *Optimisation Based Robot Control* course. If you want to change it, open the `.bashrc` file inside the container (located in your home) with `nano` or `spyder3` and change the following line accordingly: 
  ```
  export PYTHONPATH=$PYTHONPATH:<path-to-folder-containing-orc-folder>
  ```

### Important things
- The `$ROBOLAB_HOME_PATH` folder is mapped to your home inside the container. This means that you can every file located there is shared between the container and your machine. You can put, access and modify files there from your machine and those actions will be reflected inside the container.
  - For example, you can download the Python file provided by the teacher on your normal machine, move them inside that folder, and they will be available inside the container. 

### Troubleshooting
In most cases, if you are experiencing problems in the container, the best thing to try is to delete the `.bashrc` file **inside the container**, exit from the container, and run `robolab-f`.

### Known limitations
The container *probably* does not use NVIDIA GPU drivers, capabilities and functionalities. I do not have an NVIDIA GPU, so I cannot test this. Regardless, everything should work without them, especially for simple visual simulations.
