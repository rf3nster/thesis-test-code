-------------------------------------------------
-- Approximate Network on Chip RX Read Top Level
-- Purpose:
--      Receiver for network on chip.
--      Instances FIFOs and necessary components
--  Requires: VHDL-2008
--  Rick Fenster, Jan 30/2021
-- TO-DO:
--      * Add combination/muxes for signals
-------------------------------------------------

-- Library declarations
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ni_rx_components.all;
use work.ni_shared_components.all;

entity ni_rx_top is
    generic(
        addressWidth : integer := 6;
        fifoWidth : integer := 16;
        doubleFIFOWidth : integer := fifoWidth * 2;        
        fifoDepth : integer := 4
    );

    port(
        -- Basic control signals
        clk, rst, networkMode : in std_logic;
        -- Data inputs
        addrA, addrB : in std_logic_vector (addressWidth - 1 downto 0);
        dataInA, dataInB : in std_logic_vector (fifoWidth - 1 downto 0);
        -- Data control signals
        ctsChannelA, ctsChannelB : out std_logic;
        channelAValid, channelBValid : in std_logic;
        dataRqst : in std_logic;
        -- Data output signals
        dataOut : out std_logic_vector (doubleFifoWidth - 1 downto 0);
        dataValid : out std_logic;
        dataAvailable : out std_logic;
        dataType : out std_logic;
        dataOrigin : out std_logic_vector (addressWidth - 1 downto 0)
    );
end ni_rx_top;

architecture ni_rx_top_rtl of ni_rx_top is
    -- Address FIFO A signals
    signal addrFIFOA_popEn_i, addrFIFOA_writeEn_i : std_logic;
    signal addrFIFOA_full_i, addrFIFOA_empty_i : std_logic;
    signal addrFIFOA_dataOut_i : std_logic_vector (addressWidth - 1 downto 0);

    -- Address FIFO B signals
    signal addrFIFOB_popEn_i, addrFIFOB_writeEn_i : std_logic;
    signal addrFIFOB_full_i, addrFIFOB_empty_i : std_logic;
    signal addrFIFOB_dataOut_i : std_logic_vector (addressWidth - 1 downto 0);
    
    -- Data FIFO A signals
    signal dataFIFOA_popEn_i, dataFIFOA_writeEn_i : std_logic;
    signal dataFIFOA_full_i, dataFIFOA_empty_i : std_logic;   
    signal dataFIFOA_dataOut_i : std_logic_vector (doubleFIFOWidth - 1 downto 0);


    -- Data FIFO B signals
    signal dataFIFOB_popEn_i, dataFIFOB_writeEn_i : std_logic;
    signal dataFIFOB_full_i, dataFIFOB_empty_i : std_logic;  
    signal dataFIFOB_dataOut_i : std_logic_vector (doubleFIFOWidth - 1 downto 0);

    -- Signal declarations
    begin
        -- FIFO Instantiations 
        -- Address FIFO A
        addrFIFOA: ni_addr_fifo
            generic map (fifoWidth => addressWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, fifoFull => addrFIFOA_full_i, fifoEmpty => addrFIFOA_empty_i,
                popEn => addrFIFOA_popEn_i, writeEn => addrFIFOA_writeEn_i, dualWriteEn => networkMode,
                dataIn => addrA, dataOut => addrFIFOA_dataOut_i);

        -- Address FIFO B
        addrFIFOB: ni_addr_fifo
            generic map (fifoWidth => addressWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, fifoFull => addrFIFOB_full_i, fifoEmpty => addrFIFOB_empty_i,
                popEn => addrFIFOB_popEn_i, writeEn => addrFIFOB_writeEn_i, dualWriteEn => '0',
                dataIn => addrB, dataOut => addrFIFOB_dataOut_i);

        -- Data FIFO A
        dataFIFOA: ni_rx_data_fifo
            generic map (fifoWidth => fifoWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, fifoFull => dataFIFOA_full_i, fifoEmpty => dataFIFOA_empty_i,
                popEn => dataFIFOA_popEn_i, writeEn => dataFIFOA_empty_i, dataOut => dataFIFOA_dataOut_i,
                dualOutputEn => networkMode, dataIn => dataInA);

        -- Data FIFO B
        dataFIFOB: ni_rx_data_fifo
            generic map (fifoWidth => fifoWidth, fifoDepth => fifoDepth)
            port map (clk => clk, rst => rst, fifoFull => dataFIFOB_full_i, fifoEmpty => dataFIFOB_empty_i,
                popEn => dataFIFOB_popEn_i, writeEn => dataFIFOB_empty_i, dataOut => dataFIFOB_dataOut_i,
                dualOutputEn => '0', dataIn => dataInB);

        -- FSM Instantiations
        -- Read FSM
        readFSM: ni_rx_read_fsm
            port map (clk => clk, rst => rst, fifoAEmpty => dataFIFOA_empty_i, 
                fifoBEmpty => dataFIFOB_empty_i, fifoAPopEn => dataFIFOA_popEn_i, fifoBPopEn => dataFIFOB_popEn_i,
                networkMode => networkMode, dataType => dataType, dataAvailable => dataAvailable,
                dataValid => dataValid, fifoPopRqst => dataRqst);
        
        -- Write FSM A
        writeFSMA: ni_rx_write_fsm
            port map(clk => clk, rst => rst, fifoFull => dataFIFOA_full_i, fifoWriteEn => dataFIFOA_writeEn_i,
                channelValid => channelAValid, clearToSend => ctsChannelA);
        
        -- Write FSM B
        writeFSMB: ni_rx_write_fsm
            port map(clk => clk, rst => rst, fifoFull => dataFIFOB_full_i, fifoWriteEn => dataFIFOB_writeEn_i,
                channelValid => channelBValid, clearToSend => ctsChannelB);

        -- Switching logic
end ni_rx_top_rtl;