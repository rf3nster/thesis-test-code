-------------------------------------------------
-- Approximate Network on Chip Shared Library
-- Purpose:
--      Defines size of network, size of channels,
--      Provides VHDL definitions used elsewhere.
--  Requires: VHDL-2008
--  Rick Fenster, Feb 22/2021
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package shared_noc_parameters is
    -- Data sizes
    constant APX_DATA_SIZE : integer := 16;
    constant ACC_DATA_SIZE : integer := APX_DATA_SIZE * 2;
    constant FIFO_DEPTH : integer := 4;

    -- Network size configuration
    constant X_SIZE : integer := 8;
    constant Y_SIZE : integer := 8;
    constant ADDR_WIDTH : integer := integer(log2(real(X_SIZE)) + log2(real(Y_SIZE)));

    -- Link Record definition
    type noc_link is record
        -- Clear to Send signals
        ctsChannelA : std_logic;
        ctsChannelB : std_logic;
        -- Transmission Valid signals
        channelValidA : std_logic;
        channelValidB : std_logic;
        -- Data Signals
        channelAData : std_logic_vector (APX_DATA_SIZE - 1 downto 0);
        channelBData : std_logic_vector (APX_DATA_SIZE - 1 downto 0);
        -- Address Signals
        addressA : std_logic_vector (ADDR_WIDTH - 1 downto 0);
        addressB : std_logic_vector (ADDR_WIDTH - 1 downto 0);
    end record noc_link;
end package shared_noc_parameters;
