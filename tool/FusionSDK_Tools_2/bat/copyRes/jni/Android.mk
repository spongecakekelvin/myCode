LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := \
../../Classes/protobuf-lite/google/protobuf/io/coded_stream.cc \
../../Classes/protobuf-lite/google/protobuf/stubs/common.cc \
../../Classes/protobuf-lite/google/protobuf/extension_set.cc \
../../Classes/protobuf-lite/google/protobuf/generated_message_util.cc \
../../Classes/protobuf-lite/google/protobuf/message_lite.cc \
../../Classes/protobuf-lite/google/protobuf/stubs/once.cc \
../../Classes/protobuf-lite/google/protobuf/stubs/atomicops_internals_x86_gcc.cc \
../../Classes/protobuf-lite/google/protobuf/repeated_field.cc \
../../Classes/protobuf-lite/google/protobuf/wire_format_lite.cc \
../../Classes/protobuf-lite/google/protobuf/io/zero_copy_stream.cc \
../../Classes/protobuf-lite/google/protobuf/io/zero_copy_stream_impl_lite.cc \
../../Classes/protobuf-lite/google/protobuf/stubs/stringprintf.cc \
../../Classes/runtime/Landscape_png.cpp \
../../Classes/runtime/PlayDisable_png.cpp \
../../Classes/runtime/PlayEnable_png.cpp \
../../Classes/runtime/Portrait_png.cpp \
../../Classes/runtime/Shine_png.cpp \
../../Classes/runtime/Runtime.cpp \
../../Classes/runtime/Protos.pb.cc \
../../Classes/VisibleRect.cpp \
../../Classes/AppDelegate.cpp \
../../Classes/lua_assetsmanager_test_sample.cpp \
../../Classes/ConfigParser.cpp \
../../Classes/MessageDispatcher.cpp \
../../Classes/UpgradeApk.cpp \
../../Classes/SegLoader.cpp \
../../Classes/astar/MapGrid.cpp \
../../Classes/astar/MCAstar.cpp \
../../Classes/astar/MLink.cpp \
../../Classes/astar/MNode.cpp \
../../Classes/astar/WorldMapGrid.cpp \
../../Classes/luabinding/lua_cocos2dx_custom_manual.cpp \
../../Classes/map/CcarpgMcm.cpp \
../../Classes/net/BSDSocket.cpp \
../../Classes/net/CcarpgNet.cpp \
../../Classes/net/ReceiveThread.cpp \
../../Classes/net/SocketThread.cpp \
../../Classes/net/TerminalThread.cpp \
../../Classes/net/TerminalReceiveThread.cpp \
../../Classes/net/Plsocket.cpp \
../../Classes/net/PlFileLoader.cpp \
../../Classes/net/PlFileUploader.cpp \
lua/Runtime_android.cpp \
lua/main.cpp


LOCAL_C_INCLUDES := \
$(LOCAL_PATH)/../../Classes/protobuf-lite \
$(LOCAL_PATH)/../../Classes/runtime \
$(LOCAL_PATH)/../../Classes/luabinding \
$(LOCAL_PATH)/../../Classes/astar \
$(LOCAL_PATH)/../../Classes/map \
$(LOCAL_PATH)/../../Classes/net \
$(LOCAL_PATH)/../../Classes

LOCAL_STATIC_LIBRARIES := curl_static_prebuilt

LOCAL_WHOLE_STATIC_LIBRARIES := cocos_lua_static

include $(BUILD_SHARED_LIBRARY)

$(call import-module,scripting/lua-bindings)