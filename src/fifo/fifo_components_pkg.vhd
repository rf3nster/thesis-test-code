-------------------------------------------------
-- Approximate Network on Chip FIFO Component Pkg
-- Purpose:
--      Stores declarations for FIFO components
--  Requires: VHDL-2008
--  Rick Fenster, Feb 22/2021
-------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package ni_fifo_components is

    -- Dual Output FIFO
    component fifo_dual_output is
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
            fifoEmpty, fifoFull : out std_logic;
            -- Data
            dataIn : in std_logic_vector (fifoWidth - 1 downto 0);
            dataOut : out std_logic_vector (fifoWidth * 2 - 1 downto 0)
        );
    end component;

    -- Dual Pop FIFO
    component fifo_dual_pop is
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
            popEn, writeEn, dualPop : in std_logic;
            -- FIFO Status
            fifoEmpty, fifoFull : out std_logic;
            -- Data
            dataIn : in std_logic_vector (fifoWidth - 1 downto 0);
            dataOut : out std_logic_vector (fifoWidth - 1 downto 0)
        );
    end component;

    component fifo_dual_write is
        generic
        (
            fifoWidth : integer := 16;
            fifoDoubleWidth : integer := fifoWidth * 2;
            fifoDepth : integer := 4
        );
    -- Dual Write FIFO, for data
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
    -- Dual Write FIFO, for address
    component fifo_dual_write_addr is
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
            popEn, writeEn, dualWriteEn : in std_logic;
            -- FIFO Status
            fifoEmpty, fifoFull : out std_logic;
            -- Data
            dataIn : in std_logic_vector (fifoWidth - 1 downto 0);
            dataOut : out std_logic_vector (fifoWidth - 1 downto 0)
        );
    end component;    
end package ni_fifo_components;