# Create testing environment for RX Top
# Rick Fenster, Jan 30/2021

# Compile all files
vcom ../thesis-code/thesis-test-code/src/TX/*.vhd
vcom ../thesis-code/thesis-test-code/src/Shared/*.vhd
# Start simulation
vsim work.ni_rx_top 
# Create work area
###### System Properties ###### 
add wave -divider "System Properties"
add wave -position end  -label "Address Bit Size" sim:/ni_rx_top/addressWidth
add wave -position end  -label "FIFO Width" sim:/ni_rx_top/fifoWidth
add wave -position end  -label "FIFO Depth" sim:/ni_rx_top/fifoDepth
###### Clock and system control ###### 
add wave -divider "Clock and System Control"
add wave -position end  -label Clock sim:/ni_rx_top/clk
# Make clock repeat after 100ns, 50% DC
force -freeze sim:/ni_rx_top/clk 1 0, 0 {50 ps} -r 100
add wave -position end  -label Reset sim:/ni_rx_top/rst
# Set reset to 0
force -freeze sim:/ni_rx_top/rst 0 0
add wave -position end  -label "Network Mode" sim:/ni_rx_top/networkMode
###### Data Flow In ###### 
add wave -divider "Data In A"
add wave -position end  -label "Data Channel A" -radix hex sim:/ni_rx_top/dataInA
add wave -position end  -label "Address for Channel A" sim:/ni_rx_top/addrA
add wave -position end  -label "Clear to Send Channel A" sim:/ni_rx_top/ctsChannelA
add wave -position end  -label "Channel A Valid" sim:/ni_rx_top/channelAValid
add wave -divider "Data In B"
add wave -position end  -label "Data Channel B" -radix hex sim:/ni_rx_top/dataInB
add wave -position end  -label "Address for Channel B" sim:/ni_rx_top/addrB
add wave -position end  -label "Clear to Send Channel B" sim:/ni_rx_top/ctsChannelB
add wave -position end  -label "Channel B Valid" sim:/ni_rx_top/channelBValid
###### Data Flow Out ###### 
add wave -divider "Data Out"
add wave -position end  -label "Data Available" sim:/ni_rx_top/dataAvailable
add wave -position end  -label "Data Requested" sim:/ni_rx_top/dataRqst
add wave -position end  -label "Data Out" -radix hex sim:/ni_rx_top/dataOut
add wave -position end  -label "Data Origin" sim:/ni_rx_top/dataOrigin
add wave -position end  -label "Data Valid" sim:/ni_rx_top/dataValid
add wave -position end  -label "Data Type" sim:/ni_rx_top/dataType