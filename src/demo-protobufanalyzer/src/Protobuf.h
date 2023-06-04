#pragma once

#include <tuple>
#include <vector>

#include "BufferReader.h"
#include "events.bif.h"

#include <zeek/Val.h>
#include <zeek/Event.h>
#include <zeek/file_analysis/Analyzer.h>
#include <zeek/file_analysis/File.h>

namespace plugin
{
	namespace Demo_ProtobufAnalyzer
	{

		typedef struct
		{
			uint64_t byteRangeEnd;
			uint64_t byteRangeStart;
			uint64_t index;
			uint64_t type;
			std::vector<u_char> value;

		} ProtobufPart;

		enum TYPES
		{
			VARINT = 0,
			FIXED64 = 1,
			LENDELIM = 2,
			FIXED32 = 5
		};

		class Protobuf : public file_analysis::Analyzer
		{
		public:
			static file_analysis::Analyzer *Instantiate(RecordValPtr args, file_analysis::File *file);

			bool DeliverStream(const u_char *data, uint64_t len) override;

			bool EndOfFile() override;

			std::tuple<std::vector<ProtobufPart>, std::vector<u_char>>
			DecodeProto(std::vector<u_char> data);
			void DecodeProtobufPart(ProtobufPart part);

			bool ProtobufDisplay(std::vector<ProtobufPart> parts);

		protected:
			Protobuf(RecordValPtr args, file_analysis::File *file);

		private:
			std::vector<u_char> buffer;
		};
	}
}