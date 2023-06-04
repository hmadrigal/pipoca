#pragma once

// #include <cstdio>
// #include <string>
#include <vector>

#include "zeek/Val.h"

#include "VarintUtils.h"
// #include "zeek/file_analysis/Analyzer.h"
// #include "zeek/file_analysis/File.h"
// #include "zeek/file_analysis/analyzer/extract/events.bif.h"

namespace zeek::file_analysis::detail
	{

class BufferReader
	{

private:
	std::vector<u_char> buffer;
	uint64_t offset;
	uint64_t savedOffset;

public:
	BufferReader(std::vector<u_char> data);

	uint64_t GetOffset();

	uint64_t LeftBytes();

	void Checkpoint(void);

	std::tuple<uint64_t, std::vector<u_char>> ReadVarint();

	std::vector<u_char> ReadBuffer(uint64_t length);
	};

	}