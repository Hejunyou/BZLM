#!/bin/sh

PTC="protoc"
FMS="YunCaiBao/Models"

$PTC --proto_path=$FMS --objc_out=$FMS $FMS/YunCaiBaoConfig.proto