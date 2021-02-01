-------------------------------------------------
-- Approximate Network on Chip RX  
-- Test bench for RX Data Writing
-- Purpose:
--      Test data torage
--  Requires: VHDL-2008
--  Rick Fenster, Jan 30/2021
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ni_shared_components.all;
use work.ni_rx_components.all;

entity ni_rx_test_data_write is
    generic
    (
        fifoWidth : integer := 16;
        addrWidth : integer := 6;
        fifoDepth : integer := 4
    );

    port
    (
        clk, rst : in std_logic;
        networkMode : in std_logic;
        addrA, addrB : in std_logic_vector (addrWidth - 1 downto 0);
        channelAValid, channelBValid : in std_logic;
        ctsChannelA, ctsChannelB : out std_logic;
        dataInA, dataInB : in std_logic_vector (fifoWidth - 1 downto 0);
        popEnA, popEnB : in std_logic
    );
end ni_rx_test_data_write;

architecture ni_rx_test_data_write_impl of ni_rx_test_data_write is
    -- Write enable signals
    signal fifoA_writeEn_i, fifoB_writeEn_i, fifoB_writeEn_postmux_i : std_logic;
    -- FIFO full signals
    signal fifoA_Full_i, fifoB_Full_i : std_logic; 
    begin
        -- Instance Data FIFO A
        data_fifo_a : ni_rx_data_fifo
            generic map (fifoWidth => fifoWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, dualOutputEn => networkMode, fifoFull => fifoA_Full_i, dataIn => dataInA,
                popEn => popEnA, writeEn => fifoA_writeEn_i);

        -- Instance Data FIFO B
        data_fifo_b : ni_rx_data_fifo
            generic map (fifoWidth => fifoWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, dualOutputEn => '0', fifoFull => fifoB_Full_i, dataIn => dataInB,
                popEn => popEnB, writeEn => fifoB_writeEn_postmux_i);  
        
        -- Instance Address FIFO A
        addr_fifo_a : ni_rx_addr_fifo
            generic map (fifoWidth => addrWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, popEn => popEnA, writeEn => fifoA_writeEn_i,
                dataIn => addrA, dualPop => networkMode);

        -- Instance Address FIFO B
        addr_fifo_B : ni_rx_addr_fifo
            generic map (fifoWidth => addrWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, popEn => popEnB, writeEn => fifoB_writeEn_postmux_i,
                dataIn => addrB, dualPop => '0');

        -- Instance FIFO A Write FSM
        write_fsm_a : ni_rx_write_fsm
            port map (clk => clk, rst => rst, fifoFull => fifoA_Full_i, fifowriteEn => fifoA_writeEn_i, clearToSend => ctsChannelA,
                channelValid => channelAValid);

        -- Instance FIFO B Write FSM
        write_fsm_b : ni_rx_write_fsm
            port map (clk => clk, rst => rst, fifoFull => fifoB_Full_i, fifowriteEn => fifoB_writeEn_i, clearToSend => ctsChannelB,
                channelValid => channelBValid);                
        -- Mux for B FIFOs
        fifoB_writeEn_postmux_i <= fifoB_writeEn_i when networkMode = '1' else
                           fifoA_writeEn_i;
end ni_rx_test_data_write_impl;
