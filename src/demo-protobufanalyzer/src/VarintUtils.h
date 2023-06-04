#pragma once

#include <tuple>
// #include <cstdio>
// #include <string>

#include "zeek/Val.h"
// #include "zeek/file_analysis/Analyzer.h"
// #include "zeek/file_analysis/File.h"
// #include "zeek/file_analysis/analyzer/extract/events.bif.h"

namespace zeek::file_analysis::detail
	{

std::tuple<uint64_t, uint64_t> DecodeVarint(std::vector<u_char> buffer, uint64_t offset);

	}