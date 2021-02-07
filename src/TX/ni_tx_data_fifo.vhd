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

library work;
use work.ni_shared_components.all;

-- Entity
entity ni_tx_data_fifo is
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
end ni_tx_data_fifo;

-- Architecture
architecture ni_tx_data_fifo_impl of ni_tx_data_fifo is
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
                            fifo(fifoWritePoint + 1) <= dataIn (fifoDoubleWidth - 1 downto fifoWidth);

                            -- Do pointer increase
                            if (fifoWritePoint = fifoDepth - 2) then
                                fifoWritePoint <= 0;
                            else
                                fifoWritePoint <= fifoWritePoint + 2;
                            end if;
                        -- Otherwise, do single write
                        else
                            if (writeUpper = '1') then
                                fifo(fifoWritePoint) <= dataIn (fifoDoubleWidth - 1 downto fifoWidth);
                            else
                                fifo(fifoWritePoint) <= dataIn (fifoWidth - 1 downto 0);
                            end if;

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

                    -- Single write
                    -- Write when no dual write enabled, no pop
                    if (fifoFull = '0' and popEn = '0' and writeEn = '1' and dualWriteEn = '0') then
                        fifoCounter <= fifoCounter + 1;
                    end if;
                    -- Write when no dual write enabled but pop is enabled, FIFO is empty
                    if (fifoFull = '0' and fifoEmpty = '1' and popEn = '1' and writeEn = '1' and dualWriteEn = '0') then
                        fifoCounter <= fifoCounter + 1;
                    end if;
                    -- Write when no dual write enabled but pop is enabled, FIFO is not empty
                    if (fifoFull = '0' and fifoEmpty = '1' and popEn = '1' and writeEn = '1' and dualWriteEn = '0') then
                        fifoCounter <= fifoCounter ;
                    end if;

                    -- Double write
                    if (fifoFull = '0' and popEn = '0' and writeEn = '1' and dualWriteEn = '1') then
                        fifoCounter <= fifoCounter + 2;
                    end if;
                    -- Write when dual write enabled but pop is enabled, FIFO is empty
                    if (fifoFull = '0' and fifoEmpty = '1' and popEn = '1' and writeEn = '1' and dualWriteEn = '1') then
                        fifoCounter <= fifoCounter + 2;
                    end if;
                    -- Write when dual write enabled but pop is enabled, FIFO is not empty
                    if (fifoFull = '0' and fifoEmpty = '1' and popEn = '1' and writeEn = '1' and dualWriteEn = '1') then
                        fifoCounter <= fifoCounter + 1;
                    end if;    
                    
                    -- Pop only states
                    -- Pop when FIFO is not empty and no write enabled
                    if (fifoEmpty = '0' and popEn = '1' and writeEn = '0') then
                        fifoCounter <= fifoCounter - 1;
                    end if;
                    -- Pop when FIFO is empty and no write enabled
                    if (fifoEmpty = '1' and popEn = '1' and writeEn = '0') then
                        fifoCounter <= fifoCounter;
                    end if;
                    
                    -- Write and pop states
                    -- Write and pop when not full or empty, no dualwrite
                    if (fifoEmpty = '0' and fifoFull = '0' and popEn = '1' and writeEn = '1' and dualWriteEn = '0') then
                        fifoCounter <= fifoCounter;
                    end if;
                    -- Write and pop when not full or empty, dual write
                    if (fifoEmpty = '0' and fifoFull = '0' and popEn = '1' and writeEn = '1' and dualWriteEn = '1') then
                        fifoCounter <= fifoCounter + 1;
                    end if;
                    -- Write and pop when FIFO is full
                    if (fifoFull = '1' and fifoEmpty = '0' and popEn = '1' and writeEn = '1') then
                        fifoCounter <= fifoCounter - 1;
                    end if;
                    -- Write and pop when FIFO is empty, no dualwrite
                    if (fifoFull = '0' and fifoEmpty = '1' and popEn = '1' and writeEn = '1' and dualWriteEn = '0') then
                        fifoCounter <= fifoCounter + 1;
                    end if;
                    -- Write and pop when FIFO is empty, dual write
                    if (fifoFull = '0' and fifoEmpty = '1' and popEn = '1' and writeEn = '1' and dualWriteEn = '1') then
                        fifoCounter <= fifoCounter + 2;
                    end if;
                end if;
        end process;
        

    -- Combinational signals for Empty, Almost Empty, Full and Almost Full
    fifoEmpty_i <= '1' when (fifoCounter = 0) else
                   '0';
    fifoAlmostEmpty_i <= '1' when (fifoCounter = 1) else
                         '0';
    fifoFull_i <= '1' when (fifoCounter >= fifoDepth - 1 and dualWriteEn = '1') or (fifoCounter = fifoDepth and dualWriteEn = '0') else
                '0';
    fifoAlmostFull_i <= '1' when (fifoCounter = fifoDepth - 2 and dualWriteEn = '1') or (fifoCounter = fifoDepth - 1 and dualWriteEn = '0') else
    '0';

    -- Cast signals to outside world
    fifoEmpty <= fifoEmpty_i;
    fifoAlmostEmpty <= fifoAlmostEmpty_i;
    fifoFull <= fifoFull_i;
    fifoAlmostFull <= fifoAlmostFull_i;
    dataOut <= fifo(fifoReadPoint);
end ni_tx_data_fifo_impl;
