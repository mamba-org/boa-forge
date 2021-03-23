set(MAMBA_EXE
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/clean.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/config.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/constructor.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/create.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/info.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/install.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/list.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/common_options.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/main.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/remove.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/shell.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/umamba.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/update.cpp
)

set(MAMBA_EXE_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/clean.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/config.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/constructor.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/create.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/info.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/install.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/list.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/common_options.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/remove.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/shell.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/umamba.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/micromamba/update.hpp
)

add_executable(micromamba ${MAMBA_EXE} ${MAMBA_EXE_HEADERS})

target_include_directories(
    micromamba
    PRIVATE $<BUILD_INTERFACE:${MAMBA_INCLUDE_DIR}>
)

target_link_libraries(micromamba PRIVATE mamba-static)

message("Using static dependencies for micromamba: ${STATIC_DEPENDENCIES}")

if (STATIC_DEPENDENCIES AND UNIX)
    set(MAMBA_DEPENDENCIES_LIBS
        libcurl.a
        libssh2.a

        # libgssapi_krb5.a
        # libkrb5.a
        # libk5crypto.a
        # libkrb5support.a
        # libcom_err.a

        libssl.a
        libcrypto.a

        libarchive.a

        # libiconv.a
        libbz2.a
        # liblz4.a
        libzstd.a
        libz.a
        # liblzma.a
        # liblzo2.a

        libsolv.a
        libsolvext.a

        # libnghttp2.a
        libyaml-cpp.a

        libreproc++.a
        libreproc.a
    )

    if (APPLE)
        list(APPEND MAMBA_DEPENDENCIES_LIBS libiconv.a)
        list(REMOVE_ITEM MAMBA_DEPENDENCIES_LIBS libssl.a)
    endif()

    set(FINAL_LIBS "")
    foreach(LIB ${MAMBA_DEPENDENCIES_LIBS})
        set(TMP_LIB "TMP_LIB-NOTFOUND")
        find_library(TMP_LIB
            NAMES "${LIB}"
        )
        list(APPEND FINAL_LIBS "${TMP_LIB}")
    endforeach(LIB)

    if (APPLE)
        find_library(SECURITY_LIBRARY Security)
        find_library(COREFOUNDATION_LIBRARY CoreFoundation)
        message("Found library:\n  - ${SECURITY_LIBRARY}\n  - ${COREFOUNDATION_LIBRARY}")
        list(APPEND FINAL_LIBS ${COREFOUNDATION_LIBRARY} ${SECURITY_LIBRARY})
    endif()

    message("  Found static dependencies:")
    foreach(LIB ${FINAL_LIBS})
        message("   - ${LIB}")
    endforeach(LIB)

    if (APPLE)
        set (MAMBA_FORCE_DYNAMIC_LIBS resolv)
        target_link_options(micromamba PRIVATE -static-libstdc++)
    elseif (UNIX)
        set(MAMBA_FORCE_DYNAMIC_LIBS rt dl resolv)
        target_link_options(micromamba PRIVATE -static-libstdc++ -static-libgcc)
    endif()

    target_link_libraries(micromamba PRIVATE ${FINAL_LIBS} ${MAMBA_FORCE_DYNAMIC_LIBS})

elseif (STATIC_DEPENDENCIES AND WIN32)

    # For Windows we have a vcpkg based build system right now.
    find_library(LIBARCHIVE_LIBRARY archive_static.lib)

    find_package(CURL CONFIG REQUIRED)
    find_package(yaml-cpp CONFIG REQUIRED)
    find_package(nlohmann_json CONFIG REQUIRED)
    # find_package(LibLZMA CONFIG REQUIRED)
    # find_library(LZ4_LIBRARY NAMES lz4)
    # find_library(LZO2_LIBRARY NAMES lzo2)
    find_library(LIBZSTD_LIBRARY NAMES zstd_static.lib)
    find_library(BZIP2_LIBRARIES bz2.lib)
    find_library(CRYPTO_LIBRARIES NAMES libcrypto_static)

    find_library(LIBSOLV_STATIC_LIBRARIES NAMES solv_static)
    find_library(LIBSOLVEXT_STATIC_LIBRARIES NAMES solvext_static)
    find_package(reproc++ CONFIG REQUIRED)
    # find_library(REPROC_LIBRARY "reproc_static.lib")
    # find_library(REPROCPP_LIBRARY "reproc++_static.lib")

    target_link_libraries(micromamba PRIVATE
        ${CRYPTO_LIBRARIES}
        crypt32.lib
        ${LIBARCHIVE_LIBRARY}
        ${LIBZSTD_LIBRARY}
        # ${LZ4_LIBRARY}
        # ${LZO2_LIBRARY}
        ${BZIP2_LIBRARIES}
        ${LIBLZMA_LIBRARIES}
        CURL::libcurl
        nlohmann_json::nlohmann_json
        ${YAML_CPP_LIBRARIES}
        ${LIBSOLV_STATIC_LIBRARIES}
        ${LIBSOLVEXT_STATIC_LIBRARIES}
        reproc++
    )

    add_definitions("-DLIBARCHIVE_STATIC -DCURL_STATICLIB -DSOLV_STATIC_LIB")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
    include_directories($ENV{CONDA_PREFIX}/Library/include/)
    include_directories($ENV{VCPKG_ROOT}/installed/x64-windows-static/include/)
endif()

set_property(TARGET micromamba PROPERTY CXX_STANDARD 17)

install(TARGETS micromamba)
