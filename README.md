# RISC-V GDB Environment

## Docker

In this tutorial, we will be using a prebuilt Docker image to ensure a consistent and reproducible environment. 

Before starting, make sure you have installed the Docker container engine and any other necessary packages. 

## Environment Setup

### Option 1. Pull Docker image from container repository

The Docker image has been built for both x86_64 and ARM64, so the same instructions here will work for all systems (Apple/AMD/Intel).

```bash
#1. Pull Docker image from ghcr.io
docker pull ghcr.io/janssen-v/rvemu

# 2. Run container
docker container run --name rvemu -p 2222:2222 -d ghcr.io/janssen-v/rvemu

# 3. SSH into QEMU
ssh student@localhost -p 2222

# When prompted for password, enter: ilovecs
# You are now connected to your RISC-V environment
```

### Option 2. Build image from Dockerfile

If you prefer to build your own image or have trouble accessing the GitHub container repository from outside campus, you can use the dockerfile below to build the same image from source.

```dockerfile
FROM alpine:3.19

EXPOSE 2222

# Install all needed packages
RUN apk add wget qemu-system-riscv64 unzip

# Get RISC-V Debian image
RUN wget https://cdn.cloud.vjssn.dev/debian-riscv64-virt.zip && \ 
	 unzip debian-riscv64-virt.zip && rm debian-riscv64-virt.zip

# Get RISC-V Bootloader
RUN wget https://cdn.cloud.vjssn.dev/qemu-riscv64_smode-uboot.elf

# Start QEMU Emulator
CMD qemu-system-riscv64 -smp 2 -m 2G -cpu rv64 -nographic -machine virt -kernel qemu-riscv64_smode-uboot.elf -device virtio-blk-device,drive=hd -drive file=dqib_riscv64-virt/image.qcow2,if=none,id=hd -device virtio-net-device,netdev=net -netdev user,id=net,hostfwd=tcp::2222-:22 -object rng-random,filename=/dev/urandom,id=rng -device virtio-rng-device,rng=rng -append "root=LABEL=rootfs console=ttyS0"

```

Copy the above into a dockerfile, and build it using the command below

`docker build -t rvemu .`

After the image is built, you can follow the steps from option 1 starting from **#2. Run container**.

### Starting and stopping your container

After the initial setup, you can start and stop with its assigned name

- **Start:** `docker container start rvemu`
- **Stop:** `docker container stop rvemu`

## Optional Setup

#### SSH key authentication

```bash
# Setup SSH key authentication
ssh-keygen
ssh-copy-id -p 2222 -f -i ~/.ssh/id_rsa.pub student@localhost
# When prompted for password, enter: ilovecs
```

SSH key authentication is a quality of life feature that you can use to securely login to a remote server password-free. In this case, our *"remote server"* is our not so remote QEMU machine inside the container.

#### SSH config

Setting up a SSH config lets you login to a host without typing in the host IP address, port, and username. Using the config below, you can login by using `ssh debian-rv64`

```bash
# Setup SSH config
echo "
Host debian-rv64
   HostName 127.0.0.1
   User student
   Port 2222
" >> ~/.ssh/config
```

You can copy paste the above into your bash shell to add the SSH config.

## Advanced

If you prefer to setup an environment with your own emulator e.g. UTM/QEMU, or perhaps have access to a RISC-V machine, you are welcome to do so. The OS disk image we use in our container image can be downloaded in the link below.

https://cdn.cloud.vjssn.dev/debian-riscv64-virt.zip
