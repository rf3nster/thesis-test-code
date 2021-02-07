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
    signal fifo_state: fifo_state_t := fifoState_IDLE;
    signal channel_state, channel_state_next: channel_state_t := channelState_IDLE;
    signal fifoWriteEn_i, fifoPopEn_i, channelValid_i : std_logic := '0';

    begin
        process (clk, rst)
            begin
                if (rst = '1') then
                    fifo_state <= fifoState_IDLE;
                    channel_state <= channelState_IDLE;
                -- Do state changes
                elsif (rising_edge(clk)) then
                    -- Fifo write switch case
                    case fifo_state is
                        when others =>
                            if (fifoFull = '0' and fifoWriteRqst = '1') then
                                fifo_state <= fifoState_WRITE;
                            else
                                fifo_state <= fifoState_IDLE;
                            end if;
                    end case;   
                    -- Transmission Channel switch case
                    channel_state <= channel_state_next;
                end if;
        end process;
  
        transmission_proc : process (channel_state, fifoEmpty, clearToSend)
            begin
                case channel_state is
                    when channelState_TRANSMIT =>
                            fifoPopEn_i <= '1';
                            channelValid_i <= '1';
                            if (fifoEmpty = '0' and clearToSend = '1') then
                                channel_state_next <= channelState_TRANSMIT;
                            else
                                channel_state_next <= channelState_IDLE;
                            end if;
                    when channelState_IDLE =>
                        fifoPopEn_i <= '0';
                        channelValid_i <= '0';
                        if (fifoEmpty = '0' and clearToSend = '1') then
                            channel_state_next <= channelState_TRANSMIT;
                        else
                            channel_state_next <= channelState_IDLE;
                        end if;                    
                end case; 
        end process;

        fifo_proc : process (fifo_state, fifoFull, fifoWriteRqst)
            begin
                case fifo_state is
                    when others =>
                        if (fifoFull = '0' and fifoWriteRqst = '1') then
                            fifoWriteEn_i <= '1';
                        else
                            fifoWriteEn_i <= '0';
                        end if;
                end case; 
        end process;        
    -- Cast signals to outside world
    fifoPopEn <= fifoPopEn_i;
    fifoWriteEn <= fifoWriteEn_i;
    channelValid <= channelValid_i;
end ni_tx_fsm_impl;