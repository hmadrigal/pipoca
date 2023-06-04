#pragma once

#include <tuple>

#include <zeek/Val.h>

namespace plugin
{
	namespace Demo_ProtobufAnalyzer
	{

		std::tuple<uint64_t, uint64_t> DecodeVarint(std::vector<u_char> buffer, uint64_t offset);

	}
}