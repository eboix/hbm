GMP_INSTALL_DIR=/u/eboix/gmp_install/gmp-6.1.2
MPFR_INSTALL_DIR=/u/eboix/gmp_install/mpfr-3.1.6
MPFR_REAL_INSTALL_DIR=/u/eboix/gmp_install/mpfr_real_v0.0.9-alpha

GMP_INCLUDE=$(GMP_INSTALL_DIR)
GMP_LIBS=$(GMP_INSTALL_DIR)/.libs
GMP_LIBC=$(GMP_INSTALL_DIR)/libgmp.la
GMP_LIBCPP=$(GMP_INSTALL_DIR)/libgmpxx.la
MPFR_INCLUDE=$(MPFR_INSTALL_DIR)/src
MPFR_LIBS=$(MPFR_INSTALL_DIR)/src/.libs
MPFR_LIBC=$(MPFR_INSTALL_DIR)/src/libmpfr.la
MPFR_REAL_INCLUDE=$(MPFR_REAL_INSTALL_DIR)

LIBTOOL=$(GMP_INSTALL_DIR)/libtool
GMP_COMPILE=g++ -DHAVE_CONFIG_H -I$(MPFR_INCLUDE) -I$(GMP_INCLUDE) -I$(MPFR_REAL_INCLUDE) -O2 -pedantic -fomit-frame-pointer -m64 -mtune=corei7 -march=corei7 -c -o
GMP_LINK=/bin/sh $(LIBTOOL)  --tag=CXX   --mode=link g++ -O2 -pedantic -fomit-frame-pointer -m64 -mtune=corei7 -march=corei7 -L$(MPFR_LIBS) -L$(GMP_LIBS) $(MPFR_LIBC) $(GMP_LIBCPP)  $(GMP_LIBC) -lm -o 

all: A

A.o: A.cpp
	$(GMP_COMPILE) A.o A.cpp

A: A.o
	$(GMP_LINK) A A.o

clean:
	rm -f A.o A
