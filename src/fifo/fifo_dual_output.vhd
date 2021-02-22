-------------------------------------------------
-- Dual Output FIFO
-- Purpose:
--      Expandable FIFO used for network 
--      interface. Uses generics for size. Pops
--      and pushes on positive clock edges, async
--      reset. Can output two adjacent cells at
--      once.
--  Requires: VHDL-2008
--  Rick Fenster, Jan 25/2021
-------------------------------------------------

-- Library declarations
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity
entity fifo_dual_output is
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
end fifo_dual_output;


-- Architecture
architecture fifo_dual_output_impl of fifo_dual_output is
    -- Type definition
    type fifo_t is array (fifoDepth - 1 downto 0) of std_logic_vector (fifoWidth - 1 downto 0);
    -- Create FIFO
	signal fifo : fifo_t := (others => (others => '0'));
    -- FIFO Pointers
    signal fifoCounter : integer range 0 to fifoDepth := 0;
    signal fifoReadPoint, fifoWritePoint : integer range 0 to fifoDepth - 1 := 0;
    -- Internal FIFO Status signals
    signal fifoEmpty_i, fifoFull_i : std_logic;
    signal fifoDataOut_lower_i, fifoDataOut_upper_i : std_logic_vector (fifoWidth - 1 downto 0);
    
    begin
        write_proc: process (clk, rst)
            begin
                -- If reset is asserted, clear everything and reset pointer
                if (rst = '1') then
                    for i in  0 to fifoDepth - 1 loop
                        fifo(i) <= (others => '0');
                    end loop;
                    fifoWritePoint <= 0;

                elsif (rising_edge(clk)) then
                    if (fifoFull_i = '0' and writeEn = '1') then
                        fifo(fifoWritePoint) <= dataIn;
                        -- Wrap around check for fifo write counter
                        if (fifoWritePoint = fifoDepth - 1) then
                            fifoWritePoint <= 0;
                        else
                            fifoWritePoint <= fifoWritePoint + 1;
                        end if;
                    end if;
                end if;
        end process;

        counter_proc : process (clk, rst)
            begin
                if (rst = '1') then
                    fifoCounter <= 0;
                elsif (rising_edge(clk)) then
                    -- Write only scenarios                    
                    if (writeEn = '1' and popEn = '0') then
                        -- When FIFO is not full
                        if (fifoFull_i = '0') then
                            fifoCounter <= fifoCounter + 1;
                        -- When FIFO is full
                        elsif (fifoFull_i = '1') then
                            fifoCounter <= fifoCounter;
                        end if;
                    -- Pop only scenarios
                    elsif (popEn = '1' and writeEn = '0') then
                        -- Check if dualoutput is enabled and fifo is not empty
                        if (dualOutputEn = '1' and fifoEmpty_i = '0') then
                            fifoCounter <= fifoCounter - 2;
                        elsif (dualOutputEn = '0' and fifoEmpty_i = '0') then
                            fifoCounter <= fifoCounter - 1;
                        end if;
                    -- Write and pop scenarios
                    elsif (popEn = '1' and writeEn = '1') then
                        -- Check if dualOutput Mode is enabled
                        if (dualOutputEn = '1') then
                            -- If fifo is full
                            if (fifoFull_i = '1' and fifoEmpty_i = '0') then
                                fifoCounter <= fifoCounter - 2;
                            -- If fifo is empty
                            elsif (fifoFull_i = '0' and fifoEmpty_i = '1') then
                                fifoCounter <= fifoCounter + 1;                            
                            -- If fifo is not full or empty
                            elsif (fifoFull_i = '0' and fifoEmpty_i = '0') then
                                fifoCounter <= fifoCounter - 1;
                            end if;
                        else
                                -- If fifo is full
                                if (fifoFull_i = '1' and fifoEmpty_i = '0') then
                                    fifoCounter <= fifoCounter - 1;
                                -- If fifo is empty
                                elsif (fifoFull_i = '0' and fifoEmpty_i = '1') then 
                                    fifoCounter <= fifoCounter + 1;                           
                                -- If fifo is not full or empty
                                elsif (fifoFull_i = '0' and fifoEmpty_i = '0') then
                                    fifoCounter <= fifoCounter;
                                end if;
                        end if;    
                    end if;
                end if;
        end process;

        pop_proc : process (clk, rst)
            begin
                if (rst = '1') then
                    fifoReadPoint <= 0;
                elsif (rising_edge(clk)) then
                    -- If popping
                    if (popEn = '1' and fifoEmpty_i = '0') then
                        -- Check if dual output
                        if (dualOutputEn = '1') then
                            -- Check for wrap around
                            if (fifoReadPoint = fifoDepth - 2) then
                                fifoReadPoint <= 0;
                            else
                                fifoReadPoint <= fifoReadPoint + 2;
                            end if;
                        else
                            if (fifoReadPoint = fifoDepth - 1) then
                                fifoReadPoint <= 0;
                            else
                                fifoReadPoint <= fifoReadPoint + 1;
                            end if;                            
                        end if;
                    end if;
                end if;
        end process; 

        fifoFull_i <= '1' when (fifoCounter = fifoDepth) else
                      '0';
        fifoFull <= fifoFull_i;

        fifoEmpty_i <= '1' when ((fifoCounter = 0) or (fifoCounter = 1 and dualOutputEn = '1')) else
                       '0';
        fifoEmpty <= fifoEmpty_i;
        -- Lower 16 bit output
        fifodataOut_lower_i <= fifo(fifoReadPoint);
        dataOut (fifoWidth - 1 downto 0) <= fifodataOut_lower_i;
        -- Upper 16 bit output
        fifodataOut_upper_i <= fifo(fifoReadPoint + 1) when (dualOutputEn = '1') else
            (others => '0');
        dataOut ((fifoWidth * 2) - 1 downto fifoWidth) <= fifodataOut_upper_i;
end fifo_dual_output_impl;
