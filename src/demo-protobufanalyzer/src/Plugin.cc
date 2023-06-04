
#include "Plugin.h"
#include "Protobuf.h"

#include "zeek/plugin/Plugin.h"

#include "zeek/file_analysis/Component.h"
#include "zeek/file_analysis/analyzer/extract/Extract.h"

namespace zeek::plugin::detail::Zeek_Protobuf
{
	zeek::plugin::Configuration Plugin::Configure()
	{
		AddComponent(new zeek::file_analysis::Component(
			"PROTOBUF", zeek::file_analysis::detail::Protobuf::Instantiate));

		zeek::plugin::Configuration config;
		config.name = "Demo::ProtobufAnalyzer";
		config.description = "Prototype for a ProtocolBuf decoder.";
		config.version.major = 0;
		config.version.minor = 1;
		config.version.patch = 0;

		return config;
	};

}
