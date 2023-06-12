
cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

project(ZeekPluginProtobufAnalyzer)

include(ZeekPlugin)

zeek_plugin_begin(Demo ProtobufAnalyzer ${ZEEK_PLUGIN_BEGIN_OPTS})
zeek_plugin_cc(src/Plugin.cc src/BufferReader.cc src/Protobuf.cc src/VarintUtils.cc src/libinjection/libinjection_sqli.c)
zeek_plugin_bif(src/protobufanalyzer.bif)
zeek_plugin_bif(src/events.bif)
zeek_plugin_dist_files(README CHANGES COPYING VERSION)
zeek_plugin_scripts(
        scripts/__load__.zeek
        scripts/__preload__.zeek
        scripts/types.zeek
        scripts/Demo/ProtobufAnalyzer/__load__.zeek
)
zeek_plugin_end()

file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION" VERSION LIMIT_COUNT 1)

if ("${PROJECT_SOURCE_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
    # Allows building rpm/deb packages via "make package" in build dir.
    include(ConfigurePackaging)
    ConfigurePackaging(${VERSION})
endif ()
