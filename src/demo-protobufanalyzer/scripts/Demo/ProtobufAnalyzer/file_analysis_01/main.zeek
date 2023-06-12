# Enables http2 analyzer
@load http2

# Enables custom pages (for instance: PROTOBUF)
@load packages

# Use JSON for the log files
redef LogAscii::use_json=T;

# Ignores checksum check
redef ignore_checksums=T;

# =============================== Logic to detect gRPC over HTTP2 and request file analysis

# export {
# 	type ProtobufInfo: record 
#     {
# 		is_gRPC: bool &optional;
#         is_orig: bool &optional;
# 	};
# }


# redef record HTTP2::Info += {
#     protobufinfo:          ProtobufInfo  &optional;
# };

# redef record fa_file += {
#     protobufinfo:          ProtobufInfo  &optional;
# };

# function init_protobuf_info(c: connection)
# {
#     if ( ! ( c?$http2 && c$http2?$protobufinfo ) )
#     {
#         print "c.http2.protobufinfo is not defined";
#         c$http2$protobufinfo = ProtobufInfo();
#         c$http2$protobufinfo$is_gRPC = F;
#     }
# }

# event http2_request(c: connection, is_orig: bool, stream: count, method: string, authority: string, host: string, original_URI: string, unescaped_URI: string, version: string, push: bool)
# {
#     print "[http2_request]";
#     # print "    original_URI", original_URI;
#     # print "    method", method;
#     # print "    authority", authority;
#     # print "    host", host;
#     # print "    original_URI", original_URI;
#     # print "    unescaped_URI", unescaped_URI;
#     # print "    version", version;
#     # print "    push", push;
#     #c$http2$protobufinfo = ProtobufInfo();
# }

# event http2_header(c: connection, is_orig: bool, stream: count, name: string, value: string) &priority=3
# {
#     local is_grpc : bool = ( name == "CONTENT-TYPE" && value == "application/grpc" );

#     print "[http2_header_event]";
#     # print "    name", name;
#     # print "    value", value;
#     # print "    is_orig: ", is_orig;
#     # print "    is_grpc: ", is_grpc;

#     if( is_grpc )
#     {
#         print "    is_grpc: ", is_grpc;
#         print "    name", name;
#         print "    value", value;
#     }
    
#     init_protobuf_info(c);
#     c$http2$protobufinfo$is_gRPC = c$http2$protobufinfo$is_gRPC || is_grpc;
#     if( is_grpc )
#     {
#         print "    Updating c.http2.protobufinfo.is_gRPC to", c$http2$protobufinfo$is_gRPC;
#     }

# }

# event http2_begin_entity(c: connection, is_orig: bool, stream: count, contentType: string) &priority=10
# {
#     print "[http2_begin_entity]";
#     # print "    is_orig", is_orig;
#     # print "    http2", c$http2;

#     # c$http2$protobufinfo = ProtobufInfo();
#     # c$http2$protobufinfo$is_gRPC = F;
#     # c$http2$protobufinfo$is_orig = is_orig;
# }

# event file_over_new_connection(f: fa_file, c: connection, is_orig: bool) &priority=5
# {
#     # print "[file_over_new_connection]";

#     if ( c?$http2 && c$http2?$protobufinfo )
#     {
#         f$protobufinfo = c$http2$protobufinfo;
#     }else{
#         init_protobuf_info(c);
#         print " no connection info on file_over_new_connection";
#     }
#     # f$protobufinfo = c$http2$protobufinfo;

# }

# event file_sniff(f: fa_file, meta: fa_metadata) &priority=5
# {
#     # print "[file_sniff]";
#     # print "f.protobufinfo", f$protobufinfo;
#     Files::add_analyzer(f, Files::ANALYZER_PROTOBUF);

