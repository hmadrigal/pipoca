
#include "Plugin.h"

namespace plugin { namespace Demo_ProtobufAnalyzer { Plugin plugin; } }

using namespace plugin::Demo_ProtobufAnalyzer;

zeek::plugin::Configuration Plugin::Configure()
{
	plugin::Demo_ProtobufAnalyzer::plugin.AddComponent(new zeek::file_analysis::Component(
		"PROTOBUF", plugin::Demo_ProtobufAnalyzer::Protobuf::Instantiate));

	std::cout << "Running: plugin::Demo_ProtobufAnalyzer" << std::endl;
	
	zeek::plugin::Configuration config;
	config.name = "Demo::ProtobufAnalyzer";
	config.description = "Prototype for a ProtocolBuf decoder.";
	config.version.major = 0;
	config.version.minor = 1;
	config.version.patch = 0;
	return config;
}
