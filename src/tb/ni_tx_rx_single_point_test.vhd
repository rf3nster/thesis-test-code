-------------------------------------------------
-- Approximate Network on Chip Point to Point 
-- Test
-- Purpose:
--      Testbench for testing TX -> RX
--      transmission, single point to point.
--  Requires: VHDL-2008
--  Rick Fenster, Feb 5/2021
-------------------------------------------------

-- Library declarations

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ni_shared_components.all;
use work.ni_tx_components.all;
use work.ni_rx_components.all;

entity ni_rx_tx_test is
    generic
    (
        fifoWidth : integer := 16;
        addressWidth : integer := 6;
        fifoDepth : integer := 4
    );

    port
    (
        -- General system
        clk, rst, networkMode : in std_logic;
        -- TX
        dataIn : in std_logic_vector((fifoWidth * 2 ) - 1 downto 0);
        addrIn : in std_logic_vector(addressWidth - 1 downto 0);
        writeApxEn, writeAccEn : in std_logic;
        accFIFOFull, apxFIFOFull : out std_logic;
        -- RX
        dataRqst : in std_logic;
        dataType : out std_logic;
        dataValid : out std_logic;
        dataOrigin : out std_logic_vector(addressWidth - 1 downto 0);
        dataAvailable : out std_logic;
        dataOut : out std_logic_vector ((fifoWidth * 2 ) - 1 downto 0)
    );
end ni_rx_tx_test;

architecture ni_rx_tx_test_impl of ni_rx_tx_test is
    signal datachannel : std_logic_vector ((fifoWidth * 2 ) - 1 downto 0);
    alias dataChannelA : std_logic_vector (fifoWidth - 1 downto 0) is datachannel ((fifoWidth * 2) - 1 downto fifoWidth);
    alias dataChannelB : std_logic_vector (fifoWidth - 1 downto 0) is datachannel (fifoWidth  - 1 downto 0);
    signal addrA, addrB : std_logic_vector (addressWidth - 1 downto 0);
    signal channelAValid, channelBValid, ctsChannelA, ctsChannelB : std_logic;

    begin
        ni_rx : ni_rx_top
            generic map (addressWidth => addressWidth, fifoWidth => fifoWidth, fifoDepth => fifoDepth)        
            port map (clk => clk, rst => rst, networkMode => networkMode, addrA => addrA, addrB => addrB,
                dataInA => dataChannelA, dataInB => dataChannelB, dataRqst => dataRqst, channelAValid => channelAValid,
                channelBValid => channelBValid, ctsChannelA => ctsChannelA, ctsChannelB => ctsChannelB,
                dataOut => dataOut, dataValid => dataValid, dataType => dataType, dataOrigin => dataOrigin,
                dataAvailable => dataAvailable);
        
        ni_tx : ni_tx_top
            generic map (addressWidth => addressWidth, fifoDepth => fifoDepth, fifoWidth => fifoWidth)
            port map (clk => clk, rst => rst, dataIn => dataIn, networkMode => networkMode, writeAccEn => writeAccEn,
                writeApxEn => writeApxEn, ctsChannelA => ctsChannelA, ctsChannelB => ctsChannelB, dataOutA => dataChannelA,
                dataOutB => dataChannelB, addressOutA => addrA, addressOutB => addrB, addrIn => addrIn,
                accFIFOFull => accFIFOFUll, apxFIFOFull => apxFIFOFull, 
                channelAValid => channelAValid, channelBValid => channelBValid);
    end ni_rx_tx_test_impl;