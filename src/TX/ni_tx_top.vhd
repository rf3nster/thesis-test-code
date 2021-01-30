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

library work;
use work.ni_shared_components.all;
use work.ni_tx_components.all;

entity ni_tx_top is 
    generic
    (
        addressWidth : integer := 6;
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
        addressOutA, addressOutB : out std_logic_vector (addressWidth - 1 downto 0);
        addrIn : in std_logic_vector (addressWidth - 1 downto 0);
        accFIFOFull, accFIFOAlmostFull, apxFIFOFull, apxFIFOAlmostFull : out std_logic
    );
end ni_tx_top;

architecture ni_tx_top_impl of ni_tx_top is

    signal fifoAcc_Full_i, fifoAcc_Empty_i, fifoAcc_AlmostEmpty_i, fifoAcc_AlmostFull_i, fifoAcc_WriteEn_i, fifoAcc_PopEn_i : std_logic;
    signal fifoApx_WriteEn_i, fifoApx_PopEn_i : std_logic;
    signal fifoB_Full_i, fifoB_Empty_i, fifoB_AlmostEmpty_i, fifoB_AlmostFull_i, fifoB_WriteEn_i, fifoB_PopEn_i : std_logic;  
    signal fifoAddrA_Full_i, fifoAddrA_Empty_i, fifoAddrB_Full_i, fifoAddrB_Empty_i, fifoAddrB_PopEn_i, fifoAddrB_WriteEn_i : std_logic;  

    begin
        -- Instance Data FIFO A
        FIFO_data_A : ni_tx_data_fifo
            generic map (fifoWidth => fifoWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, dataIn => dataIn, dataOut => dataOutA, popEn => fifoAcc_PopEn_i, writeEn => fifoAcc_WriteEn_i,
                      fifoAlmostEmpty => fifoAcc_AlmostEmpty_i, fifoAlmostFull => fifoAcc_AlmostFull_i, fifoFull => fifoAcc_Full_i, fifoEmpty => fifoAcc_Empty_i,
                      dualWriteEn => networkMode, writeUpper => '0');
        -- Instance Data FIFO B
        FIFO_data_B : ni_tx_data_fifo
            generic map (fifoWidth => fifoWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, dataIn => dataIn, dataOut => dataOutB, popEn => fifoB_PopEn_i, writeEn => fifoB_WriteEn_i,
                      fifoAlmostEmpty => fifoB_AlmostEmpty_i, fifoAlmostFull => fifoB_AlmostFull_i, fifoFull => fifoB_Full_i, fifoEmpty => fifoB_Empty_i,
                      dualWriteEn => '0', writeUpper => '1');   
                      
        -- Instance Address FIFO A (Accurate)
        FIFO_addr_A: ni_addr_fifo
            generic map (fifoWidth => addressWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, dataIn => addrIn, dataOut => addressOutA, popEn => fifoAcc_PopEn_i, writeEn => fifoAcc_WriteEn_i, dualWriteEn => networkMode, fifoFull => fifoAddrA_Full_i, fifoEmpty => fifoAddrA_Empty_i );

        -- Instance Address FIFO B (Approx)
       FIFO_addr_B: ni_addr_fifo
            generic map (fifoWidth => addressWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, dataIn => addrIn, dataOut => addressOutB, popEn => fifoAddrB_PopEn_i, writeEn => fifoAddrB_WriteEn_i, dualWriteEn => '0', fifoFull => fifoAddrB_Full_i, fifoEmpty => fifoAddrB_Empty_i );            
        
        -- Instance FSMs
        FSM_ACC : ni_tx_fsm
            port map (clk => clk, rst => rst, fifoFull => fifoAcc_Full_i, fifoEmpty => fifoAcc_Empty_i, fifoWriteEn => fifoAcc_WriteEn_i, 
                      fifoPopEn => fifoAcc_PopEn_i, fifoWriteRqst => writeAccEn, clearToSend => ctsChannelA, channelValid => channelAValid);
        FSM_APX : ni_tx_fsm
            port map (clk => clk, rst => rst, fifoFull => fifoB_Full_i, fifoEmpty => fifoB_Empty_i, fifoWriteEn => fifoApx_WriteEn_i, 
                      fifoPopEn => fifoApx_PopEn_i, fifoWriteRqst => writeApxEn, clearToSend => ctsChannelB, channelValid => channelBValid);
                      
        -- Mux signals for data FIFO
        fifoB_PopEn_i <= fifoAcc_PopEn_i when (networkMode = '0') else
                         fifoApx_PopEn_i;
        fifoB_WriteEn_i <= fifoAcc_WriteEn_i when (networkMode = '0') else
                         fifoApx_WriteEn_i;
        -- Mux signals for address FIFO
        fifoAddrB_PopEn_i <= '0' when (networkMode = '0') else
                             fifoApx_PopEn_i;
        fifoAddrB_WriteEn_i <= '0' when (networkMode = '0') else
                             fifoApx_WriteEn_i;
            
    
        -- Set status signals outside
        accFIFOFull <= fifoAcc_Full_i;
        accFIFOAlmostFull <= fifoAcc_AlmostFull_i;

        apxFIFOFull <= fifoB_Full_i;
        apxFIFOAlmostFull <= fifoB_AlmostFull_i;


            
end ni_tx_top_impl;