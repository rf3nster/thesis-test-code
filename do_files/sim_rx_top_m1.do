# Create testing environment for RX Top, Mode 1
# Mode 1
# Rick Fenster, last updated on Feb 3/2021

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
force networkMode 1
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
###### FSMs #####
add wave -position end  -label "Read FSM Current State" sim:/ni_rx_top/rx_read_fsm/fsm_state
add wave -position end  -label "Read FSM Next State" sim:/ni_rx_top/rx_read_fsm/fsm_state_next

add wave -position end  sim:/ni_rx_top/dataFIFO_B_out_i
add wave -position end  sim:/ni_rx_top/addrFIFO_B_out_i

# Task 1 Set initial condition to mode 1 and send one accurate data packet
force dataRqst 0
force channelAValid 1
force channelBValid 0
force dataInA 16#DEAD
force addrA 16#3F
run 100
force channelAValid 1
force dataInA 16#BEEF
force addrA 16#3F
run 100
force channelAValid 0
run 100
# Task 2 Pop Received packet
force dataRqst 1
run 100
force dataRqst 0
run 100

# Task 3 send one apx packet
force dataRqst 0
force channelBValid 1
force dataInB 16#FFFF
force addrB 16#3F
run 100
force channelBValid 0
run 100

# Task 4 Pop apx packet
force dataRqst 1
run 200
force dataRqst 0

# Task 5 Fill both channels and empty
force channelAValid 1
force channelBValid 0
force dataInA 16#0000
force addrA 16#3F
run 100
force channelAValid 1
force channelBValid 0
force dataInA 16#1111
force addrA 16#3F
run 100
force channelAValid 1
force channelBValid 0
force dataInA 16#2222
force addrA 16#3F
run 100
force channelAValid 1
force channelBValid 0
force dataInA 16#3333
force addrA 16#3F
run 100
force channelAValid 1
force channelBValid 0
force dataInA 16#4444
force addrA 16#3F
run 100

force channelAValid 0
force channelBValid 1
force dataInB 16#AAAA
force addrB 16#22
run 100
force channelAValid 0
force channelBValid 1
force dataInB 16#BBBB
force addrB 16#22
run 100
force channelAValid 0
force channelBValid 1
force dataInB 16#CCCC
force addrB 16#22
run 100
force channelAValid 0
force channelBValid 1
force dataInB 16#DDDD
force addrB 16#22
run 100

force channelBValid 0
run 100
force dataRqst 1
run 800
force dataRqst 0

# Task 6 Write while popping, ACC mode
force channelAValid 1
force dataInA 16#DECA
force addrA 16#66
run 100
force dataInA 16#FBAD
force addrA 16#66
run 100
force dataRqst 1
force channelAValid 1
force dataInA 16#DEAD
force addrA 16#77
run 100
force dataInA 16#BEEF
force addrA 16#77
run 100
# Task 7 Empty ACC channel
force channelAValid 0
force dataRqst 0
run 200
