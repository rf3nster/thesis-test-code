# Create testing environment for RX-TX Point to Point testing
# Mode 1
# Rick Fenster, last updated on Feb 5/2021

# Compile all files
#vcom ../thesis-code/thesis-test-code/src/RX/*.vhd
#vcom ../thesis-code/thesis-test-code/src/RX/*.vhd
#vcom ../thesis-code/thesis-test-code/src/Shared/*.vhd
#vcom ../thesis-code/thesis-test-code/src/Tests/ni_tx_rx_single_point_test.vhd
# Start simulation
vsim work.ni_rx_tx_test 
# Create work area
###### System Properties ###### 
add wave -divider "System Properties"
add wave -position end  -label "Address Bit Size" sim:/ni_rx_tx_test/addressWidth
add wave -position end  -label "FIFO Width" sim:/ni_rx_tx_test/fifoWidth
add wave -position end  -label "FIFO Depth" sim:/ni_rx_tx_test/fifoDepth
###### Clock and system control ###### 
add wave -divider "Clock and System Control"
add wave -position end  -label Clock sim:/ni_rx_tx_test/clk
# Make clock repeat after 100ns, 50% DC
force -freeze sim:/ni_rx_tx_test/clk 1 0, 0 {50 ps} -r 100
add wave -position end  -label Reset sim:/ni_rx_tx_test/rst
# Set reset to 0
force -freeze sim:/ni_rx_tx_test/rst 0 0
add wave -position end  -label "Network Mode" sim:/ni_rx_tx_test/networkMode
force networkMode 1
# Transceiver
add wave -divider "Transceiver Properties"
add wave -position end  -radix hex -label "Data In" sim:/ni_rx_tx_test/dataIn
add wave -position end  -radix hex -label "Address In" sim:/ni_rx_tx_test/addrIn
add wave -position end  -label "Write Approximate" sim:/ni_rx_tx_test/writeApxEn
add wave -position end  -label "Write Accurate" sim:/ni_rx_tx_test/writeAccEn
add wave -position end  -label "Accurate Buffer Full" sim:/ni_rx_tx_test/accFIFOFull
add wave -position end  -label "Accurate Buffer Empty" sim:/ni_rx_tx_test/ni_tx/FIFO_data_A/fifoEmpty
add wave -position end  -label "FIFO A Data" -radix hex sim:/ni_rx_tx_test/ni_tx/FIFO_data_A/fifo
add wave -position end  -label "FIFO A Address" -radix hex sim:/ni_rx_tx_test/ni_tx/FIFO_addr_A/fifo
add wave -position end  -label "FIFO A Data Counter" -radix hex sim:/ni_rx_tx_test/ni_tx/FIFO_data_A/fifocounter
add wave -position end  -label "Channel A Address FIFO Counter" sim:/ni_rx_tx_test/ni_tx/FIFO_addr_A/fifoCounter
add wave -position end  -label "FIFO B Data" -radix hex sim:/ni_rx_tx_test/ni_tx/FIFO_data_B/fifo
add wave -position end  -label "FIFO B Address" -radix hex sim:/ni_rx_tx_test/ni_tx/FIFO_addr_B/fifo
add wave -position end  -label "FIFO B Data Counter" -radix hex sim:/ni_rx_tx_test/ni_tx/FIFO_data_B/fifocounter
add wave -position end  -label "Channel B Address FIFO Counter" sim:/ni_rx_tx_test/ni_tx/FIFO_addr_B/fifoCounter
add wave -position end  -label "Acc Write FSM" sim:/ni_rx_tx_test/ni_tx/FSM_ACC/fifo_state



# Link
add wave -divider "Link Properties"
add wave -position end  -radix hex -label "Channel A Address" sim:/ni_rx_tx_test/addrA
add wave -position end  -radix hex -label "Channel B Address" sim:/ni_rx_tx_test/addrB
add wave -position end  -radix hex -label "Channel A Data" sim:/ni_rx_tx_test/dataChannelA
add wave -position end  -radix hex -label "Channel B Data" sim:/ni_rx_tx_test/dataChannelB
add wave -position end  sim:/ni_rx_tx_test/channelAValid
add wave -position end  sim:/ni_rx_tx_test/channelBValid
add wave -position end  sim:/ni_rx_tx_test/ctsChannelA
add wave -position end  sim:/ni_rx_tx_test/ctsChannelB

# Receiver
add wave -divider "Receiver Properties"
add wave -position end  -label "Data Available" sim:/ni_rx_tx_test/dataAvailable
add wave -position end  -label "Data Request" sim:/ni_rx_tx_test/dataRqst
force dataRqst 0
add wave -position end  -label "Data Type" sim:/ni_rx_tx_test/dataType
add wave -position end  -label "Data Valid" sim:/ni_rx_tx_test/dataValid
add wave -position end  -label "Data Origin" -radix hex sim:/ni_rx_tx_test/dataOrigin
add wave -position end  -label "Data Out" -radix hex sim:/ni_rx_tx_test/dataOut
add wave -position end  -label "FIFO A Data" -radix hex sim:/ni_rx_tx_test/ni_rx/data_FIFO_A/fifo
add wave -position end  -label "FIFO A Address" -radix hex sim:/ni_rx_tx_test/ni_rx/addr_FIFO_A/fifo
add wave -position end  -label "FIFO A Counter" -radix hex sim:/ni_rx_tx_test/ni_rx/data_FIFO_A/fifocounter
add wave -position end  -label "FIFO B Data" -radix hex sim:/ni_rx_tx_test/ni_rx/data_FIFO_B/fifo
add wave -position end  -label "FIFO B Address" -radix hex sim:/ni_rx_tx_test/ni_rx/addr_FIFO_B/fifo
add wave -position end  -label "FIFO B Counter" -radix hex sim:/ni_rx_tx_test/ni_rx/data_FIFO_B/fifocounter
add wave -position end  -label "Receiver Write State" sim:/ni_rx_tx_test/ni_rx/rx_write_chanA_fsm/fsm_state
add wave -position end  -label "Receiver Pop State" sim:/ni_rx_tx_test/ni_rx/rx_read_fsm/fsm_state
add wave -position end  sim:/ni_rx_tx_test/ni_rx/dataFIFO_B_out_i
add wave -position end  sim:/ni_rx_tx_test/ni_rx/FIFO_B_writeEn_i
add wave -position end  sim:/ni_rx_tx_test/ni_rx/FIFO_B_writeEn_postmux_i
add wave -position end  sim:/ni_rx_tx_test/ni_rx/dataInB
add wave -position end  sim:/ni_rx_tx_test/ni_tx/dataOutB


# ACC Solo Testing
# Fill RX channel ACC
force datarqst 0
force writeAccEn 1
force writeApxEn 0
force addrIn 16#02
force dataIn 16#DEADBEEF
run 100
force addrIn 16#03
force dataIn 16#DECAFBAD
run 100
force writeAccEn 0
run 200
# Pop out data
force dataRqst 1
run 400
force dataRqst 0
run 100

# Write out one packet
force writeAccEn 1
force addrIn 16#04
force dataIn 16#FFFFFFFF
run 100
force writeAccEn 0
run 400

# Mixed tests
force writeApxEn 1
force dataIn 16#4444
force addrIn 16#10
run 300
force writeAccEn 0
force writeApxEn 0
force dataRqst 1
run 400