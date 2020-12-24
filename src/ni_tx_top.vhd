-------------------------------------------------
-- Approximate Network on Chip TX Top
-- Purpose:
--      Top level of Network on Chip TX 
--      Has two modes:
--          Mode 0: Accurate data across two 
--                  channels. (2x 16 bit) 
--          Mode 1: Accurate data on one channel
--                  transmitted over two cycles
--                  and other channel is approx
--                  data (16 bit) over one.
--      
--  Requires: VHDL-2008
--  Rick Fenster, Dec 24/2020
-------------------------------------------------

-- Library declarations
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ni_tx_top is 
    generic
    (
        fifoWidth : integer := 16;
        doubleFIFOWidth : integer := fifoWidth * 2;        
        fifoDepth : integer := 4
    );

    port
    (
        clk, rst : in std_logic;
        dataIn : in std_logic_vector (doubleFIFOWidth - 1 downto 0);
        networkMode : in std_logic;
        writeEn : in std_logic;
        ctsChannelA : in std_logic;
        channelAValid : out std_logic;
        dataOutA : out std_logic_vector (fifoWidth - 1 downto 0);
        accFIFOFull, accFIFOAlmostFull : out std_logic
    );
end ni_tx_top;

architecture ni_tx_top_impl of ni_tx_top is

    -- Component definition for FIFO
    component ni_fifo is
        generic
        (
            fifoWidth : integer := 16;
            fifoDoubleWidth : integer := fifoWidth * 2;
            fifoDepth : integer := 4
        );
    
        port
        (
            -- Clocking control
            clk, rst : in std_logic;
            -- FIFO Control
            popEn, writeEn, dualWriteEn, writeUpper : in std_logic;
            -- FIFO Status
            fifoEmpty, fifoAlmostEmpty, fifoFull, fifoAlmostFull : out std_logic;
            -- Data
            dataIn : in std_logic_vector (fifoDoubleWidth - 1 downto 0);
            dataOut : out std_logic_vector (fifoWidth - 1 downto 0)
        );
    end component;

    -- Component definition for NI TX FSM
    component ni_tx_fsm is
        port
        (
            -- General control
            clk, rst : in std_logic;
            -- FIFO status signals
            fifoFull, fifoEmpty : in std_logic;
            -- FIFO Control signals
            fifoWriteEn, fifoPopEn : out std_logic;
            fifoWriteRqst : in std_logic;
            -- Channel control
            clearToSend : in std_logic;
            channelValid : out std_logic
        );
    end component;
    signal fifoA_Full_i, fifoA_Empty_i, fifoA_AlmostEmpty_i, fifoA_AlmostFull_i, fifoA_WriteEn_i, fifoA_PopEn_i : std_logic;
    signal writeUpper : std_logic := '0';
    begin
        -- Instance FIFO
        FIFO_A : ni_fifo
            generic map (fifoWidth => fifoWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, dataIn => dataIn, dataOut => dataOutA, popEn => fifoA_PopEn_i, writeEn => fifoA_WriteEn_i,
                      fifoAlmostEmpty => fifoA_AlmostEmpty_i, fifoAlmostFull => fifoA_AlmostFull_i, fifoFull => fifoA_Full_i, fifoEmpty => fifoA_Empty_i,
                      dualWriteEn => networkMode, writeUpper => writeUpper);

        -- Instance FSM
        FSM_A : ni_tx_fsm
            port map (clk => clk, rst => rst, fifoFull => fifoA_Full_i, fifoEmpty => fifoA_Empty_i, fifoWriteEn => fifoA_WriteEn_i, 
                      fifoPopEn => fifoA_PopEn_i, fifoWriteRqst => writeEn, clearToSend => ctsChannelA, channelValid => channelAValid);
end ni_tx_top_impl;