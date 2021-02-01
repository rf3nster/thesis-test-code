-------------------------------------------------
-- Approximate Network on Chip RX Write FSM
-- Purpose:
--      Finite State Machine for receiver
--      and processing elements.
--      Control FIFOs and writing to them
--  Requires: VHDL-2008
--  Rick Fenster, Jan 26/2021
--  Updated on Jan 29/2021
-------------------------------------------------

-- Library declarations
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ni_rx_write_fsm is
    port
    (
        -- General control
        clk, rst : in std_logic;
        -- FIFO status signals
        fifoFull : in std_logic;      
        -- FIFO Control signals
        fifoWriteEn : out std_logic;
        -- Channel control signal
        channelValid : in std_logic;
        clearToSend : out std_logic
    );

end ni_rx_write_fsm;

architecture ni_rx_write_fsm_impl of ni_rx_write_fsm is
    -- Define receiver pop state
    type fsm_state_t is (rxWriteState_IDLE, rxWriteState_EN);
    signal fsm_state, fsm_state_next : fsm_state_t := rxWriteState_IDLE;  
    begin
        -- State transition process
        state_transition_proc: process (clk, rst)
            begin  
                if (rst = '1') then
                    fsm_state <= rxWriteState_IDLE;
                elsif (rising_edge(clk)) then
                    fsm_state <= fsm_state_next;
                end if;
        end process;

        state_comb_proc: process (fifoFull, channelValid, fsm_state)
        begin

            -- Case for FIFO Write State
            case fsm_state is
                -- Write and idle state
                when rxWriteState_EN | rxWriteState_IDLE =>
                    if (fifoFull = '0' and channelValid = '1') then
                        fsm_state_next <= rxWriteState_EN;
                        fifoWriteEn <= '1';
                    else
                        fsm_state_next <= rxWriteState_IDLE;
                        fifoWriteEn <= '0';
                    end if; 
                    
                -- Idle/Others        
                when others =>
                    if (fifoFull = '0' and channelValid = '1') then
                        fsm_state_next <= rxWriteState_EN;
                        fifoWriteEn <= '1';
                    else
                        fsm_state_next <= rxWriteState_IDLE;
                        fifoWriteEn <= '0';
                    end if; 
            end case;
    end process;

    -- Concurrent signal assignment
    clearToSend <= not(fifoFull);
end ni_rx_write_fsm_impl;