# RX Data Write System Test
# For Mode 0, accurate mode
# Rick Fenster
# Written on Jan 31/2021
# Purpose is to test RX writing across multiple modes

# Compile all VHDL files
vcom ../thesis-code/thesis-test-code/src/Shared/*.vhd
vcom ../thesis-code/thesis-test-code/src/RX/*.vhd
vcom ../thesis-code/thesis-test-code/src/Tests/ni_rx_test_data_write.vhd

# Start Sim
vsim work.ni_rx_test_data_write

# Create work area
add wave -divider "Clock and System Control"
add wave -position end  -label Clock sim:/ni_rx_test_data_write/clk
# Make clock repeat after 100ns, 50% DC
force -freeze sim:/ni_rx_test_data_write/clk 1 0, 0 {50 ps} -r 100
add wave -position end  -label Reset sim:/ni_rx_test_data_write/rst
# Set reset to 0
force -freeze sim:/ni_rx_test_data_write/rst 0 0
add wave -position end  -label "Network Mode" sim:/ni_rx_test_data_write/networkMode
force -freeze sim:/ni_rx_test_data_write/networkMode 0 0
# Data Inputs
add wave -divider "Data Inputs"
add wave -position end  -radix hex -label "Data In A" sim:/ni_rx_test_data_write/dataInA
add wave -position end -label "Address In A" sim:/ni_rx_test_data_write/addrA
add wave -position end -label "Channel A Valid" sim:/ni_rx_test_data_write/channelAValid
add wave -position end  -radix hex -label "Data In B" sim:/ni_rx_test_data_write/dataInB
add wave -position end -label "Address In B" sim:/ni_rx_test_data_write/addrB
add wave -position end -label "Channel B Valid" sim:/ni_rx_test_data_write/channelBValid
# FSMs
add wave -divider "Channel A FSM"
add wave -position end  -label "Channel A FSM State" sim:/ni_rx_test_data_write/write_fsm_a/fsm_state
add wave -position end  -label "Channel A FSM Next State" sim:/ni_rx_test_data_write/write_fsm_a/fsm_state_next
add wave -position end  -label "Channel A Clear to Send" sim:/ni_rx_test_data_write/ctsChannelA
add wave -position end  -label "Channel A Write Enable" sim:/ni_rx_test_data_write/fifoA_writeEn_i
add wave -divider "Channel B FSM"
add wave -position end  -label "Channel B FSM State" sim:/ni_rx_test_data_write/write_fsm_b/fsm_state
add wave -position end  -label "Channel B FSM Next State" sim:/ni_rx_test_data_write/write_fsm_b/fsm_state_next
add wave -position end  -label "Channel B Clear to Send" sim:/ni_rx_test_data_write/ctsChannelB
add wave -position end  -label "Channel B Write Enable" sim:/ni_rx_test_data_write/fifoB_writeEn_i
# FIFOs
add wave -divider "Channel A FIFOs"
add wave -position end  -label "Data A FIFO" -radix hex sim:/ni_rx_test_data_write/data_fifo_a/fifo
add wave -position end  -label "Data A Counter" sim:/ni_rx_test_data_write/data_fifo_a/fifoCounter
add wave -position end  -label "Address A FIFO" -radix hex sim:/ni_rx_test_data_write/addr_fifo_a/fifo
add wave -position end  -label "Address A Counter" sim:/ni_rx_test_data_write/addr_fifo_a/fifoCounter
add wave -position end  -label "Channel A Full" sim:/ni_rx_test_data_write/fifoA_full_i
add wave -position end  -label "Channel A Pop Enable" sim:/ni_rx_test_data_write/popEnA
add wave -divider "Channel B FIFOs"
add wave -position end  -label "Data B FIFO" -radix hex sim:/ni_rx_test_data_write/data_fifo_b/fifo
add wave -position end  -label "Data B Counter" sim:/ni_rx_test_data_write/data_fifo_b/fifoCounter
add wave -position end  -label "Address B FIFO" -radix hex sim:/ni_rx_test_data_write/addr_fifo_b/fifo
add wave -position end  -label "Address B Counter" sim:/ni_rx_test_data_write/addr_fifo_b/fifoCounter
add wave -position end  -label "Channel B Full" sim:/ni_rx_test_data_write/fifoB_full_i
add wave -position end  -label "Channel B Pop Enable" sim:/ni_rx_test_data_write/popEnB


# Start tests
# Enable write
# Task 1 Populate FIFOs
force popEnA 0
force popEnB 0
force channelAValid 1
force channelBValid 1
force dataInA 16#dead
force dataInB 16#beef
force addra 010101
force addrb 010101
run 100
force dataInA 16#0def
force dataInB 16#aced
force addra 111111
force addrb 111111
run 100
force dataInA 16#cafe
force dataInB 16#d00d
force addra 000011
force addrb 000011
run 100
force dataInA 16#feed
force dataInB 16#c0de
force addra 110011
force addrb 110011
run 100
# Task 2 Write on Full
force dataInA 16#ffff
force dataInB 16#ffff
force addra 111111
force addrb 111111
run 100
# Task 3 Pop All
force channelAValid 0
force channelBValid 0
force popEnA 1
force popEnB 1
run 500
# Task 4 Fill FIFOs Entirely (again)
force channelAValid 1
force channelBValid 1
force popEnA 0
force popEnB 0
force dataInA 16#0001
force dataInB 16#0001
force addra 000000
force addrb 000000
run 100
force dataInA 16#0002
force dataInB 16#0002
force addra 101101
force addrb 101101
run 100
force dataInA 16#0003
force dataInB 16#0003
force addra 000011
force addrb 000011
run 100
force dataInA 16#0004
force dataInB 16#0004
force addra 111111
force addrb 111111
run 100
# Pop and write at same time
force popEnA 1
force popEnB 1
force dataInA 16#ffff
force dataInB 16#ffff
force addra 000000
force addrb 000000
run 100