
#pragma once

#include "Protobuf.h"

#include <zeek/plugin/Plugin.h>
#include <zeek/file_analysis/Component.h>
#include <zeek/file_analysis/analyzer/extract/Extract.h>

namespace plugin {
namespace Demo_ProtobufAnalyzer {

		class Plugin : public zeek::plugin::Plugin
		{
		protected:
			// Overridden from zeek::plugin::Plugin.
			zeek::plugin::Configuration Configure() override;
		};

		extern Plugin plugin;

	}
}
