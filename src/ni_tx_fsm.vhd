-------------------------------------------------
-- Approximate Network on Chip TX FSM
-- Purpose:
--      Finite State Machine to control a channel
--      and can be reinstanced for multiple 
--      channels. For use on a network interface 
--      transceiver.
--      
--  Requires: VHDL-2008
--  Rick Fenster, Dec 24/2020
-------------------------------------------------

-- Library declarations
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ni_tx_fsm is
    port
    (
        -- General control
        clk, rst : in std_logic;
        -- FIFO status signals
        fifoFull, fifoEmpty : in std_logic;
        -- FIFO Control signals
        fifoWriteEn, fifoPopEn : out std_logic;
        fifoWriteRqst : in std_logic;
        -- Channel control
        clearToSend : in std_logic;
        channelValid : out std_logic
    );

end ni_tx_fsm;

architecture ni_tx_fsm_impl of ni_tx_fsm is
    -- Define FIFO write state
    type fifo_state_t is (fifoState_IDLE, fifoState_WRITE);
    -- Define channel transmission state
    type channel_state_t is (channelState_IDLE, channelState_TRANSMIT);
    -- Instance states
    signal fifo_state : fifo_state_t := fifoState_IDLE;
    signal channel_state : channel_state_t := channelState_IDLE;
    begin
        -- State transition process
        state_transition_proc: process (clk, rst)
            begin  
                if (rst = '1') then
                    fifo_state <= fifoState_IDLE;
                    channel_state <= channelState_IDLE;
                elsif (rising_edge(clk)) then
                    -- Start with FIFO state
                    if (fifoFull = '0' and fifoWriteRqst = '1') then
                        fifo_state <= fifoState_WRITE;
                    else
                        fifo_state <= fifoState_IDLE;
                    end if;
                    -- Channel control logic
                    if (fifoEmpty = '0' and clearToSend = '1') then
                        channel_state <= channelState_TRANSMIT;
                    else
                        channel_state <= channelState_IDLE;
                    end if;                        
                end if;
        end process;

        -- State behaviour process
        state_behavior_proc: process (fifo_state, channel_state, clk)
            begin
                case (fifo_state) is
                    when fifoState_WRITE =>
                        fifoWriteEn <= '1';
                    when others =>
                        fifoWriteEn <= '0';
                end case;

                case (channel_state) is
                    when channelState_TRANSMIT =>
                        fifoPopEn <= '1';
                        channelValid <= '1';
                    when others =>
                        fifoPopEn <= '0';
                        channelValid <= '0';
                end case;
        end process;

end ni_tx_fsm_impl;