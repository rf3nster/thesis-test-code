-------------------------------------------------
-- Approximate Network on Chip Router 
-- Purpose:
--      Top level of router
--  Requires: VHDL-2008
--  Rick Fenster, Feb 22/2021
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all
use ieee.numeric_std.all;

library work;
use work.shared_noc_parameters.all;

entity noc_router_top is
    generic
    (
        X_COORD : integer range 0 to X_SIZE - 1:= 1;
        Y_COORD : integer range 0 to Y_SIZE - 1:= 1
    );

    port
    (
        -- Control
        clk, rst : in std_logic;

        -- North In
        northDataInA, northDataInB : in std_logic_vector (APX_DATA_SIZE - 1 downto 0);
        northAddrInA, northAddrInB : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
        northChannelAValid, northChannelBValid : in std_logic;

        -- North Out
        northDataOutA, northDataOutB : out std_logic_vector (APX_DATA_SIZE - 1 downto 0);
        northAddrOutA, northAddrOutB : out std_logic_vector (ADDR_WIDTH - 1 downto 0);
        northCTSChannelA, northCTSChannelB : out std_logic;
        
        -- South In
        southDataInA, southDataInB : in std_logic_vector (APX_DATA_SIZE - 1 downto 0);
        southAddrInA, southAddrInB : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
        southChannelAValid, southChannelBValid : in std_logic;

        -- South Out
        southDataOutA, southDataOutB : out std_logic_vector (APX_DATA_SIZE - 1 downto 0);
        southAddrOutA, southAddrOutB : out std_logic_vector (ADDR_WIDTH - 1 downto 0);
        southCTSChannelA, southCTSChannelB : out std_logic;  

        -- West In
        westDataInA, westDataInB : in std_logic_vector (APX_DATA_SIZE - 1 downto 0);
        westAddrInA, westAddrInB : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
        westChannelAValid, westChannelBValid : in std_logic;

        -- West Out
        westDataOutA, westDataOutB : out std_logic_vector (APX_DATA_SIZE - 1 downto 0);
        westAddrOutA, westAddrOutB : out std_logic_vector (ADDR_WIDTH - 1 downto 0);
        westCTSChannelA, westCTSChannelB : out std_logic;     
        
        -- East In
        eastDataInA, eastDataInB : in std_logic_vector (APX_DATA_SIZE - 1 downto 0);
        eastAddrInA, eastAddrInB : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
        eastChannelAValid, eastChannelBValid : in std_logic;

        -- East Out
        eastDataOutA, eastDataOutB : out std_logic_vector (APX_DATA_SIZE - 1 downto 0);
        eastAddrOutA, eastAddrOutB : out std_logic_vector (ADDR_WIDTH - 1 downto 0);
        eastCTSChannelA, eastCTSChannelB : out std_logic;
        
        -- Proc In
        procDataInA, procDataInB : in std_logic_vector (APX_DATA_SIZE - 1 downto 0);
        procAddrInA, procAddrInB : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
        procChannelAValid, procChannelBValid : in std_logic;

        -- Proc Out
        procDataOutA, procDataOutB : out std_logic_vector (APX_DATA_SIZE - 1 downto 0);
        procAddrOutA, procAddrOutB : out std_logic_vector (ADDR_WIDTH - 1 downto 0);
        procCTSChannelA, procCTSChannelB : out std_logic             
    );
end noc_router_top;

architecture noc_router_top_impl of noc_router_top is
    begin
        -- Generate North if not at edge of mesh
        NORTH_LINK : if Y_COORD /= (Y_SIZE - 1) generate
            -- Instance TX and RX
        end generate NORTH_LINK;

        -- Generate South if not at edge of mesh
        SOUTH_LINK : if Y_COORD /= 0 generate
            -- Instance TX and RX
        end generate SOUTH_LINK;     
            
        -- Generate East if not at edge of mesh
        EAST_LINK : if X_COORD /= (X_SIZE - 1) generate
            -- Instance TX and RX
        end generate EAST_LINK; 

        -- Generate West if not at edge of mesh
        WEST_LINK : if X_COORD /= 0 generate
            -- Instance TX and RX
        end generate WEST_LINK;       
       
end noc_router_top_impl;
