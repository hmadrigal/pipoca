#include "Protobuf.h"

namespace plugin
	{
namespace Demo_ProtobufAnalyzer
	{

Protobuf::Protobuf(zeek::RecordValPtr args, zeek::file_analysis::File* file)
	: zeek::file_analysis::Analyzer(zeek::file_mgr->GetComponentTag("PROTOBUF"), std::move(args), file)
	{
	}

std::tuple<std::vector<ProtobufPart>, std::vector<u_char>>
Protobuf::DecodeProto(std::vector<u_char> data)
	{

	std::vector<ProtobufPart> parts;

	BufferReader reader = BufferReader(data);

	while ( reader.LeftBytes() > 0 )
		{
		reader.Checkpoint();

		uint64_t byteRangeStart = reader.GetOffset();
		uint64_t byteRangeEnd = 0;
		const auto [indexType, _] = reader.ReadVarint();
		uint64_t type = indexType & 0x7;
		uint64_t index = indexType >> 3;
		std::vector<u_char> value;

		// uint64_t value = 0;

		if ( type == TYPES::VARINT )
			{
			const auto [number, data] = reader.ReadVarint();
			value = data;
			}
		else if ( type == TYPES::LENDELIM )
			{
			const auto [length, _] = reader.ReadVarint();
			value = reader.ReadBuffer(length);
			}
		else if ( type == TYPES::FIXED32 )
			{
			value = reader.ReadBuffer(4);
			}
		else if ( type == TYPES::FIXED64 )
			{
			value = reader.ReadBuffer(8);
			}
		else
			{
			throw std::runtime_error("Unknown type");
			}

		byteRangeEnd = reader.GetOffset();

		ProtobufPart part = {byteRangeEnd, byteRangeStart, index, type, value};
		parts.push_back(part);

		// if ( protobuf_string )
		// 	{
		// 	std::string str(buffer.begin(), buffer.end());
		// 	zeek::event_mgr.Enqueue(protobuf_string, GetFile()->ToVal(),
		// 	                        zeek::make_intrusive<zeek::StringVal>(str));
		// 	}
		}

	std::vector<u_char> leftOver = reader.ReadBuffer(reader.LeftBytes());
	return std::make_tuple(parts, leftOver);
	}

bool Protobuf::DeliverStream(const u_char* data, uint64_t len)
	{
	// Keeps the data in memory
	for ( uint64_t i = 0; i <= len; i++ )
		{
		buffer.push_back(data[i]);
		}

	return true;
	}

void Protobuf::DecodeProtobufPart(ProtobufPart part)
	{
	switch ( part.type )
		{
		case TYPES::VARINT:
			break;
		case TYPES::LENDELIM:
			{
			const auto [parts, leftOver] = DecodeProto(part.value);
			if ( part.value.size() > 0 && leftOver.size() == 0 )
				{
				// part.value is likely to be a sub message
				ProtobufDisplay(parts);
				}
			else
				{
				// part.value is likely to be a string or bytes
				// trigger event using value
				const u_char* data = part.value.data();
				zeek::event_mgr.Enqueue(protobuf_string, GetFile()->ToVal(),
				                        zeek::make_intrusive<zeek::StringVal>(
											new zeek::String(data, part.value.size(), false)));
				}
			break;
			}
		case TYPES::FIXED32:
			// trigger event using value
			break;
		case TYPES::FIXED64:
			// trigger event using value
			break;
		default:
			throw std::runtime_error("Unknown type");
		}
	}

bool Protobuf::EndOfFile()
	{

	const auto [parts, _] = DecodeProto(buffer);

	return ProtobufDisplay(parts);
	}

bool Protobuf::ProtobufDisplay(std::vector<ProtobufPart> parts)
	{
	for ( ProtobufPart part : parts )
		{
		DecodeProtobufPart(part);
		}
	return true;
	}

zeek::file_analysis::Analyzer* Protobuf::Instantiate(zeek::RecordValPtr args,
                                                     zeek::file_analysis::File* file)
	{
	return new Protobuf(std::move(args), file);
	}

	}
	}