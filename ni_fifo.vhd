-- Network Interface FIFO
-- Circular implementation
-- FIFO wraps around to avoid shifting
-- Rick Fenster
-- Nov 9/2020  

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ni_fifo is
	-- Size declarations
	generic (
		fifoDepth : integer := 4;
		fifoWidth : integer := 8
	); 
		
	port (
		clk, rst, writeEnable, popEnable : in std_logic;
		dataIn : in std_logic_vector(fifoWidth - 1 downto 0);
		dataOut : out std_logic_vector (fifoWidth-1 downto 0);
		fifoFull : out std_logic ;
		fifoEmpty : out std_logic
		);
		
end ni_fifo;

architecture fifo_rtl of ni_fifo is
	-- Define FIFO type and instance it
	type fifo_t is array (fifoDepth-1 downto 0) of std_logic_vector (fifoWidth-1 downto 0);
	signal fifo : fifo_t := (others => (others => '0'));
	-- Define FIFO indices for reading and writing
	signal fifoReadIndex, fifoWriteIndex : integer range 0 to fifoDepth-1;
	-- Define FIFO flags
	signal fifoFull_sig : std_logic := '0';	
	signal fifoEmpty_sig : std_logic;
	-- Define FIFO counter
	signal fifoCounter : integer range 0 to fifoDepth+1 := 0; 
	begin
		process (rst, clk)
		begin
			-- Check for reset
			if (rst = '1') then
				-- Clear FIFO
				for i in fifoDepth-1 downto 0 loop
					fifo(i) <= (others => '0');
				end loop;
				-- Reset signals and indices
				fifoReadIndex <= 0;
				fifoWriteIndex <= 0;
				fifoCounter <= 0;
			elsif (rising_edge(clk)) then
				-- Write to register if not full
				if (writeEnable = '1' and fifoFull_sig = '0') then
					-- Control wrap-around if at bounds
					if (fifoWriteIndex = fifoDepth - 1) then
						fifoWriteIndex <= 0;
					else
						fifoWriteIndex <= fifoWriteIndex + 1;
					end if;
					fifo(fifoWriteIndex) <= dataIn;
					fifoCounter <= fifoCounter + 1;
				end if;
			elsif (falling_edge(clk)) then
				-- Read data if not empty
				if (popEnable = '1' and fifoEmpty_sig = '0') then
					fifoCounter <= fifoCounter - 1;
					if (fifoReadIndex = fifoDepth - 1) then
						fifoReadIndex <= 0;
					else
						fifoReadIndex <= fifoReadIndex + 1;
					end if;
				end if;
			end if;
		end process;
		
		-- Process to update FIFO status signals and clear out registers
		process (fifoCounter)
		begin
			-- If full, say so
			if (fifoCounter = fifoDepth) then
				fifoFull_sig <= '1';
			-- If empty, say so
			elsif (fifoCounter = 0) then
				fifoEmpty_sig <= '1';				
			else
				fifoFull_sig <= '0';
				fifoEmpty_sig <= '0';
			end if;
		end process;
			
		-- Static signal assignments to outputs	
		fifoFull <= fifoFull_sig;
		fifoEmpty <= fifoEmpty_sig;
		dataOut <= fifo(fifoReadIndex);
end fifo_rtl;