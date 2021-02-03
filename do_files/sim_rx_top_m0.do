# Create testing environment for RX Top
# Mode 0
# Rick Fenster, Jan 30/2021

# Compile all files
vcom ../thesis-code/thesis-test-code/src/RX/*.vhd
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
force networkMode 0
###### Data Flow In ###### 
add wave -divider "Channel A"
add wave -position end  -label "Data Input" -radix hex sim:/ni_rx_top/dataInA
add wave -position end  -label "Address Input" sim:/ni_rx_top/addrA
add wave -position end  -label "Data FIFO" -radix hex sim:/ni_rx_top/data_FIFO_A/fifo
add wave -position end  -label "Address FIFO" -radix hex sim:/ni_rx_top/addr_FIFO_A/fifo
add wave -position end  -label "Clear to Send" sim:/ni_rx_top/ctsChannelA
add wave -position end  -label "Channel Valid" sim:/ni_rx_top/channelAValid
add wave -position end  -label "FIFO Empty" sim:/ni_rx_top/data_FIFO_A/fifoEmpty
add wave -position end  -label "FIFO Full" sim:/ni_rx_top/data_FIFO_A/fifoFull
add wave -position end  -label "FIFO Pop Enable" sim:/ni_rx_top/FIFO_A_popEn_i
add wave -position end  -label "FIFO Write Enable" sim:/ni_rx_top/FIFO_A_writeEn_i

add wave -divider "Channel B"
add wave -position end  -label "Data Channel B" -radix hex sim:/ni_rx_top/dataInB
add wave -position end  -label "Address for Channel B" sim:/ni_rx_top/addrB
add wave -position end  -label "Data FIFO" -radix hex sim:/ni_rx_top/data_FIFO_B/fifo
add wave -position end  -label "Address FIFO" -radix hex sim:/ni_rx_top/addr_FIFO_B/fifo
add wave -position end  -label "Clear to Send Channel B" sim:/ni_rx_top/ctsChannelB
add wave -position end  -label "Channel B Valid" sim:/ni_rx_top/channelBValid
add wave -position end  -label "FIFO Empty" sim:/ni_rx_top/data_FIFO_B/fifoEmpty
add wave -position end  -label "FIFO Full" sim:/ni_rx_top/data_FIFO_B/fifoFull
add wave -position end  -label "FIFO Pop Enable" sim:/ni_rx_top/FIFO_B_popEn_i
add wave -position end  -label "FIFO Write Enable" sim:/ni_rx_top/FIFO_B_writeEn_postmux_i
###### Data Flow Out ###### 
add wave -divider "Data Out"
add wave -position end  -label "Data Available" sim:/ni_rx_top/dataAvailable
add wave -position end  -label "Data Requested" sim:/ni_rx_top/dataRqst
add wave -position end  -label "Data Out" -radix hex sim:/ni_rx_top/dataOut
add wave -position end  -label "Data Origin" sim:/ni_rx_top/dataOrigin
add wave -position end  -label "Data Valid" sim:/ni_rx_top/dataValid
add wave -position end  -label "Data Type" sim:/ni_rx_top/dataType

# Task 1 Set initial condition to mode 0 and send one chunk of dataInA
force dataRqst 0
force channelAValid 1
force channelBValid 1
force dataInA 16#DEAD
force dataInB 16#BEEF
force addrA 16#3F
force addrB 16#3F
run 100

# Push Out
force channelAValid 0
force channelBValid 0
run 100
force dataRqst 1
run 100

# Task 2: Fill receiver and pop everything
force dataRqst 0
force channelAValid 1
force channelBValid 1
force dataInA 16#C0DE
force dataInB 16#BAAD
force addrA 16#AF
force addrB 16#AF
run 100
force dataInA 16#1234
force dataInB 16#5678
force addrA 16#11
force addrB 16#11
run 100
force dataInA 16#ABCD
force dataInB 16#0123
force addrA 16#22
force addrB 16#22
run 100
force dataInA 16#8BAD
force dataInB 16#F00D
force addrA 16#33
force addrB 16#33
run 100
force dataInA 16#FEED
force dataInB 16#C0DE
force addrA 16#44
force addrB 16#44
run 100
force channelAValid 0
force channelBValid 0
force dataRqst 1
run 500

# Write on empty, requesting data
force channelAValid 1
force channelBValid 1
force dataInA 16#FFFF
force dataInB 16#FFFF
force addrA 16#FF
force addrB 16#FF
run 100
force dataInA 16#0101
force dataInB 16#0101
force addrA 16#01
force addrB 16#01
run 100

