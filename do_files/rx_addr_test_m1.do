# RX Addressing System Test
# For Mode 1, mixed mode
# Rick Fenster
# Written on Jan 30/2021
# Purpose is to test RX addressing mechanism

# Compile all VHDL files
vcom ../thesis-code/thesis-test-code/src/Shared/*.vhd
vcom ../thesis-code/thesis-test-code/src/RX/*.vhd
vcom ../thesis-code/thesis-test-code/src/Tests/ni_rx_test_addr.vhd

# Start Sim
vsim work.ni_rx_test_addr 

# Create work area
add wave -divider "Clock and System Control"
add wave -position end  -label Clock sim:/ni_rx_test_addr/clk
# Make clock repeat after 100ns, 50% DC
force -freeze sim:/ni_rx_test_addr/clk 1 0, 0 {50 ps} -r 100
add wave -position end  -label Reset sim:/ni_rx_test_addr/rst
# Set reset to 0
force -freeze sim:/ni_rx_test_addr/rst 0 0
add wave -position end  -label "Network Mode" sim:/ni_rx_test_addr/networkMode
force sim:/ni_rx_test_addr/networkMode 1
add wave -position end  -label "Pop Request" sim:/ni_rx_test_addr/popRqst

add wave -divider "FSM"
add wave -position end  -label "FSM Current State" sim:/ni_rx_test_addr/rx_read_fsm/fsm_state
add wave -position end  -label "FSM Next State" sim:/ni_rx_test_addr/rx_read_fsm/fsm_state_next

add wave -divider "Channel A"
add wave -position end  -label "Address A In" -radix hex sim:/ni_rx_test_addr/addrA
add wave -position end  -label "Channel A Write Enable" sim:/ni_rx_test_addr/channelA_WriteEn
add wave -position end  -label "Channel A Pop Enable" sim:/ni_rx_test_addr/channelA_popEn_i
add wave -position end  -label "FIFO Contents" -radix hex sim:/ni_rx_test_addr/addrA_FIFO/fifo
add wave -position end  -label "FIFO Empty" sim:/ni_rx_test_addr/addrA_FIFO/fifoEmpty
add wave -position end  -label "FIFO Full" sim:/ni_rx_test_addr/addrA_FIFO/fifoFull

add wave -divider "Channel B"
add wave -position end  -label "Address B In" -radix hex sim:/ni_rx_test_addr/addrB
add wave -position end  -label "Channel B Write Enable" sim:/ni_rx_test_addr/channelB_WriteEn
add wave -position end  -label "Channel B Pop Enable" sim:/ni_rx_test_addr/channelB_popEn_i
add wave -position end  -label "FIFO Contents" -radix hex sim:/ni_rx_test_addr/addrB_FIFO/fifo
add wave -position end  -label "FIFO Empty" sim:/ni_rx_test_addr/addrB_FIFO/fifoEmpty
add wave -position end  -label "FIFO Full" sim:/ni_rx_test_addr/addrB_FIFO/fifoFull

add wave -divider "Status and Output"
add wave -position end  -label "Data Origin Address" -radix hex sim:/ni_rx_test_addr/dataOrigin
add wave -position end  -label "Data Available" -radix hex sim:/ni_rx_test_addr/dataAvailable
add wave -position end  -label "Data Type" sim:/ni_rx_test_addr/dataType
add wave -position end  -label "Data Valid" sim:/ni_rx_test_addr/dataValid


# Start Tests
# Pop Request on empty
force sim:/ni_rx_test_addr/addrA 000000
force sim:/ni_rx_test_addr/addrB 000000
force sim:/ni_rx_test_addr/channelA_WriteEn 0
force sim:/ni_rx_test_addr/channelB_WriteEn 0
force sim:/ni_rx_test_addr/popRqst 1
run 100

# Disable Pop Request and fill accurate addr FIFO
force sim:/ni_rx_test_addr/addrA 111000
force sim:/ni_rx_test_addr/channelA_WriteEn 1
force sim:/ni_rx_test_addr/popRqst 0
run 200
force sim:/ni_rx_test_addr/addrA 001100
run 300
# Pop out all of addr A
force sim:/ni_rx_test_addr/channelA_WriteEn 0
force sim:/ni_rx_test_addr/popRqst 1
run 400

# Fill apx addr FIFO
force sim:/ni_rx_test_addr/channelB_WriteEn 1
force sim:/ni_rx_test_addr/popRqst 0
force sim:/ni_rx_test_addr/addrb 110000
run 100
force sim:/ni_rx_test_addr/addrb 010101
run 100
force sim:/ni_rx_test_addr/addrb 001111
run 100
force sim:/ni_rx_test_addr/addrb 000001
run 100
# Pop out all of addr B
force sim:/ni_rx_test_addr/channelB_WriteEn 0
force sim:/ni_rx_test_addr/popRqst 1
run 500

# Fill both addr FIFOs
force sim:/ni_rx_test_addr/popRqst 0
force sim:/ni_rx_test_addr/channelA_WriteEn 1
force sim:/ni_rx_test_addr/addrA 111000
force sim:/ni_rx_test_addr/channelB_WriteEn 1
force sim:/ni_rx_test_addr/addrB 000111
run 500

# Check for alternating pops, starting with APX
force sim:/ni_rx_test_addr/popRqst 1
force sim:/ni_rx_test_addr/channelA_WriteEn 0
force sim:/ni_rx_test_addr/channelB_WriteEn 0
run 1000

# Fill Addr A FIFO
force sim:/ni_rx_test_addr/popRqst 0
force sim:/ni_rx_test_addr/channelA_WriteEn 1
force sim:/ni_rx_test_addr/addrA 111111
run 400

# Start pop
force sim:/ni_rx_test_addr/popRqst 1
force sim:/ni_rx_test_addr/channelA_WriteEn 0
force sim:/ni_rx_test_addr/channelB_WriteEn 1
force sim:/ni_rx_test_addr/addrB 111000
run 100
force sim:/ni_rx_test_addr/channelB_WriteEn 0
run 200

# Fill Addr B FIFO
force sim:/ni_rx_test_addr/popRqst 0
force sim:/ni_rx_test_addr/channelB_WriteEn 1
force sim:/ni_rx_test_addr/addrB 101010
run 400
# Start pop and write Addr A
force sim:/ni_rx_test_addr/popRqst 1
force sim:/ni_rx_test_addr/channelB_WriteEn 0
force sim:/ni_rx_test_addr/channelA_WriteEn 1
force sim:/ni_rx_test_addr/addrB 111111
run 200
force sim:/ni_rx_test_addr/channelA_WriteEn 0
run 400