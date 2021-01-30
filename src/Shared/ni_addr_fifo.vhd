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
                    -- If can be written
                    if (fifoFull_i = '0' and writeEn = '1') then
                        -- Check if dual write mode
                        if (dualWriteEn = '1') then
                            fifo(fifoWritePoint) <= dataIn (fifoWidth - 1 downto 0);
                            fifo(fifoWritePoint + 1) <= dataIn (fifoWidth - 1 downto 0);

                            -- Do pointer increase
                            if (fifoWritePoint = fifoDepth - 2) then
                                fifoWritePoint <= 0;
                            else
                                fifoWritePoint <= fifoWritePoint + 2;
                            end if;
                        -- Otherwise, do single write
                        else
                            fifo(fifoWritePoint) <= dataIn (fifoWidth - 1 downto 0);
                            -- Do pointer increase
                            if (fifoWritePoint = fifoDepth - 1) then
                                fifoWritePoint <= 0;
                            else
                                fifoWritePoint <= fifoWritePoint + 1;
                            end if;                                
                        end if;
                    end if;
                end if;
        end process;

        read_proc: process (clk, rst)
            begin
                if (rst = '1') then
                    fifoReadPoint <= 0;
                elsif (rising_edge(clk)) then
                    -- Check if FIFO is not empty, and if so, pop
                    if (popEn = '1' and fifoEmpty_i = '0') then
                        -- Do wrap around
                        if (fifoReadPoint = fifoDepth - 1) then
                            fifoReadPoint <= 0;
                        else
                            fifoReadPoint <= fifoReadPoint + 1;
                        end if;
                    end if;
                end if;
        end process;

        counter_proc: process (clk, rst)
            begin
                if (rst = '1') then
                    fifoCounter <= 0;
                elsif (rising_edge (clk)) then
                    if (writeEn = '1' and fifoFull_i = '0' and dualWriteEn = '1') then
                        fifoCounter <= fifoCounter + 2;
                    elsif (writeEn = '1' and fifoFull_i = '0' and dualWriteEn = '0') then
                        fifoCounter <= fifoCounter + 1;                                                
                    elsif (popEn = '1' and fifoEmpty_i = '0') then
                        fifoCounter <= fifoCounter - 1;
                    elsif (writeEn = '1' and fifoFull_i = '0' and dualWriteEn = '1' and popEn = '1' and fifoEmpty_i = '0') then
                        fifoCounter <= fifoCounter + 1;                         
                    end if;
                end if;
        end process;


    -- Combinational signals for Empty, Almost Empty, Full and Almost Full
    fifoEmpty_i <= '1' when (fifoCounter = 0) else
                   '0';
    fifoFull_i <= '1' when (fifoCounter >= fifoDepth - 1 and dualWriteEn = '1') or (fifoCounter = fifoDepth and dualWriteEn = '0') else
                '0';


    -- Cast signals to outside world
    fifoEmpty <= fifoEmpty_i;
    fifoFull <= fifoFull_i;
    dataOut <= fifo(fifoReadPoint);
end ni_addr_fifo_impl;