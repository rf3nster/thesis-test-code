# Create testing environment for TX FSM
# Rick Fenster, last updated on Feb 5/2021

# Compile files
#vcom ../thesis-code/thesis-test-code/src/TX/ni_tx_fsm.vhd
# Start simulation
vsim work.ni_tx_fsm 
# Create work area
###### Clock and system control ###### 
add wave -divider "Clock and System Control"
add wave -position end  -label Clock sim:/ni_tx_fsm/clk
# Make clock repeat after 100ns, 50% DC
force -freeze sim:/ni_tx_fsm/clk 1 0, 0 {50 ps} -r 100
add wave -position end  -label Reset sim:/ni_tx_fsm/rst
# Set reset to 0
force -freeze sim:/ni_tx_fsm/rst 0 0
###### FIFO Status ###### 
add wave -divider "FIFO Status"
add wave -position end  -label "FIFO Full" sim:/ni_tx_fsm/fifoFull
add wave -position end  -label "FIFO Empty" sim:/ni_tx_fsm/fifoEmpty
###### Write Control ###### 
add wave -divider "FIFO Write Control"
add wave -position end  -label "FIFO Full" sim:/ni_tx_fsm/fifoFull
add wave -position end  -label "FIFO Write Enable" sim:/ni_tx_fsm/fifoWriteEn
add wave -position end  -label "FIFO Write State" sim:/ni_tx_fsm/fifo_state
add wave -position end  -label "FIFO Write Request" sim:/ni_tx_fsm/fifoWriteRqst
###### Transmission Control ###### 
add wave -divider "Transmission Control"
add wave -position end  -label "FIFO Empty" sim:/ni_tx_fsm/fifoEmpty
add wave -position end  -label "Pop FIFO" sim:/ni_tx_fsm/fifoPopEn
add wave -position end  -label "Channel Valid" sim:/ni_tx_fsm/channelValid
add wave -position end  -label "Channel State" sim:/ni_tx_fsm/channel_state

# Set starting state as FIFO is Empty
force fifoEmpty 1
force fifoFull 0
force fifoWriteRqst 0
force cleartosend 1
run 100

# Start Write
force fifoWriteRqst 1
run 100
force fifoEmpty 0
run 100
force fifoFull 1