FROM scratch
ADD rootfs.tar.xz /
CMD ["/bin/bash"]

RUN groupadd --gid 1000 user && \
    useradd --shell /bin/bash --home-dir /home/user --uid 1000 --gid 1000 --create-home user

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget build-essential m4 && \
    apt-get install -y --no-install-recommends libglib2.0-dev libgtk2.0-dev libgl1-mesa-dev libxcb-glx0-dev libx11-xcb-dev && \
    apt-get clean

WORKDIR /usr/src

RUN wget --no-check-certificate https://www.openssl.org/source/openssl-1.1.1i.tar.gz && \
    tar -xvpf openssl-1.1.1i.tar.gz && \
    cd openssl-1.1.1i && \
    setarch i386 ./Configure linux-generic32 -m32 --prefix=/usr --openssldir=/etc/ssl zlib no-shared && \
    make depend && \
    make -j4 && \
    make install DESTDIR=/tmp/wget && \
    cd .. && \
    rm -rf openssl-1.1.1i.tar.gz openssl-1.1.1i && \
    wget ftp://ftp.gnu.org/gnu/wget/wget-1.20.3.tar.gz && \
    tar -xvpf wget-1.20.3.tar.gz && \
    cd wget-1.20.3 && \
    LIBS='-L/tmp/wget/usr/lib -pthread' CFLAGS='-I/tmp/wget/usr/include -pthread' ./configure --build=i486-pc-linux-gnu --host=i486-pc-linux-gnu --prefix=/usr --disable-debug --disable-nls --with-ssl=openssl --with-zlib --with-openssl --with-included-libunistring --with-libssl-prefix=/usr --enable-threads=posix && \
    make -j4 && \
    make install DESTDIR=/tmp/wget && \
    cd .. && \
    rm -rf wget-1.20.3.tar.gz wget-1.20.3 && \
    mv /tmp/wget/usr/bin/wget /usr/local/bin/ && \
    strip --strip-all /usr/local/bin/wget && \
    rm -rf /tmp/wget

# ====================================================================================================

ENV LD_LIBRARY_PATH="/usr/local/lib"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
ENV PATH="/usr/local/bin:${PATH}"

RUN wget ftp://ftp.gnu.org/gnu/gmp/gmp-4.2.4.tar.bz2 && \
    tar -xvpf gmp-4.2.4.tar.bz2 && \
    cd gmp-4.2.4 && \
    ./configure --build=i486-pc-linux-gnu --host=i486-pc-linux-gnu --enable-static --disable-shared && \
    make -j4 && \
    make install && \
    cd .. && \
    rm -rf gmp-4.2.4.tar.bz2 gmp-4.2.4

RUN wget --no-check-certificate http://www.mpfr.org/mpfr-2.4.2/mpfr-2.4.2.tar.gz && \
    tar -xvpf mpfr-2.4.2.tar.gz && \
    cd mpfr-2.4.2 && \
    ./configure --build=i486-pc-linux-gnu --host=i486-pc-linux-gnu --enable-static --disable-shared && \
    make -j4 && \
    make install && \
    cd .. && \
    rm -rf mpfr-2.4.2.tar.gz mpfr-2.4.2

RUN wget --no-check-certificate http://www.multiprecision.org/downloads/mpc-0.8.2.tar.gz && \
    tar -xvpf mpc-0.8.2.tar.gz && \
    cd mpc-0.8.2 && \
    ./configure --build=i486-pc-linux-gnu --host=i486-pc-linux-gnu --enable-static --disable-shared && \
    make -j4 && \
    make install && \
    cd .. && \
    rm -rf mpc-0.8.2.tar.gz mpc-0.8.2

RUN wget ftp://ftp.gnu.org/gnu/gcc/gcc-4.8.5/gcc-4.8.5.tar.bz2 && \
    tar -xvpf gcc-4.8.5.tar.bz2 && \
    cd gcc-4.8.5 && \
    ./configure --prefix=/usr/local --disable-shared --enable-threads=posix --disable-nls --build=i486-linux-gnu --host=i486-linux-gnu --target=i486-linux-gnu --enable-languages=c,c++ --with-tune=generic --disable-libgomp --with-arch-32=i486 --disable-multilib --disable-multiarch && \
    make -j4 && \
    make install && \
    cd .. && \
    rm -rf gcc-4.8.5.tar.bz2 gcc-4.8.5

RUN wget --no-check-certificate http://zlib.net/fossils/zlib-1.2.11.tar.gz && \
    tar -xvpf zlib-1.2.11.tar.gz && \
    cd zlib-1.2.11 && \
    CC=/usr/local/bin/gcc CXX=/usr/local/bin/g++ CPP=/usr/local/bin/cpp CFLAGS="-g0" CXXFLAGS="-g0" ./configure --static --prefix=/usr/local && \
    make -j4 && \
    make install && \
    cd .. && \
    rm -rf zlib-1.2.11.tar.gz zlib-1.2.11

