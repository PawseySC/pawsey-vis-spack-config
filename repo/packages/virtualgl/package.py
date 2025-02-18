# Copyright 2013-2021 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class Virtualgl(CMakePackage):
    """VirtualGL redirects 3D commands from a Unix/Linux OpenGL application
       onto a server-side GPU and converts the rendered 3D images into a video
       stream with which remote clients can interact to view and control the
       3D application in real time."""

    homepage = "https://www.virtualgl.org/Main/HomePage"
    #url      = "https://sourceforge.net/projects/virtualgl/files/2.6.3/VirtualGL-2.6.3.tar.gz/download"
    #url      = "https://sourceforge.net/projects/virtualgl/files/3.0.1/VirtualGL-3.0.1.tar.gz/download"
    url      = "https://sourceforge.net/projects/virtualgl/files/3.1/VirtualGL-3.1.tar.gz/download"
    maintainers = ['syathunanthan']
    
    tags = ["visualisation"]

    version('3.1', sha256='57bd20a9b1127de344313b6178b19610838a6af6309c059702788e41b6a875d0')
    version('3.0.1', sha256='a96c620963243f4a2f47b0c5b04c557b1f9f0bcdeab958b1ff1e6247f00c58c3')
    version('2.6.3', sha256='9be36c540c512068c8fc26a28722e604e0d2c305f7295229f1e1c8283193cb5e')
    #version('2.6.3', sha256='bdb60d72f0a0b6e8c0ef2b904c0779e6c427ed66d51e1ac1875b3b5e51b1897b')

    # This package will only work with libjpeg-turbo, not other jpeg providers    
    depends_on("libjpeg-turbo")

    def cmake_args(self):
        # FIXME: CMAKE_INSTALL_PREFIX and CMAKE_BUILD_TYPE
        args = [
        '-DOpenCL_INCLUDE_DIR=/usr/include/',
#        '-DCMAKE_C_FLAGS=-fPIC',
#        '-DCMAKE_CXX_FLAGS=-fPIC',
        '-DVGL_FAKEXCB=ON',
        '-DOPENGL_glu_LIBRARY=/usr/lib64/libGLU.so',
        '-DX11_Xtst_LIB=/usr/lib64/libXtst.so',
        '-DX11_Xtst_INCLUDE_PATH=/usr/include/',
        '-DX11_ICE_INCLUDE_PATH=/usr/include',
        '-DX11_ICE_LIB=/usr/lib64/libICE.so',
        '-DX11_X11_INCLUDE_PATH=/usr/include',
        '-DX11_X11_LIB=/usr/lib64/libX11.so',
        '-DOpenCL_INCLUDE_DIR=/usr/include',
        '-DOpenCL_LIBRARY=/usr/lib64/libOpenCL.so.1']
        return args

