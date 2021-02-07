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

    component ni_tx_top is
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
    end component;
    

end package ni_tx_components;