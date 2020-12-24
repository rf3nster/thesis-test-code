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

-- Entity
entity ni_fifo is
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
end ni_fifo;

-- Architecture
architecture ni_fifo_impl of ni_fifo is
    -- Type definition
    type fifo_t is array (fifoDepth - 1 downto 0) of std_logic_vector (fifoWidth - 1 downto 0);
    -- Create FIFO
	signal fifo : fifo_t := (others => (others => '0'));
    -- FIFO Pointers
    signal fifoCounter : integer range 0 to fifoDepth := 0;
    signal fifoReadPoint, fifoWritePoint : integer range 0 to fifoDepth - 1 := 0;
    -- Internal FIFO Status signals
    signal fifoEmpty_i, fifoFull_i : std_logic;
    signal fifoAlmostEmpty_i, fifoAlmostFull_i : std_logic;
    
    begin
        write_proc: process (clk, rst)
            begin
                -- The great reset
                if (rst = '1') then
                    fifoWritePoint <= 0;
                    for i in 0 to fifoDepth-1 loop
                        fifo(i) <= (others => '0');
                    end loop;
                elsif (rising_edge(clk)) then
                    -- Do write if not full
                    if (writeEn = '1' and fifoFull_i = '0') then
                        if (dualWriteEn = '1') then
                            fifo(fifoWritePoint) <= dataIn (fifoWidth - 1 downto 0);
                            fifo(fifoWritePoint + 1) <= dataIn (fifoDoubleWidth - 1 downto fifoWidth);
                            -- Pointer wrap around check
                            if (fifoWritePoint = fifoDepth - 2) then
                                fifoWritePoint <= 0;
                            else
                                fifoWritePoint <= fifoWritePoint + 2;
                            end if;
                        else
                            -- Check to see if writing upper set of dataIn or not
                            if (writeUpper = '1') then
                                fifo(fifoWritePoint) <= dataIn (fifoDoubleWidth - 1 downto fifoWidth);
                            else
                                fifo(fifoWritePoint) <= dataIn (fifoWidth - 1 downto 0);
                            end if;
                            -- Pointer wrap around check
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
                    -- Do a read if not empty
                    if (popEn = '1' and fifoEmpty_i = '0') then
                        -- Wrap around check
                        if (fifoReadPoint = fifoDepth - 1) then
                            fifoReadPoint <= 0;
                        else
                            fifoReadPoint <= fifoReadPoint + 1;
                        end if;
                    else
                    end if;
                end if;
        end process;

        counter_proc: process (fifoReadPoint, fifoWritePoint)
            begin
                fifoCounter <= abs(fifoWritePoint - fifoReadPoint);
        end process;

    -- Combinational assignments
    fifoEmpty_i <= '1' when fifoCounter = 0 else
                   '0';

    fifoFull_i <= '1' when ((dualWriteEn = '1' and fifoCounter >= fifoDepth-1) or (dualWriteEn = '0' and fifoCounter = fifoDepth)) else
                '0';

    fifoAlmostEmpty_i <= '1' when (fifoCounter = 1) else
                       '0';
    fifoAlmostFull_i <= '1' when (((fifoCounter = fifoDepth-1) and dualWriteEn = '0') or ((fifoCounter = fifoDepth-2) and dualWriteEn = '1')) else
                        '0';
    -- Signal assignments to outside world
    fifoEmpty <= fifoEmpty_i;
    fifoFull <= fifoFull_i;    
    fifoAlmostEmpty <= fifoAlmostEmpty_i;
    fifoAlmostFull <= fifoAlmostFull_i;
    dataOut <= fifo(fifoReadPoint);    
end ni_fifo_impl;
