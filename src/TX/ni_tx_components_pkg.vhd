-------------------------------------------------
-- Approximate Network on Chip TX Component Pkg
-- Purpose:
--      Stores declarations for all components
--      for TX.
--  Requires: VHDL-2008
--  Rick Fenster, Jan 30/2021
-------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package ni_tx_components is

    -- TX Data FIFO Declaration
    component ni_tx_data_fifo is
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
    end component ni_tx_data_fifo;

    -- TX FSM Declaration
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
    
    end component ni_tx_fsm;

end package ni_tx_components;