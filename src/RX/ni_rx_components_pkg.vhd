-------------------------------------------------
-- Approximate Network on Chip RX Component Pkg
-- Purpose:
--      Stores declarations for all components
--      for RX.
--  Requires: VHDL-2008
--  Rick Fenster, Jan 30/2021
-------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package ni_rx_components is


-- RX Data FIFO Declaration
component ni_rx_data_fifo is
    generic
    (
        fifoWidth : integer := 16;
        fifoDepth : integer := 4
    );

    port
    (
        -- Clocking control
        clk, rst : in std_logic;
        -- FIFO Control
        popEn, writeEn, dualOutputEn : in std_logic;
        -- FIFO Status
        fifoEmpty, fifoFull, fifoAlmostFull, fifoAlmostEmpty : out std_logic;
        -- Data
        dataIn : in std_logic_vector (fifoWidth - 1 downto 0);
        dataOut : out std_logic_vector (fifoWidth * 2 - 1 downto 0)
    );
end component ni_rx_data_fifo;

-- RX FIFO Write FSM Declaration
component ni_rx_write_fsm is
    port
    (
        -- General control
        clk, rst : in std_logic;
        -- FIFO status signals
        fifoFull : in std_logic;      
        -- FIFO Control signals
        fifoWriteEn : out std_logic;
        -- Channel control signal
        channelValid : in std_logic;
        clearToSend : out std_logic
    );
end component ni_rx_write_fsm;

-- RX FIFO Read Declaration
component ni_rx_read_fsm is
    port
    (
        -- General control
        clk, rst : in std_logic;
        -- FIFO status signals
        fifoAEmpty : in std_logic;
        fifoBEmpty : in std_logic;       
        -- FIFO Control signals
        fifoAPopEn : out std_logic;
        fifoBPopEn : out std_logic;        
        fifoPopRqst : in std_logic;
        networkMode : in std_logic;
        dataType, dataAvailable : out std_logic;
        -- Channel control
        dataValid : out std_logic
    );
end component ni_rx_read_fsm;

end package ni_rx_components;