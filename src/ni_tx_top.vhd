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
        writeAccEn, writeApxEn : in std_logic;
        ctsChannelA, ctsChannelB : in std_logic;
        channelAValid, channelBValid : out std_logic;
        dataOutA, dataOutB : out std_logic_vector (fifoWidth - 1 downto 0);
        accFIFOFull, accFIFOAlmostFull, apxFIFOFull, apxFIFOAlmostFull : out std_logic
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
    signal fifoAcc_Full_i, fifoAcc_Empty_i, fifoAcc_AlmostEmpty_i, fifoAcc_AlmostFull_i, fifoAcc_WriteEn_i, fifoAcc_PopEn_i : std_logic;
    signal fifoApx_WriteEn_i, fifoApx_PopEn_i : std_logic;
    signal fifoB_Full_i, fifoB_Empty_i, fifoB_AlmostEmpty_i, fifoB_AlmostFull_i, fifoB_WriteEn_i, fifoB_PopEn_i : std_logic;    

    begin
        -- Instance FIFO A
        FIFO_A : ni_fifo
            generic map (fifoWidth => fifoWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, dataIn => dataIn, dataOut => dataOutA, popEn => fifoAcc_PopEn_i, writeEn => fifoAcc_WriteEn_i,
                      fifoAlmostEmpty => fifoAcc_AlmostEmpty_i, fifoAlmostFull => fifoAcc_AlmostFull_i, fifoFull => fifoAcc_Full_i, fifoEmpty => fifoAcc_Empty_i,
                      dualWriteEn => networkMode, writeUpper => '0');
        -- Instance FIFO B
        FIFO_B : ni_fifo
            generic map (fifoWidth => fifoWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, dataIn => dataIn, dataOut => dataOutB, popEn => fifoB_PopEn_i, writeEn => fifoB_WriteEn_i,
                      fifoAlmostEmpty => fifoB_AlmostEmpty_i, fifoAlmostFull => fifoB_AlmostFull_i, fifoFull => fifoB_Full_i, fifoEmpty => fifoB_Empty_i,
                      dualWriteEn => '0', writeUpper => '1');        
        -- Instance FSMs
        FSM_ACC : ni_tx_fsm
            port map (clk => clk, rst => rst, fifoFull => fifoAcc_Full_i, fifoEmpty => fifoAcc_Empty_i, fifoWriteEn => fifoAcc_WriteEn_i, 
                      fifoPopEn => fifoAcc_PopEn_i, fifoWriteRqst => writeAccEn, clearToSend => ctsChannelA, channelValid => channelAValid);
        FSM_APX : ni_tx_fsm
            port map (clk => clk, rst => rst, fifoFull => fifoB_Full_i, fifoEmpty => fifoB_Empty_i, fifoWriteEn => fifoApx_WriteEn_i, 
                      fifoPopEn => fifoApx_PopEn_i, fifoWriteRqst => writeApxEn, clearToSend => ctsChannelB, channelValid => channelBValid);
                      

        -- Mux signals
        fifoB_PopEn_i <= fifoAcc_PopEn_i when (networkMode = '0') else
                         fifoApx_PopEn_i;
        fifoB_WriteEn_i <= fifoAcc_WriteEn_i when (networkMode = '0') else
                         fifoApx_WriteEn_i;
        -- Set status signals outside
        accFIFOFull <= fifoAcc_Full_i;
        accFIFOAlmostFull <= fifoAcc_AlmostFull_i;

        apxFIFOFull <= fifoB_Full_i;
        apxFIFOAlmostFull <= fifoB_AlmostFull_i;


            
end ni_tx_top_impl;