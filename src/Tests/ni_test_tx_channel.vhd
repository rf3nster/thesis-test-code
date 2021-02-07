-------------------------------------------------
-- Approximate Network on Chip TX Channel 
-- Test
-- Purpose:
--      Testbench for testing TX transmisison
--  Requires: VHDL-2008
--  Rick Fenster, Feb 5/2021
-------------------------------------------------

-- Library declarations
library work;
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ni_tx_components.all;

entity ni_test_tx_channel is
    generic
    (
        fifoWidth : integer := 16;
        fifoDepth : integer := 4
    );

    port
    (
        clk, rst : in std_logic;
        dataIn : in std_logic_vector (fifoWidth * 2 - 1 downto 0);
        dataOut : out std_logic_vector (fifoWidth  - 1 downto 0);
        fifoWriteRqst : in std_logic;
        clearToSend : in std_logic;
        channelValid : out std_logic
    );
end ni_test_tx_channel;

architecture ni_test_tx_channel_impl of ni_test_tx_channel is
        signal fifoFull_i, fifoEmpty_i, fifoPopEn_i, fifoWriteEn_i : std_logic;
        begin
            ni_fifo : ni_tx_data_fifo
                generic map (fifoWidth => fifoWidth, fifoDepth => fifoDepth)
                port map (clk=>clk, rst => rst, popEn => fifoPopEn_i, writeEn => fifoWriteEn_i, dualWriteEn => '0',
                    writeUpper => '0', fifoEmpty => fifoEmpty_i, fifoFull => fifoFull_i, dataIn => dataIn, dataOut => dataOut);

            ni_fsm : ni_tx_fsm
                port map (clk => clk, rst => rst, fifoFull => fifoFull_i, fifoEmpty => fifoEmpty_i, fifoWriteEn => fifoWriteEn_i,
                    fifoPopEn => fifoPopEn_i, fifoWriteRqst => fifoWriteRqst, clearToSend => clearToSend, channelValid => channelValid);

end ni_test_tx_channel_impl;