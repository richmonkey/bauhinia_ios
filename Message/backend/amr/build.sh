#!/bin/bash
VERSION="0.1.2"

CURRENTPATH=$(pwd)
mkdir -p ${CURRENTPATH}/src

tar zxf opencore-amr-${VERSION}.tar.gz -C "${CURRENTPATH}/src"  
cd "$CURRENTPATH/src/opencore-amr-${VERSION}"  

DEVELOPER=`xcode-select -print-path`
DEST=${CURRENTPATH}/opencore_amr_ios
ARCHS="i386 x86_64 armv7 armv7s arm64"

LIBS="libopencore-amrnb.a libopencore-amrwb.a"  

for arch in $ARCHS;
do
    mkdir -p $DEST/$arch
done


for arch in $ARCHS; 
do  
    IOSMV="-miphoneos-version-min=6.0"
    case $arch in
    arm*)  
        echo "Building opencore-amr for iPhoneOS $arch ****************"
        if [ $arch == "arm64" ]
        then
            IOSMV="-miphoneos-version-min=7.0"
        fi
        PATH=`xcodebuild -version -sdk iphoneos PlatformPath`"/Developer/usr/bin:$PATH" \
        SDK=`xcodebuild -version -sdk iphoneos Path` \
        CXX="xcrun --sdk iphoneos clang++ -arch $arch $IOSMV --sysroot=$SDK -isystem $SDK/usr/include -fembed-bitcode" \
        LDFLAGS="-Wl,-syslibroot,$SDK" \
        ./configure \
        --host=arm-apple-darwin \
        --prefix=$DEST/$arch \
        --disable-shared
        ;;
    *)
        echo "Building opencore-amr for iPhoneSimulator $arch *****************"
        PATH=`xcodebuild -version -sdk iphonesimulator PlatformPath`"/Developer/usr/bin:$PATH" \
        CXX="xcrun --sdk iphonesimulator clang++ -arch $arch $IOSMV -fembed-bitcode" \
        ./configure \
        --prefix=$DEST/$arch \
        --disable-shared
        ;;
    esac
    make
    make install
    make clean
done

echo "Merge into universal binary."
for i in $LIBS;
do
    input=""
    for arch in $ARCHS; do
        input="$input $DEST/$arch/lib/$i"
    done
    lipo -create $input -output $DEST/$i
done 

echo "Cleaning up..."  
rm -rf ${CURRENTPATH}/src  
echo "Done." 
