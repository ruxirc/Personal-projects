----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/02/2024 07:29:32 AM
-- Design Name: 
-- Module Name: uart_transmitter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_transmitter is
    Port (
        clk     : in  STD_LOGIC;                    -- Semnalul de ceas
        rst     : in  STD_LOGIC;                    -- Semnal de reset
        baud_en : in  STD_LOGIC;                    -- Controlul ratei baud
        tx_en   : in  STD_LOGIC;                    -- Permisiunea de inițiere a transmisiei
        tx_data : in  STD_LOGIC_VECTOR (15 downto 0); -- Datele de transmis
        tx      : out STD_LOGIC;                    -- Ieșirea serială
        tx_rdy  : out STD_LOGIC                     -- Semnalul de gata pentru transmisie
    );
end uart_transmitter;

architecture Behavioral of uart_transmitter is
    type state_type is (idle, start, bits, stop); -- Stările FSM
    signal state    : state_type := idle;         -- Starea curentă a FSM
    signal bit_cnt  : integer := 0;
    
begin

    -- FSM principal
    process (clk, rst)
    begin
        if rst = '1' then
            state <= idle;
            bit_cnt <= 0;
        elsif rising_edge(clk) then
            if baud_en = '1' then -- Controlul baud rate-ului
                case state is
                    when idle =>
                        if tx_en = '1' then
                            state <= start;   -- Trecem la starea de start dacă tx_en este activ
                        end if;

                    when start =>
                        state <= bits;       -- Trecem la transmiterea biților de date
                        bit_cnt <= 0; -- Resetăm contorul de biți

                    when bits =>
                        if bit_cnt < 7 then
                            bit_cnt <= bit_cnt + 1;  -- Incrementăm contorul de biți
                        else
                            state <= stop;           -- După ce transmitem toți cei 8 biți, trecem la stop
                        end if;

                    when stop =>
                        state <= idle;               -- Revenim la starea idle după bitul de stop

                    when others =>
                        state <= idle;               -- Resetare de siguranță
                end case;
            end if;
        end if;
    end process;

    -- Logica de transmisie în funcție de starea FSM-ului
    process(state, tx_data, bit_cnt)
    begin
        case state is
            when idle =>
                tx <= '1';       -- Linie inactivă (high)
                tx_rdy <= '1';   -- Transmitter-ul este pregătit

            when start =>
                tx <= '0';       -- Bitul de start (low)
                tx_rdy <= '0';   -- Transmiterea a început, deci transmitter-ul nu e pregătit

            when bits =>
                tx <= tx_data(bit_cnt); -- Transmiterea bitului curent
                tx_rdy <= '0';

            when stop =>
                tx <= '1';       -- Bitul de stop (high)
                tx_rdy <= '0';

            when others =>
                tx <= '1';
                tx_rdy <= '0';
        end case;
    end process;

end Behavioral;

