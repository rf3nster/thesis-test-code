-------------------------------------------------
-- Approximate Network on Chip Data RX FIFO
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
entity ni_rx_data_fifo is
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
        fifoEmpty, fifoFull, fifoAlmostFull, fifoAlmostEmpty : out std_logic;
        -- Data
        dataIn : in std_logic_vector (fifoWidth - 1 downto 0);
        dataOut : out std_logic_vector (fifoWidth * 2 - 1 downto 0)
    );
end ni_rx_data_fifo;


-- Architecture
architecture ni_rx_data_fifo_impl of ni_rx_data_fifo is
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
                    -- Do write
                    if (fifoFull_i = '0' and writeEn = '1' and fifoFull_i = '0') then
                        fifo(fifoWritePoint) <= dataIn;
                        -- Increment pointer
                        if (fifoWritePoint = fifoDepth - 1) then
                            fifoWritePoint <= 0;
                        else
                            fifoWritePoint <= fifoWritePoint + 1;
                        end if;
                    end if;


                end if;
        end process;

        read_proc: process (clk, rst)
            begin
                if (rst = '1') then
                    fifoReadPoint <= 0;
                elsif (rising_edge(clk)) then
                    if (popEn = '1' and dualOutputEn = '1' and fifoEmpty_i = '0') then
                        -- Check if wrap around is needed
                        if (fifoReadPoint = fifoDepth - 2) then
                            fifoReadPoint <= 0;
                        else
                            fifoReadPoint <= fifoReadPoint + 2;
                        end if;
                    elsif (popEn = '1' and dualOutputEn = '0' and fifoEmpty_i = '0') then
                        -- Check if wrap around is needed
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
                elsif (rising_edge(clk)) then
                    if (writeEn = '1' and fifoFull_i = '0' and popEn = '0') then
                        fifoCounter <= fifoCounter + 1;
                    elsif (writeEn = '1' and fifoFull_i = '0' and popEn = '1' and dualOutputEn = '0' and fifoEmpty_i = '0') then
                        fifoCounter <= fifoCounter;
                    elsif (writeEn = '1' and fifoFull_i = '0' and popEn = '1' and dualOutputEn = '1' and fifoEmpty_i = '0') then
                        fifoCounter <= fifoCounter - 1;
                    elsif (writeEn = '0' and popEn = '1' and dualOutputEn = '0' and fifoEmpty_i = '0') then
                        fifoCounter <= fifoCounter - 1;
                        elsif (writeEn = '0' and popEn = '1' and dualOutputEn = '1' and fifoEmpty_i = '0') then
                            fifoCounter <= fifoCounter - 2;                        

                    end if;                    
                end if;
        end process;


    -- Combinational signals for Empty, Almost Empty, Full and Almost Full
    fifoEmpty_i <= '1' when (fifoCounter = 0) or (fifoCounter = 1 and dualOutputEn = '1') or  (fifoCounter = 0 and dualOutputEn = '1')
                else '0';
    fifoFull_i <= '1' when ((fifoCounter = fifoDepth)) 
                else '0';
    fifoAlmostEmpty_i <= '1' when (fifoCounter = 1 and dualOutputEn = '0') or (fifoCounter = 2 and dualOutputEn = '1')
                else '0';
    fifoAlmostFull_i <= '1' when (fifoCounter = fifoDepth - 1 and dualOutputEn = '0') or ((fifoCounter = fifoDepth - 2 or fifoCounter = fifoDepth - 1) and dualOutputEn = '1')
                else '0';
    

    -- Cast data output signals
    fifoDataOut_lower_i <= fifo(fifoReadPoint);
    fifoDataOut_upper_i <= fifo(0) when (fifoReadPoint = fifoDepth - 1)
                else fifo(fifoReadPoint + 1);
    -- Cast signals to outside world
    fifoEmpty <= fifoEmpty_i;
    fifoAlmostEmpty <= fifoAlmostEmpty_i;
    fifoFull <= fifoFull_i;
    fifoAlmostFull <= fifoAlmostFull_i;
    -- Cast output signals
    dataOut(fifoWidth - 1 downto 0) <= fifoDataOut_lower_i;
    dataOut(fifoWidth * 2 - 1 downto fifoWidth) <= fifoDataOut_upper_i when (dualOutputEn = '1') 
                else (others => '0');
                        
end ni_rx_data_fifo_impl;
