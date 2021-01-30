-------------------------------------------------
-- Approximate Network on Chip Shared Component Pkg
-- Purpose:
--      Stores declarations for shared components
--      for RX and TX.
--  Requires: VHDL-2008
--  Rick Fenster, Jan 30/2021
-------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package ni_shared_components is


-- Address FIFO Declaration
component ni_addr_fifo is
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
end component ni_addr_fifo;

end package ni_shared_components;