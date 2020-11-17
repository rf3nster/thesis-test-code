-- Network Interface Test
-- Basic Duplex Network Interface
-- Rick Fenster
-- Nov 2/2020

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity network_interface is	
	generic(
		approxFIFODepth : integer := 4;
		approxFIFOWidth : integer := 16;
		accurateFIFODepth : integer := 4;
		accurateFIFOWidth : integer := 32;
		injectionFIFOWidth : integer := 33;
		injectionFIFODepth : integer := 4
	);
	
	port(
		-- Basic controls
		clk : in std_logic;
		rst : in std_logic;
		
		-- Injection FIFO Data and Control
		injectionPayload : in std_logic_vector (injectionFIFOWidth-2 downto 0);
		isInjectionApproximate : in std_logic;
		injectionFIFOWriteEn : in std_logic;
		-- Injection FIFO Status
		injectionFIFOEmpty : out std_logic;
		injectionFIFOFull : out std_logic	
	
	);
end network_interface;		  

architecture ni_rtl of network_interface is
	-- Define FIFO Component
	component ni_fifo is
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
		
	end component;
	

	-- Signals for reading status
	signal injectionFIFO_Empty_sig : std_logic;
	signal injectionFIFO_Full_sig: std_logic;
	signal injectionFIFO_popEnable : std_logic;
	signal injectionFIFO_DataOut : std_logic_vector (injectionFIFOWidth-1 downto 0);
	signal injectionFIFO_DataIn : std_logic_vector (injectionFIFOWidth-1 downto 0);	
	

	-- Test signals for accurate FIFO
	signal accurateFIFO_dataIn : std_logic_vector (accurateFIFOWidth-1 downto 0);
	signal accurateFIFO_dataOut : std_logic_vector (accurateFIFOWidth-1 downto 0);
	signal accurateFIFO_Full : std_logic;
	signal accurateFIFO_Empty : std_logic;
	signal accurateFIFO_pop : std_logic := '0';
	signal accurateFIFO_writeEnable : std_logic := '0';

	-- Test signals for approximate FIFO
	signal approxFIFO_dataIn : std_logic_vector(approxFIFOWidth-1 downto 0);
	signal approxFIFO_dataOut : std_logic_vector(approxFIFOWidth-1 downto 0);
	signal approxFIFO_Full : std_logic;
	signal approxFIFO_Empty : std_logic;
	signal approxFIFO_pop : std_logic := '0';
	signal approxFIFO_writeEnable : std_logic := '0';
	
	-- Bookkeeping signals
	signal accurateFIFO_writeLastCycle : std_logic ;
	signal approxFIFO_writeLastCycle : std_logic ;
	begin
		
		-- Instantiate Injection FIFO
		injectionFIFO : ni_fifo
			generic map(
				fifoDepth => injectionFIFODepth, fifoWidth => injectionFIFOWidth
			)
			
			port map(
			clk => clk, rst => rst, writeEnable => injectionFIFOWriteEn, popEnable => injectionFIFO_popEnable,
			dataIn => injectionFIFO_DataIn, dataOut => injectionFIFO_DataOut, fifoFull => injectionFIFO_Full_sig,
			fifoEmpty => injectionFIFO_Empty_sig
			);
			
		-- Instantiate Accurate FIFO
		accurateFIFO : ni_fifo
			generic map(
				fifoDepth => accurateFIFODepth, fifoWidth => accurateFIFOWidth
			)
			
			port map(
			clk => clk , rst => rst, writeEnable => accurateFIFO_writeEnable, popEnable => accurateFIFO_pop,
			dataIn => accurateFIFO_dataIn, dataOut => accurateFIFO_dataOut, fifoFull => accurateFIFO_Full,
			fifoEmpty => accurateFIFO_Empty
			);
			
		-- Instantiate Approximate FIFO
		approxFIFO : ni_fifo
			generic map(
				fifoDepth => approxFIFODepth, fifoWidth => approxFIFOWidth
			)
			
			port map(
			clk => clk , rst => rst, writeEnable => approxFIFO_writeEnable, popEnable => approxFIFO_pop,
			dataIn => approxFIFO_dataIn, dataOut => approxFIFO_dataOut, fifoFull => approxFIFO_Full,
			fifoEmpty => approxFIFO_Empty
			);
			
		-- Concurrent Signal assignments
		injectionFIFOEmpty <= injectionFIFO_Empty_sig;
		injectionFIFOFull <= injectionFIFO_Full_sig;
		injectionFIFO_DataIn (injectionFIFOWidth-1) <= isInjectionApproximate;
		injectionFIFO_DataIn ((injectionFIFOWidth -2) downto 0) <= injectionPayload;
		
		-- More concurrent signal assignments
		
		accurateFIFO_dataIn <= injectionFIFO_DataOut(injectionFIFOWidth-2 downto 0);
		approxFIFO_dataIn <= injectionFIFO_DataOut(approxFIFOWidth-1 downto 0);
		-- Process to write into Accurate Data FIFO

		process (rst, clk)

			begin
			if (rising_edge(clk)) then 
				-- Check to see if accurate FIFO was written to, and if so, pop FIFO
				if (accurateFIFO_writeLastCycle = '1' or approxFIFO_writeLastCycle = '1') then
					injectionFIFO_popEnable <= '1';
				else
					injectionFIFO_popEnable <= '0';
				end if;
			end if;
		end process;
		

			
		-- Concurrent signal assignments
		accurateFIFO_writeEnable <= '1'
			when (injectionFIFO_Empty_sig = '0' and accurateFIFO_Full = '0' and (injectionFIFO_dataOut(injectionFIFOWidth-1) = '0'))
			else '0';
		accurateFIFO_writeLastCycle <= accurateFIFO_writeEnable;
		approxFIFO_writeEnable <= '1'
			when (injectionFIFO_Empty_sig = '0' and approxFIFO_Full = '0' and (injectionFIFO_dataOut(injectionFIFOWidth-1) = '1'))
			else '0';
		approxFIFO_writeLastCycle <= approxFIFO_writeEnable;		
		
				
				
end ni_rtl;
					   			 