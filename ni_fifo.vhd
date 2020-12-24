-------------------------------------------------
-- Approximate Network on Chip FIFO
-- Purpose:
--      Expandable FIFO used for network 
--      interface. Uses generics for size. Pops
--      and pushes on positive clock edges, async
--      reset.
--  Requires: VHDL-2008
--  Rick Fenster, Dec 24/2020
-------------------------------------------------

-- Library declarations
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ni_fifo is
    generic
    (
        fifoWidth : integer 16;
        fifoDepth : integer 16
    );

    port
    (
        -- Clocking control
        clk, rst : in std_logic;
        -- FIFO Control
        popEn, writeEn : in std_logic;
        -- Data
        dataIn : in std_logic_vector (fifoWidth-1 downto 0);
        dataOut : out std_logic_vector (fifoWidth-1 downto 0)
    );
end ni_fifo;


