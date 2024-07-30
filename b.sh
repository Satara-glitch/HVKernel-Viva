#!/bin/bash

function compile() 
{

source ~/.bashrc && source ~/.profile
export ARCH=arm64
export KBUILD_BUILD_HOST="gitpodkesayanganku"
export KBUILD_BUILD_USER="fjrXTR"
mkdir clang-18 ; wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/8f439623c553f8297533ff81aae3fd702416e364/clang-r522817.tar.gz 


rm -rf AnyKernel
make O=out ARCH=arm64 viva_defconfig

PATH="${PWD}/clang/bin:${PATH}:${PWD}/los-4.9-32/bin:${PATH}:${PWD}/los-4.9-64/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC="clang" \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${PWD}/los-4.9-64/bin/aarch64-linux-gnu-" \
                      CROSS_COMPILE_ARM32="${PWD}/los-4.9-32/bin/arm-linux-gnueabihf-" \
                      LD=ld.lld \
                      AS=llvm-as \
		      AR=llvm-ar \
                      NM=llvm-nm \
		      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      CONFIG_SECTION_MISMATCH_WARN_ONLY=y
}

function zupload()
{
git clone --depth=1 https://github.com/fjrXTR/AnyKernel3.git -b mt6781 AnyKernel
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
cd AnyKernel
zip -r9 fjrXTR-kernel-v1.2-viva.zip *
curl -T fjrXTR-kernel-v1.2-viva.zip temp.sh
}

compile
zupload
