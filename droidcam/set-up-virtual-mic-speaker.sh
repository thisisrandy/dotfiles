#!/bin/bash

pactl load-module module-null-sink sink_name=VirtualSpeaker sink_properties=device.description=VirtualSpeaker
pactl load-module module-virtual-source source_name=VirtualMic master=VirtualSpeaker.monitor
