-------------------------------------------------
-- Approximate Network on Chip Address FIFO
-- Purpose:
--      Expandable FIFO used for network 
--      interface. Uses generics for size. Pops
--      and pushes on positive clock edges, async
--      reset. Reduced functionality aimed for
--      addressing.
--  Requires: VHDL-2008
--  Rick Fenster, Jan 12/2021
-------------------------------------------------

-- Library declarations
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity
entity ni_addr_fifo is
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
end ni_addr_fifo;

-- Architecture
architecture ni_addr_fifo_impl of ni_addr_fifo is
    -- Type definition
    type fifo_t is array (fifoDepth - 1 downto 0) of std_logic_vector (fifoWidth - 1 downto 0);
    -- Create FIFO
	signal fifo : fifo_t := (others => (others => '0'));
    -- FIFO Pointers
    signal fifoCounter : integer range 0 to fifoDepth := 0;
    signal fifoReadPoint, fifoWritePoint : integer range 0 to fifoDepth - 1 := 0;
    -- Internal FIFO Status signals
    signal fifoEmpty_i, fifoFull_i : std_logic;
    
    begin
        write_proc: process (clk, rst)
            begin
                if (rst = '1') then
                    fifoWritePoint <= 0;
                    for i in 0 to fifoDepth - 1 loop
                        fifo(i) <= (others => '0');
                    end loop;
                elsif (rising_edge(clk)) then
                    -- Check if dual write enabled
                    if (writeEn = '1' and dualWriteEn = '0' and fifoFull_i = '0') then
                        fifo(fifoWritePoint) <= dataIn;
                        -- Check for wrap around
                        if (fifoWritePoint = (fifoDepth - 1)) then
                            fifoWritePoint <= 0;
                        else
                            fifoWritePoint <= fifoWritePoint + 1;
                        end if;
                    -- If dual write
                    elsif (writeEn = '1' and dualWriteEn = '1' and fifoFull_i = '0') then
                        fifo(fifoWritePoint) <= dataIn;
                        fifo(fifoWritePoint + 1) <= dataIn;
                        -- Check for wrap around
                        if (fifoWritePoint = (fifoDepth - 2)) then
                            fifoWritePoint <= 0;
                        else
                            fifoWritePoint <= fifoWritePoint + 2;
                        end if;
                    end if;
                end if;
        end process;

        read_proc: process (clk, rst)
            begin
                if (rst = '1') then
                    fifoReadPoint <= 0;
                elsif (rising_edge(clk)) then
                    if (fifoEmpty_i = '0' and popEn = '1') then
                        -- Check for wrap around
                        if (fifoReadPoint = (fifoDepth - 1)) then
                            fifoReadPoint <= 0;
                        else
                            fifoReadPoint <= fifoReadPoint + 1;
                        end if;
                    end if;
                end if;
        end process;
    -- Counter shenanigans
    counter_proc : process (rst, clk)
        begin
            if (rst = '1') then
                fifoCounter <= 0;
            elsif (rising_edge(clk)) then
                -- Write only
                if (writeEn = '1' and popEn = '0') then
                    -- Write when dualWrite is enabled
                    if (dualWriteEn = '1' and fifoFull_i = '0') then
                        fifoCounter <= fifoCounter + 2;
                    -- Write when dualWrite is disabled
                    elsif (dualWriteEn = '0' and fifoFull_i = '0') then
                        fifoCounter <= fifoCounter + 1;
                    end if;
                -- Pop only
                elsif (writeEn = '0' and popEn = '1') then
                    if (fifoEmpty_i = '0') then 
                        fifoCounter <= fifoCounter - 1;
                    end if;
                -- Write and Pop at same time
                elsif (writeEn = '1' and popEn = '1') then
                    if (dualWriteEn = '1') then
                        -- Pop and Write, dual write when not full or empty
                        if (fifoFull_i = '0' and fifoEmpty_i = '0') then
                            fifoCounter <= fifoCounter + 1;
                        -- Pop and Write, dual write when full 
                        elsif (fifoFull_i = '1' and fifoEmpty_i = '0') then
                            fifoCounter <= fifoCounter - 1;
                        -- Pop and Write, dual write when empty 
                        elsif (fifoFull_i = '0' and fifoEmpty_i = '1') then
                            fifoCounter <= fifoCounter + 2;
                        end if;
                    else  
                        -- Pop and Write, no dual write when not full or empty
                        if (fifoFull_i = '0' and fifoEmpty_i = '0') then
                            fifoCounter <= fifoCounter;
                        -- Pop and Write, no dual write when full
                        elsif (fifoFull_i = '1' and fifoEmpty_i = '0') then
                            fifoCounter <= fifoCounter - 1;
                        -- Pop and write, no dual write when empty
                        elsif (fifoFull_i = '0' and fifoEmpty_i = '1') then
                            fifoCounter <= fifoCounter + 1;
                        end if;
                    end if;
                end if;
            end if;
    end process;

    dataOut <= fifo(fifoReadPoint);
    fifoEmpty_i <= '1' when (fifoCounter = 0) else
                   '0';
    fifoFull_i <= '1' when (fifoCounter = fifoDepth) else
                  '0';
    fifoFull <= fifoFull_i;
    fifoEmpty <= fifoEmpty_i;
end ni_addr_fifo_impl;
