.PHONY: proto
TARGET=./libs/common/src/types
gen-proto:
	@protoc --plugin=node_modules/ts-proto/protoc-gen-ts_proto \
		-I=./proto \
		--ts_proto_out=${TARGET} \
		--ts_proto_opt=nestJs=true \
		--ts_proto_opt=fileSuffix=.pb \
		./proto/auth.proto --experimental_allow_proto3_optional