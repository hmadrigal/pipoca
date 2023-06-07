# Enables http2 analyzer
@load http2

# Enables http2 intel framework extensions
@load http2/intel

# Enables custom pages
@load packages

# Enables extraction of all files
# @load frameworks/files/extract-all-files

# Enables Protobuf Analyzer
# @load demo-protobufanalyzer

# Use JSON for the log files
redef LogAscii::use_json=T;

# Ignores checksum check
redef ignore_checksums=T;

# =============================== Logic to detect gRPC over HTTP2 and request file analysis

export {
	type ProtobufInfo: record 
    {
		## Filename for the entity if discovered from a header.
		contentType: string &optional;
	};
}


redef record HTTP2::Info += {
    protobufinfo:          ProtobufInfo  &optional;
};

redef record fa_file += {
    protobufinfo:          ProtobufInfo  &optional;
};

event http2_begin_entity(c: connection, is_orig: bool, stream: count, contentType: string) &priority=10
{
    # print "[http2_begin_entity]";

    c$http2$protobufinfo = ProtobufInfo();
}

event http2_header(c: connection, is_orig: bool, stream: count, name: string, value: string) &priority=3
{
    # print "[http2_header_event]";

    if ( name == "CONTENT-TYPE" 
        && /[aA][pP][pP][lL][iI][cC][aA][tT][iI][oO][nN]\/[gG][rR][pP][cC]*/ in value )
    {
		# Detected content gRPC
        # print "FOUND gRPC!!!", value;
        if ( c?$http2 && c$http2?$protobufinfo )
        {
            c$http2$protobufinfo$contentType = "application/grpc";
            # print "c.http2.protobufinfo.contentType set to" , c$http2$protobufinfo$contentType;
        }
    }

}

event file_over_new_connection(f: fa_file, c: connection, is_orig: bool) &priority=5
{
    # print "[file_over_new_connection]";

    f$protobufinfo=c$http2$protobufinfo;

}

event file_sniff(f: fa_file, meta: fa_metadata) &priority=5
{
    # print "[file_sniff]";
    # print "f.protobufinfo", f$protobufinfo;

    if (f?$protobufinfo 
        && f$protobufinfo?$contentType 
        && f$protobufinfo$contentType == "application/grpc")
    {
        # print "PROTO FILE DETECTED!! Calling ANALYZER_PROTOBUF";
        Files::add_analyzer(f, Files::ANALYZER_PROTOBUF);
    }
}

event http2_end_entity(c: connection, is_orig: bool, stream: count) &priority=5
{
    # print "[http2_end_entity]";

	if ( c?$http2 && c$http2?$protobufinfo )
    {
		delete c$http2$protobufinfo;
	}
}

# =============================== Handling gRPC text event
event protobuf_string(f: fa_file, text: string)
{
    print "[protobuf_string]";

    print "text", text;
}