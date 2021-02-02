-------------------------------------------------
-- Approximate Network on Chip RX Read Top Level
-- Purpose:
--      Receiver for network on chip.
--      Instances FIFOs and necessary components
--  Requires: VHDL-2008
--  Rick Fenster, Jan 30/2021
--  Updated, Feb 1/2021
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
    -- Channel A Signals
    signal dataFIFO_A_out_i : std_logic_vector (doubleFIFOWidth - 1 downto 0);
    signal addrFIFO_A_out_i : std_logic_vector (addressWidth - 1 downto 0);
    signal dataFIFO_A_empty_i, dataFIFO_A_full_i, FIFO_A_popEn_i, FIFO_A_writeEn_i : std_logic;

    -- Channel B Signals
    signal dataFIFO_B_out_i : std_logic_vector (doubleFIFOWidth - 1 downto 0);
    signal addrFIFO_B_out_i : std_logic_vector (addressWidth - 1 downto 0);    
    signal dataFIFO_B_empty_i, dataFIFO_B_full_i, FIFO_B_popEn_i, FIFO_B_writeEn_i : std_logic;
    signal FIFO_B_writeEn_postmux_i : std_logic;

    -- Internal status signals
    signal dataType_i : std_logic;

    begin
    
    -- Instance Data FIFO A
    data_FIFO_A : ni_rx_data_fifo
        generic map (fifoWidth => fifoWidth, fifoDepth => fifoDepth)
        port map (clk => clk, rst => rst, popEn => FIFO_A_popEn_i, writeEn => FIFO_A_writeEn_i,
            fifoEmpty => dataFIFO_A_empty_i, fifoFull => dataFIFO_A_full_i, dualOutputEn => networkMode,
            dataIn => dataInA, dataOut => dataFIFO_A_out_i);

    -- Instance Data FIFO B
    data_FIFO_B : ni_rx_data_fifo
        generic map (fifoWidth => fifoWidth, fifoDepth => fifoDepth)
        port map (clk => clk, rst => rst, popEn => FIFO_B_popEn_i, writeEn => FIFO_B_writeEn_postmux_i,
            fifoEmpty => dataFIFO_B_empty_i, fifoFull => dataFIFO_B_full_i, dualOutputEn => '0',
                dataIn => dataInB, dataOut => dataFIFO_B_out_i);

    -- Instance Address FIFO A
    addr_FIFO_A : ni_rx_addr_fifo
        generic map (fifoWidth => addressWidth, fifoDepth => fifoDepth)
        port map (clk => clk, rst => rst, popEn => FIFO_A_popEn_i, writeEn => FIFO_A_writeEn_i,
            dualPop => networkMode, dataIn => addrA, dataOut => addrFIFO_A_out_i);

    -- Instance Address FIFO B            
    addr_FIFO_B : ni_rx_addr_fifo
        generic map (fifoWidth => addressWidth, fifoDepth => fifoDepth)
        port map (clk => clk, rst => rst, popEn => FIFO_B_popEn_i, writeEn => FIFO_B_writeEn_postmux_i,
            dualPop => '0', dataIn => addrB, dataOut => addrFIFO_B_out_i);

    -- Instance Data Read FSM
    rx_read_fsm: ni_rx_read_fsm
        port map (clk => clk, rst => rst, fifoAEmpty => dataFIFO_A_empty_i, fifoBEmpty => dataFIFO_B_empty_i,
            fifoAPopEn => FIFO_A_popEn_i, fifoBPopEn => FIFO_B_popEn_i, fifoPopRqst => dataRqst,
            networkMode => networkMode, dataType => dataType_i, dataAvailable => dataAvailable,
            dataValid => dataValid);

    -- Instance channel A Write FSM
    rx_write_chanA_fsm : ni_rx_write_fsm
        port map (clk => clk, rst => rst, fifoFull => dataFIFO_A_full_i, fifoWriteEn => FIFO_A_writeEn_i,
            channelValid => channelAValid, clearToSend => ctsChannelA);

    -- Instance channel B Write FSM
    rx_write_chanB_fsm : ni_rx_write_fsm
        port map (clk => clk, rst => rst, fifoFull => dataFIFO_B_full_i, fifoWriteEn => FIFO_B_writeEn_i,
            channelValid => channelBValid, clearToSend => ctsChannelB);            

            -- Switching for Channel B FIFO Write Enables
    FIFO_B_writeEN_postmux_i <= FIFO_A_writeEn_i when (networkMode = '0') else
        FIFO_B_writeEn_i;

    -- Switching for data origin
    dataOrigin <= addrFIFO_A_out_i when (networkMode = '0' or (networkMode = '1' and dataType_i = '0'))
        else addrFIFO_B_out_i;
    -- Switching for data output
    dataOut (doubleFIFOWidth - 1 downto fifoWidth) <= 
               dataFIFO_B_out_i (doublefifoWidth - 1 downto fifoWidth) when (networkMode = '1' and dataType = '1')
        else   dataFIFO_A_out_i (doubleFIFOWidth - 1 downto fifoWidth) when (networkMode = '1' and dataType = '0')
        else   dataFIFO_A_out_i (fifoWidth - 1 downto 0) when (networkMode = '0');

    dataOut (fifoWidth - 1 downto 0) <=
        dataFIFO_B_out_i (fifoWidth - 1 downto 0) when (networkMode = '1' and dataType = '1')
        else   dataFIFO_A_out_i (fifoWidth - 1 downto 0) when (networkMode = '1' and dataType = '0')
        else   dataFIFO_B_out_i (fifoWidth - 1 downto 0) when (networkMode = '0');

        dataType <= dataType_i;

end ni_rx_top_rtl;