RUN wget ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng16/libpng-1.6.37.tar.gz && \
    tar -xvpf libpng-1.6.37.tar.gz && \
    cd libpng-1.6.37 && \
    mkdir build && \
    cd build && \
    wget --no-check-certificate https://cmake.org/files/v3.6/cmake-3.6.3-Linux-i386.tar.gz && \
    tar -xvpf cmake-3.6.3-Linux-i386.tar.gz && \
    CC=/usr/local/bin/gcc CXX=/usr/local/bin/g++ CPP=/usr/local/bin/cpp CFLAGS="-m32 -g0" CXXFLAGS="-m32 -g0" cmake-3.6.3-Linux-i386/bin/cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DPNG_SHARED=NO -DPNG_STATIC=YES -DPNG_TESTS=NO .. && \
    make -j4 && \
    make install && \
    cd ../.. && \
    rm -rf libpng-1.6.37.tar.gz libpng-1.6.37

RUN wget --no-check-certificate http://download-mirror.savannah.gnu.org/releases/freetype/freetype-2.6.5.tar.gz && \
    tar -xvpf freetype-2.6.5.tar.gz && \
    cd freetype-2.6.5 && \
    CC=/usr/local/bin/gcc CXX=/usr/local/bin/g++ CPP=/usr/local/bin/cpp CFLAGS="-g0" CXXFLAGS="-g0" ./configure --build=i486-pc-linux-gnu --host=i486-pc-linux-gnu --prefix=/usr/local --enable-shared=no --enable-static=yes --with-zlib=yes --with-png=yes --with-harfbuzz=no --with-bzip2=no && \
    make -j4 && \
    make install && \
    cd .. && \
    rm -rf freetype-2.6.5.tar.gz freetype-2.6.5

RUN wget ftp://ftp.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz && \
    tar -xvpf openssl-1.0.2u.tar.gz && \
    cd openssl-1.0.2u && \
    setarch i386 ./Configure linux-generic32 -m32 --prefix=/usr/local --openssldir=/etc/ssl zlib no-shared no-sse2 && \
    make depend && \
    make -j4 && \
    make install && \
    cd .. && \
    rm -rf openssl-1.0.2u.tar.gz openssl-1.0.2u

# ====================================================================================================

RUN wget --no-check-certificate http://download.qt.io/new_archive/qt/5.6/5.6.3/single/qt-everywhere-opensource-src-5.6.3.tar.xz && \
    tar -xvpf qt-everywhere-opensource-src-5.6.3.tar.xz && \
    cd qt-everywhere-opensource-src-5.6.3 && \
    mkdir build && \
    cd build && \
    OPENSSL_LIBS='-L/usr/local/lib -lssl -lcrypto' \
    ../configure -prefix /opt/qt-5.6.3-static -opensource -confirm-license -release -strip -static \
      -qt-sql-sqlite -no-sql-mysql -no-sql-odbc -no-sql-psql -no-sql-sqlite2 -no-sql-tds \
      -no-qml-debug -platform linux-g++-32 -no-sse2 -no-sse3 -no-ssse3 -no-sse4.1 -no-sse4.2 -no-avx -no-avx2 \
      -system-zlib -no-mtdev -no-journald -system-libpng -qt-libjpeg -system-freetype -qt-harfbuzz -openssl-linked -no-libproxy -qt-pcre \
      -qt-xcb -qt-xkbcommon-x11 -xkb-config-root /usr/share/X11/xkb -no-xkbcommon-evdev -no-xinput2 -no-xcb-xlib -glib \
      -no-pulseaudio -no-alsa -gtkstyle -gui -widgets -rpath -verbose -fontconfig -no-icu -dbus-runtime \
      -no-use-gold-linker -no-directfb -opengl desktop -no-mirclient -qpa xcb -no-gstreamer -no-libinput -no-warnings-are-errors \
      -no-compile-examples -nomake tools -nomake examples -nomake tests -skip qt3d -skip qtactiveqt -skip qtandroidextras \
      -skip qtcanvas3d -skip qtconnectivity -skip qtdeclarative -skip qtdoc -skip qtenginio -skip qtgraphicaleffects \
      -skip qtlocation -skip qtmacextras -skip qtmultimedia -skip qtquickcontrols -skip qtquickcontrols2 -skip qtscript \
      -skip qtsensors -skip qtserialbus -skip qtserialport -skip qttools -skip qtwayland -skip qtwebchannel -skip qtwebengine \
      -skip qtwebview -skip qtwinextras -skip qtxmlpatterns -skip qtwebsockets -L /usr/local/lib \
      -no-egl -no-eglfs -no-linuxfb -no-kms -no-openvg -xcb-xlib && \
    make -j4 && \
    make install && \
    cd ../.. && \
    rm -rf qt-everywhere-opensource-src-5.6.3.tar.xz qt-everywhere-opensource-src-5.6.3
