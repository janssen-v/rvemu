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