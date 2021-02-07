# Create testing environment for TX Channel 
# Rick Fenster, last updated on Feb 5/2021

# Compile files
#vcom ../thesis-code/thesis-test-code/src/Tests/ni_test_tx_channel.vhd
# Start simulation
vsim work.ni_test_tx_channel 
# Create work area
###### Clock and system control ###### 
add wave -divider "Clock and System Control"
add wave -position end  -label Clock sim:/ni_test_tx_channel/clk
# Make clock repeat after 100ns, 50% DC
force -freeze sim:/ni_test_tx_channel/clk 1 0, 0 {50 ps} -r 100
add wave -position end  -label Reset sim:/ni_test_tx_channel/rst
# Set reset to 0
force -freeze sim:/ni_test_tx_channel/rst 0 0
add wave -position end  -label "FIFO Write Request" sim:/ni_test_tx_channel/fifoWriteRqst
add wave -position end  -label "Channel Clear to Send" sim:/ni_test_tx_channel/clearToSend
add wave -label "Data In" -radix hex sim:/ni_test_tx_channel/dataIn
add wave -divider "Control Signals"
add wave -position end  sim:/ni_test_tx_channel/fifoFull_i
add wave -position end  sim:/ni_test_tx_channel/fifoEmpty_i
add wave -position end  sim:/ni_test_tx_channel/fifoPopEn_i
add wave -position end  sim:/ni_test_tx_channel/fifoWriteEn_i
add wave -divider "Channel Outputs"
add wave -position end  -label "Channel Valid" sim:/ni_test_tx_channel/channelValid
add wave -label "Data Out" -radix hex sim:/ni_test_tx_channel/dataOut
