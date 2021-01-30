# RX Addressing System Test
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
