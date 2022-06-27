#!/usr/bin/bash
#==============================================================================
#title        : install_netcdf.sh
#author       : Alessandro Mercatini - ISPRA-CSA
#mail         : alessandro.mercatini@isprambiente.it
#date         : 20062022
#usage        : bash ./install_netcdf.sh
#notes        : Compile netcdf library and all dependencies with Intel fortran compiler (oneAPI-hpckit).		
#==============================================================================

version_szip="2.1.1"
version_zlib="1.2.11"
version_hdf5="1.12.0"
version_curl="7.82.0"
version_netcdf4="4.8.0"
version_netcdf4_fortran="4.5.4"

####################################################
###### -Don't touch anything below this line- ######
####################################################

PS3='Choose library:: '
elenco=("Install requirements" "Install szip-${version_szip}" "Install zlib-${version_zlib}" "Install hdf5-${version_hdf5}" "Install netcdf-c-${version_netcdf4}" "Install netcdf-fortran-${version_netcdf4_fortran}" "Quit")
select fav in "${elenco[@]}"; do
    case $fav in


        "Install requirements")
            echo "Installing requirements..."
	    #PAUSE 'Press [Enter] key to continue...'
	    if ! exist="$(type -p "wget")" || [ -z "$exist" ]; then
  	      apt install wget
	    fi
	    ## to install netcdf library
	    if ! exist="$(type -p "m4")" || [ -z "$exist" ]; then
  	      apt install m4
	    fi
	    ## to install curl
	    if ! exist="$(type -p "curl")" || [ -z "$exist" ]; then
  	      apt install curl
	    fi
	    ## to install gawk
	    if ! exist="$(type -p "gawk")" || [ -z "$exist" ]; then
  	      apt install gawk
	    fi
	    echo -e "${GREEN} All basic requirements are installed${NC}"
	    ;;
        "Install szip-${version_szip}")
            echo "Installing szip-${version_szip}"
            wget -nc -nv https://support.hdfgroup.org/ftp/lib-external/szip/${version_szip}/src/szip-${version_szip}.tar.gz
  	    tar xf szip-${version_szip}.tar.gz
  	    rm -r szip-${version_szip}.tar.gz
  	    cd szip-${version_szip}
	    ./configure --prefix=/usr/local/szip/${version_szip}
	    make -j 10
	    make install
	    cd ..
            rm -r szip-${version_szip}
            ;;
        "Install zlib-${version_zlib}")
            echo "Installing zlib-${version_zlib}"
            wget -nc -nv https://zlib.net/fossils/zlib-${version_zlib}.tar.gz
            tar xf zlib-${version_zlib}.tar.gz
	    rm -r zlib-${version_zlib}.tar.gz
	    cd zlib-${version_zlib}
            ./configure --prefix=/usr/local/zlib/${version_zlib}
	    make -j 10
	    make install
	    cd ..
	    rm -r zlib-${version_zlib}
	    ;;
        "Install hdf5-${version_hdf5}")
            echo "Installing hdf5-${version_hdf5}"
            wget -nc -nv https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.12/hdf5-${version_hdf5}/src/hdf5-${version_hdf5}.tar.gz 
  	    tar xf hdf5-${version_hdf5}.tar.gz
            rm -r hdf5-${version_hdf5}.tar.gz
	    cd hdf5-${version_hdf5}
	    export CXXCPP='icpc -E'
	    export CFLAGS='-O1 -ip -mp1 -shared-intel' 
	    export CXXFLAGS='-O1 -ip -mp1 -shared-intel'
	    export CPP='icc -E' 
	    export CC=mpiicc
	    export CXX=mpiicpc 
	    export F9X=mpiifort 
	    export FC=mpiifort 
	    export CFLAGS='-O3'
	    ./configure --prefix=/usr/local/hdf5/${version_hdf5} --enable-shared --enable-static --enable-parallel --enable-fortran --with-default-api-version=v18 --with-zlib=/usr/local/zlib/${version_zlib}/include,/usr/local/zlib/${version_zlib}/lib
	    make -j 10
	    make install
	    cd .. 
	    rm -r hdf5-${version_hdf5}
	    ;;
        "Install netcdf-c-${version_netcdf4}")
            echo "Installing netcdf-c-${version_netcdf4}"
            wget -nc -nv ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-c-${version_netcdf4}.tar.gz
	    tar xzvf netcdf-c-${version_netcdf4}.tar.gz
	    rm -r netcdf-c-${version_netcdf4}.tar.gz
	    cd netcdf-c-${version_netcdf4}/
	    export LDFLAGS="-L/usr/local/hdf5/${version_hdf5}/lib -L/usr/local/zlib/${version_zlib}/lib -L/usr/local/curl/${version_curl}/lib"
	    export CPPFLAGS="-I/usr/local/hdf5/${version_hdf5}/include -I/usr/local/zlib/${version_zlib}/include ${LDFLAGS} -I/usr/local/curl/${version_curl}/include"
	    export OPTIM="-O3 -mcmodel=large -fPIC ${LDFLAGS}"
	    export CC=icc
	    export FC=ifort
	    export CPP="icc -E -mcmodel=large"
	    export CXXCPP="icpc -E -mcmodel=large"
	    export CFLAGS="${OPTIM}"
	    export CXXFLAGS="${OPTIM}"
	    ./configure --prefix=/usr/local/netcdf4-intel/${version_netcdf4} --enable-shared --enable-static --enable-netcdf-4 --disable-dap
	    make
	    make install
	    cd ..
	    rm -r netcdf-c-${version_netcdf4}
	    ;;
        "nstall netcdf-fortran-${version_netcdf4_fortran}")
            echo "nstalling netcdf-fortran-${version_netcdf4_fortran}"
            wget -nc -nv https://downloads.unidata.ucar.edu/netcdf-fortran/4.5.4/netcdf-fortran-${version_netcdf4_fortran}.tar.gz
	    tar xzvf netcdf-fortran-${version_netcdf4_fortran}.tar.gz
	    rm -r netcdf-fortran-${version_netcdf4_fortran}.tar.gz
	    cd netcdf-fortran-${version_netcdf4_fortran}
	    export NCDIR="/usr/local/netcdf4-intel/${version_netcdf4}"
	    export LD_LIBRARY_PATH="${NCDIR}/lib:${LD_LIBRARY_PATH}"
	    export NFDIR="/usr/local/netcdf4-intel-fortran/${version_netcdf4_fortran}"
	    export CPPFLAGS="-I${NCDIR}/include"
	    export LDFLAGS="-L${NCDIR}/lib"
	    export OPTIM="-O3 -mcmodel=large -fPIC ${LDFLAGS}"
	    export CC=icc
	    export FC=ifort
	    export CPP="icc -E -mcmodel=large"
	    export CXXCPP="icpc -E -mcmodel=large"
	    export CPPFLAGS="-DNDEBUG -DpgiFortran ${LDFLAGS} $CPPFLAGS"
	    export CFLAGS="${OPTIM}"
	    export CXXFLAGS="${OPTIM}"
	    export FCFLAGS="${OPTIM}"
	    export F77FLAGS="${OPTIM}"
	    export F90FLAGS="${OPTIM}"
	    ./configure --prefix=${NFDIR} --enable-large-file-tests --with-pic
	    make
	    make install
	    cd ..
	    rm -r netcdf-fortran-${version_netcdf4_fortran};;
	"Quit")
	    echo "User requested exit"
	    exit
	    ;;
	esac
done


echo " Installation done... you have to export the netCDF path in your system manually!"
export PATH="/usr/local/netcdf4-intel/4.8.0/bin:$PATH"
export PATH="/usr/local/netcdf4-intel-fortran/4.5.4/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/netcdf4-intel/4.8.0/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/usr/local/netcdf4-intel-fortran/4.5.4/lib:$LD_LIBRARY_PATH"

