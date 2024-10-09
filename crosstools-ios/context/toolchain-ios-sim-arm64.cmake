set (CMAKE_SYSTEM_NAME Darwin)
set (CMAKE_SYSTEM_VERSION 1)
set (UNIX True)
set (APPLE True)
set (IOS True)

set(CMAKE_C_COMPILER arm64-ios-simulator-clang)
set(CMAKE_CXX_COMPILER arm64-ios-simulator-clang++)

set(_CMAKE_TOOLCHAIN_PREFIX arm64-ios-simulator-)

set(CMAKE_IOS_SDK_ROOT "/usr/arm64-ios-simulator/sdk")

set(CMAKE_OSX_SYSROOT ${CMAKE_IOS_SDK_ROOT} CACHE PATH "Sysroot used for iOS support")

set(IOS_ARCH arm64)
set(CMAKE_OSX_ARCHITECTURES ${IOS_ARCH} CACHE STRING "Build architecture for iOS")

set(CMAKE_FIND_ROOT_PATH ${CMAKE_IOS_DEVELOPER_ROOT} ${CMAKE_IOS_SDK_ROOT} ${CMAKE_PREFIX_PATH} CACHE STRING "iOS find search path root")

set(CMAKE_FIND_FRAMEWORK FIRST)

set(CMAKE_SYSTEM_FRAMEWORK_PATH
    ${CMAKE_IOS_SDK_ROOT}/System/Library/Frameworks
)

set(CMAKE_CXX_FLAGS "-std=c++17")
