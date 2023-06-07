#pragma once

#include <vector>
#include <iostream>

#include <zeek/Val.h>

#include "VarintUtils.h"

namespace plugin
{
	namespace Demo_ProtobufAnalyzer
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

			void ResetToCheckpoint(void);

			std::tuple<uint64_t, std::vector<u_char>> ReadVarint();

			std::vector<u_char> ReadBuffer(uint64_t length);
		};

	}
}