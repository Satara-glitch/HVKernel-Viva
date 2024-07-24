#!/bin/sh

DEFCONFIG="/viva_defconfig"
CLANGDIR="/workspace/clang"

#
rm -rf compile.log

#
mkdir -p out
mkdir out/HvKernel
mkdir out/HvKernel/viva_build



#
export KBUILD_BUILD_USER=Hkadaaa
export KBUILD_BUILD_HOST=Builder
export PATH="$CLANGDIR/bin:$PATH"
git clone --depth=1 https://github.com/sarthakroy2002/prebuilts_gcc_linux-x86_aarch64_aarch64-linaro-7 los-4.9-64
git clone --depth=1 https://github.com/sarthakroy2002/linaro_arm-linux-gnueabihf-7.5 los-4.9-32

#
make O=out ARCH=arm64 $DEFCONFIG

#
MAKE="./makeparallel"

#
START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

hvk () {
PATH="${PWD}/clang/bin:${PATH}:${PWD}/los-4.9-32/bin:${PATH}:${PWD}/los-4.9-64/bin:${PATH}" \
make -j$(nproc --all) O=out LLVM=1 \
ARCH=arm64 \
CC="ccache clang" \
CLANG_TRIPLE=aarch64-linux-gnu- \
CROSS_COMPILE="${PWD}/los-4.9-64/bin/aarch64-linux-gnu-" \
CROSS_COMPILE_ARM32="${PWD}/los-4.9-32/bin/arm-linux-gnueabihf-" \
LD=ld.lld \
AR=llvm-ar \
AS=llvm-as \
NM=llvm-nm \
OBJCOPY=llvm-objcopy \
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
}

viva_build() {
cp HvKernel/viva_build/* arch/arm64/boot/dts/mediatek/
cp HvKernel/viva_build/mt6781.dts arch/arm64/boot/dts/mediatek/
hvk 2>&1 | tee -a compile.log
    if [ $? -ne 0 ]
        then
                echo "Build failed"
                    else
                            echo "Build succesful"
                                    cp out/arch/arm64/boot/Image.gz-dtb out/HvKernel/viva_build/Image.gz-dtb
                                        fi
                                        }


                                        viva_build

                                        END=$(date +"%s")
                                        DIFF=$(($END - $START))
                                        echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"