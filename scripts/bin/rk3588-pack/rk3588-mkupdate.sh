#!/bin/bash
echo "start to make update.img..."
if [ ! -f "Image/parameter" -a ! -f "Image/parameter.txt" ]; then
	echo "Error:No found parameter!"
	exit 1
fi
if [ ! -f "package-file" ]; then
	echo "Error:No found package-file!"
	exit 1
fi
./afptool -pack ./ Image/update.img || pause
./rkImageMaker -RK3588 Image/MiniLoaderAll.bin Image/update.img update.img -os_type:androidos || pause
echo "Making ./Image/update.img OK."
exit $?
