#include "BufferReader.h"

// #include <cstdio>
// #include <string>

// #include "zeek/Val.h"
// #include "zeek/file_analysis/Analyzer.h"
// #include "zeek/file_analysis/File.h"
// #include "zeek/file_analysis/analyzer/extract/events.bif.h"

// #include "VarintUtils.h"

namespace zeek::file_analysis::detail
	{

BufferReader::BufferReader(std::vector<u_char> data)
	{
	buffer = data;
	offset = 0;
	}

uint64_t BufferReader::GetOffset()
	{
	return offset;
	}

std::tuple<uint64_t, std::vector<u_char>> BufferReader::ReadVarint()
	{
	const auto [value, length] = DecodeVarint(buffer, offset);
	std::vector<u_char> data(buffer.begin() + offset, buffer.begin() + offset + length + 1);
	offset += length;
	return std::make_tuple(value, data);
	}

std::vector<u_char> BufferReader::ReadBuffer(uint64_t length)
	{
	std::vector<u_char> res;
	for ( uint64_t i = 0; i < length; i++ )
		{
		res.push_back(buffer[offset++]);
		}
	return res;
	}

uint64_t BufferReader::LeftBytes()
	{
	return buffer.size() - offset;
	}

void BufferReader::Checkpoint(void)
	{
	savedOffset = offset;
	}

	}