#     if (f?$protobufinfo 
#         && f$protobufinfo?$is_gRPC 
#         && f$protobufinfo$is_gRPC == T )
#     {
#         # print "PROTO FILE DETECTED!! Calling ANALYZER_PROTOBUF";
#         # Files::add_analyzer(f, Files::ANALYZER_PROTOBUF);
#     }
# }

# event http2_end_entity(c: connection, is_orig: bool, stream: count) &priority=5
# {
#     # print "[http2_end_entity]";

# 	if ( c?$http2 && c$http2?$protobufinfo )
#     {
# 		delete c$protobuf_mime_typeshttp2$protobufinfo;
# 	}
# }


# ===================================

export {
	type ProtoInfo: record 
    {
		is_protobuf: bool &optional;
        stream: count &optional;
        is_orig: bool &optional;
	};
}

redef record HTTP2::Info += {
    proto:          ProtoInfo  &optional;
};

redef record fa_file += {
    proto:          ProtoInfo  &optional;
};

const protobuf_mime_types = { 
    
    # https://developers.cloudflare.com/support/speed/optimization-file-size/what-will-cloudflare-compress/
    "application/x-protobuf",
    # https://groups.google.com/g/protobuf/c/VAoJ-HtgpAI
    "application/vnd.google.protobuf",
    # https://datatracker.ietf.org/doc/html/draft-rfernando-protocol-buffers-00
    "application/protobuf",
    # https://stackoverflow.com/questions/30505408/what-is-the-correct-protobuf-content-type
    "application/octet-stream",
    # https://github.com/grpc/grpc/blob/master/doc/PROTOCOL-WEB.md
    "application/grpc",
    "application/grpc+proto",
    "application/grpc+json",
    "application/grpc+proto+json",
    "application/grpc-web",
    "application/grpc-web+proto",
    "application/grpc-web+json",
    "application/grpc-web+proto+json",
    "application/grpc-web-text",
    "application/grpc-web-text+proto",
    "application/grpc-web-text+json",
    "application/grpc-web-text+proto+json",
    "application/grpc-web+proto",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto",
    "application/grpc-web+proto+json",
    "application/grpc-web+proto+json",
    # NOTE: This is not a valid mime type, but it is used in replies from the server
    "text/plain"
 };


event http2_content_type(c: connection, is_orig: bool, stream: count, contentType: string)
{
    print "[http2_content_type]";
    print "    contentType", contentType;
    print "    is_orig", is_orig;
    print "    stream", stream;
    
    if ( contentType in protobuf_mime_types) 
    {
        print "    contentType is protobuf: ", contentType;
        c$http2$proto = ProtoInfo();
        c$http2$proto$is_protobuf = T;
        c$http2$proto$stream = stream;
        c$http2$proto$is_orig = is_orig;
    }
}

event file_over_new_connection(f: fa_file, c: connection, is_orig: bool) &priority=5
{
    print "[file_over_new_connection]";
    if ( c?$http2 )
    {
        if ( c$http2?$proto )
        {
            f$proto = c$http2$proto;
        }else{
            print "    no proto info on http2 connection";
        }
    }else{
        print "    no http2 info on connection";
    }

}

event file_sniff(f: fa_file, meta: fa_metadata) &priority=5
{
    print "[file_sniff]";
    Files::add_analyzer(f, Files::ANALYZER_PROTOBUF);

    if (f?$proto)
    {
        if (f$proto?$is_protobuf
            && f$proto$is_protobuf == T)
        {
            # print "PROTO FILE DETECTED!! Calling ANALYZER_PROTOBUF";
            Files::add_analyzer(f, Files::ANALYZER_PROTOBUF);
        }else{
            print "    proto info is not protobuf or is_protobuf is false";
        }

    }else {
        print "    no proto info on file";
    }
}

# =============================== Handling gRPC text event
event protobuf_string(f: fa_file, text: string)
{
    print "[protobuf_string]";
    print "    text", text;
    print "text", text;
    local result_is_sql_injection = is_sql_injection(text, |text|);
    print "is_sql_injection", result_is_sql_injection;

}