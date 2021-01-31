-------------------------------------------------
-- Approximate Network on Chip RX  
-- Test bench for RX Address storage
-- Purpose:
--      Test address retrieval and storage
--  Requires: VHDL-2008
--  Rick Fenster, Jan 30/2021
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ni_shared_components.all;
use work.ni_rx_components.all;

entity ni_rx_test_addr is
    generic
    (
        addrWidth : integer := 6;
        fifoDepth : integer := 4
    );

    port
    (
        clk, rst : in std_logic;
        networkMode : in std_logic;
        addrA, addrB : in std_logic_vector (addrWidth - 1 downto 0);
        channelA_writeEn, channelB_writeEn : in std_logic;
        popRqst : in std_logic;
        dataOrigin : out std_logic_vector (addrWidth - 1 downto 0);
        dataType, dataValid, dataAvailable : out std_logic
    );
end ni_rx_test_addr;

architecture ni_rx_test_addr_impl of ni_rx_test_addr is

    signal dataType_i : std_logic;
    signal addrOut_A_i, addrOut_B_i : std_logic_vector (addrWidth - 1 downto 0);
    signal fifoA_Empty_i, fifoB_Empty_i : std_logic;
    signal channelA_popEn_i, channelB_popEn_i : std_logic;
    signal dataAvailable_i : std_logic;
    begin
        -- Instance FIFOs
        addrA_FIFO: ni_rx_addr_fifo
            generic map (fifoWidth => addrWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, popEn => channelA_popEn_i, writeEn => channelA_writeEn,
                dualPop => networkMode, dataIn => addrA, fifoEmpty => fifoA_Empty_i, dataOut => addrOut_A_i);

        addrB_FIFO: ni_rx_addr_fifo
            generic map (fifoWidth => addrWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, popEn => channelB_popEn_i, writeEn => channelB_writeEn,
                dualPop => '0', dataIn => addrB, fifoEmpty => fifoB_Empty_i, dataOut => addrOut_B_i);
        -- Instance Read FSM

        rx_read_fsm: ni_rx_read_fsm
            port map (clk => clk, rst => rst, fifoAEmpty => fifoA_Empty_i, fifoBEmpty => fifoB_Empty_i,
                fifoAPopEn => channelA_popEn_i, fifoBPopEn => channelB_popEn_i, networkMode => networkMode,
                dataType => dataType_i, dataAvailable => dataAvailable_i, dataValid => dataValid, 
                fifoPopRqst => popRqst);

    dataOrigin <= addrOut_B_i when (networkMode = '1' and dataType_i = '1') else
                  addrOut_A_i;
    dataAvailable <= dataAvailable_i;
    dataType <= dataType_i;
end ni_rx_test_addr_impl;
