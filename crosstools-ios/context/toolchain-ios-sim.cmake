set (CMAKE_SYSTEM_NAME Darwin)
set (CMAKE_SYSTEM_VERSION 1)
set (UNIX True)
set (APPLE True)
set (IOS True)

set(CMAKE_C_COMPILER x86_64-apple-darwin11-clang)
set(CMAKE_CXX_COMPILER x86_64-apple-darwin11-clang++)

set(_CMAKE_TOOLCHAIN_PREFIX x86_64-apple-darwin11-)

set(CMAKE_IOS_SDK_ROOT "/usr/x86_64-apple-darwin11/sdk")

set(CMAKE_OSX_SYSROOT ${CMAKE_IOS_SDK_ROOT} CACHE PATH "Sysroot used for iOS support")

set(IOS_ARCH x86_64)
set(CMAKE_OSX_ARCHITECTURES ${IOS_ARCH} CACHE string "Build architecture for iOS")

set(CMAKE_FIND_ROOT_PATH ${CMAKE_IOS_DEVELOPER_ROOT} ${CMAKE_IOS_SDK_ROOT} ${CMAKE_PREFIX_PATH} CACHE string "iOS find search path root")

set(CMAKE_FIND_FRAMEWORK FIRST)

set(CMAKE_SYSTEM_FRAMEWORK_PATH
    ${CMAKE_IOS_SDK_ROOT}/System/Library/Frameworks
)
