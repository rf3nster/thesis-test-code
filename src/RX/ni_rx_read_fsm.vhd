-------------------------------------------------
-- Approximate Network on Chip RX Read FSM
-- Purpose:
--      Finite State Machine for receiver
--      and processing elements.
--      Control FIFOs and popping from them
--  Requires: VHDL-2008
--  Rick Fenster, Jan 26/2021
--  Updated on Jan 29/2021
-------------------------------------------------

-- Library declarations
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ni_rx_read_fsm is
    port
    (
        -- General control
        clk, rst : in std_logic;
        -- FIFO status signals
        fifoAEmpty : in std_logic;
        fifoBEmpty : in std_logic;       
        -- FIFO Control signals
        fifoAPopEn : out std_logic;
        fifoBPopEn : out std_logic;        
        fifoPopRqst : in std_logic;
        networkMode : in std_logic;
        dataType, dataAvailable : out std_logic;
        -- Channel control
        dataValid : out std_logic
    );

end ni_rx_read_fsm;

architecture ni_rx_read_fsm_impl of ni_rx_read_fsm is
    -- Define receiver pop state
    type fsm_state_t is (rxPopState_IDLE, rxPopState_APX, rxPopState_ACC);
    signal fsm_state, fsm_state_next : fsm_state_t := rxPopState_IDLE;  
    begin
        -- State transition process
        state_transition_proc: process (clk, rst)
            begin  
                if (rst = '1') then
                    fsm_state <= rxPopState_IDLE;
                elsif (rising_edge(clk)) then
                    fsm_state <= fsm_state_next;
                end if;
        end process;

        state_comb_proc: process (fifoAEmpty, fifoBEmpty, fsm_state, networkMode, fifoPopRqst)
        begin
            -- By default, go back to idle states
            fsm_state_next <= rxPopState_IDLE;
            fifoAPopEn <= '0';
            fifoBPopEn <= '0';

            -- Case for FIFO Write State
            case fsm_state is
                -- Idle state
                when rxPopState_IDLE | rxPopState_ACC =>
                    -- When in accurate only mode and data is present
                    if (fifoAEmpty = '0' and fifoBEmpty = '0' and networkMode = '0' and fifoPopRqst = '1') then
                        fifoAPopEn <= '1';
                        fifoBPopEn <= '1';                        
                        fsm_state_next <= rxPopState_ACC;
                    -- If network mode is mixed and approx data (channel B) is present (priority)
                    elsif (networkMode = '1' and fifoBEmpty = '0' and fifoPopRqst = '1') then
                        fifoAPopEn <= '0';                        
                        fifoBPopEn <= '1';
                        fsm_state_next <= rxPopState_APX;
                    -- If network mode ix mixed and accurate data (channel A) is present
                    elsif (networkMode = '1' and fifoAEmpty = '0' and fifoBEmpty = '1' and fifoPopRqst = '1') then
                        fifoAPopEn <= '1';                        
                        fifoBPopEn <= '0';
                        fsm_state_next <= rxPopState_ACC;                        
                    -- Fall back to idle
                    else
                        fifoAPopEn <= '0';                        
                        fifoBPopEn <= '0';
                        fsm_state_next <= rxPopState_IDLE;    
                    end if;
                
                -- Approx state
                when rxPopState_APX =>
                    -- When in accurate only mode and data is present
                    if (fifoAEmpty = '0' and fifoBEmpty = '0' and networkMode = '0' and fifoPopRqst = '1') then
                        fifoAPopEn <= '1';
                        fifoBPopEn <= '1';                        
                        fsm_state_next <= rxPopState_ACC;
                    -- If network mode is mixed and accurate data (channel A) is present (priority)
                    elsif (networkMode = '1' and fifoAEmpty = '0' and fifoPopRqst = '1') then
                        fifoAPopEn <= '1';                        
                        fifoBPopEn <= '0';
                        fsm_state_next <= rxPopState_ACC;
                    -- If network mode is mixed and accurate data (channel A) is present
                    elsif (networkMode = '1' and fifoAEmpty = '1' and fifoBEmpty = '0' and fifoPopRqst = '1') then
                        fifoAPopEn <= '0';                        
                        fifoBPopEn <= '1';
                        fsm_state_next <= rxPopState_APX;                        
                    -- Fall back to idle
                    else
                        fifoAPopEn <= '0';                        
                        fifoBPopEn <= '0';
                        fsm_state_next <= rxPopState_IDLE;    
                    end if;                


                when others =>
                        fifoAPopEn <= '0';
                        fifoBPopEn <= '0'; 
                        fsm_state_next <= rxPopState_IDLE; 
            end case;
    end process;

    -- Add concurrent signal assignments
    dataAvailable <= NOT(fifoAEmpty) or NOT(fifoBEmpty);
    dataType <= '1' when (fsm_state = rxPopState_APX) else
                '0';

    dataValid <= '1' when ((fsm_state = rxPopState_ACC) or (fsm_state = rxPopState_APX)) else
                '0';

end ni_rx_read_fsm_impl;