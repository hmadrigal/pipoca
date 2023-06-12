# Enables http2 analyzer
@load http2

# Enables custom pages (for instance: PROTOBUF)
@load packages

# Use JSON for the log files
redef LogAscii::use_json=T;

# Ignores checksum check
redef ignore_checksums=T;

# =============================== Logic to detect gRPC over HTTP2 and request file analysis

export {
	type ProtobufInfo: record 
    {
		is_gRPC: bool &optional;
        is_orig: bool &optional;
	};
}


redef record HTTP2::Info += {
    protobufinfo:          ProtobufInfo  &optional;
};

redef record fa_file += {
    protobufinfo:          ProtobufInfo  &optional;
};

event http2_request(c: connection, is_orig: bool, stream: count, method: string, authority: string, host: string, original_URI: string, unescaped_URI: string, version: string, push: bool)
{
    print "[http2_request]";
    print "    original_URI", original_URI;
    # print "    method", method;
    # print "    authority", authority;
    # print "    host", host;
    # print "    original_URI", original_URI;
    # print "    unescaped_URI", unescaped_URI;
    # print "    version", version;
    # print "    push", push;
    #c$http2$protobufinfo = ProtobufInfo();
}

event http2_header(c: connection, is_orig: bool, stream: count, name: string, value: string) &priority=3
{
    local is_grpc : bool = ( name == "CONTENT-TYPE" && value == "application/grpc" );

    print "[http2_header_event]";
    # print "    name", name;
    # print "    value", value;
    # print "    is_orig: ", is_orig;
    # print "    is_grpc: ", is_grpc;

    if( is_grpc )
    {
        print "    is_grpc: ", is_grpc;
        print "    name", name;
        print "    value", value;
    }
    
    if ( c?$http2 && c$http2?$protobufinfo )
    {
        c$http2$protobufinfo$is_gRPC = c$http2$protobufinfo$is_gRPC || is_grpc;
        print "    Updating c.http2.protobufinfo.is_gRPC to", c$http2$protobufinfo$is_gRPC;
    }

}

event http2_begin_entity(c: connection, is_orig: bool, stream: count, contentType: string) &priority=10
{
    print "[http2_begin_entity]";
    # print "    is_orig", is_orig;
    # print "    http2", c$http2;

    c$http2$protobufinfo = ProtobufInfo();
    c$http2$protobufinfo$is_gRPC = F;
    c$http2$protobufinfo$is_orig = is_orig;
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
        && f$protobufinfo?$is_gRPC 
        && f$protobufinfo$is_gRPC == T )
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
    local result_is_sql_injection = is_sql_injection(text, |text|);
    print "is_sql_injection", result_is_sql_injection;
}