----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/29/2024 10:45:55 PM
-- Design Name: RSA Top Module
-- Module Name: rsa_top - Behavioral
-- Project Name: 
-- Target Devices: Zybo
-- Tool Versions: 
-- Description: 
--   Combines encryption and decryption functionality into a single top-level module.
--   Keys (public, private, and modulus) are hardcoded for simplicity.
--
-- Dependencies: encryption_top, decryption_top
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rsa_top is
    generic (
        N : integer := 16  -- Lățimea în biți a mesajului criptat
    );
    port (
        clk             : in std_logic;          -- Clokul principal
        rx              : in std_logic;          -- Semnalul de recepție UART
        tx              : out std_logic;         -- Semnalul de transmisie UART
        operation_mode  : in std_logic;          -- '0' pentru criptare, '1' pentru decriptare
        done            : out std_logic          -- Semnal pentru a indica finalizarea procesului
    );
end rsa_top;

architecture Behavioral of rsa_top is

    -- Chei RSA hardcodate
    constant PUBLIC_EXP  : std_logic_vector(N-1 downto 0) := x"0003";  -- Exponent public
    constant PRIVATE_EXP : std_logic_vector(N-1 downto 0) := x"0D03";  -- Exponent privat
    constant MODULUS     : std_logic_vector(N-1 downto 0) := x"C5C7";  -- Modul n

    -- Semnale interne pentru criptare și decriptare
    signal encrypted_out   : std_logic_vector(N-1 downto 0);
    signal decrypted_out   : std_logic_vector(7 downto 0);

    -- Semnale de stare și control
    signal rx_data         : std_logic_vector(N-1 downto 0);       -- Mesajul primit (8 biți)
    signal rx_ready        : std_logic;                         -- Semnal pentru a indica dacă am primit un caracter
    signal tx_start        : std_logic;                         -- Semnal pentru a începe transmiterea
    signal tx_busy         : std_logic;                         -- Semnal pentru a indica dacă TX este ocupat
    signal tx_data         : std_logic_vector(N-1 downto 0);    -- Datele transmise

    signal internal_message : std_logic_vector(N-1 downto 0);   -- Mesajul intern procesat (16 biți)

    -- Semnale de control pentru criptare/decriptare
    signal start_encryption : std_logic := '0';
    signal start_decryption : std_logic := '0';

    -- Semnale interne pentru finalizarea procesului
    signal encryption_done  : std_logic := '0';
    signal decryption_done  : std_logic := '0';

    -- Semnal local pentru a sincroniza `operation_mode`
    signal local_operation_mode : std_logic := '0';

begin

    -- Sincronizarea semnalului `operation_mode`
    process(clk)
    begin
        if rising_edge(clk) then
            local_operation_mode <= operation_mode;
        end if;
    end process;

    -- Logica principală de start pentru criptare/decriptare
    process(clk)
    begin
        if rising_edge(clk) then
            start_encryption <= '0';
            start_decryption <= '0';
            if local_operation_mode = '0' then  -- Modul de criptare
                if rx_ready = '1' then
                    internal_message <= (others => '0');
                    internal_message <= rx_data;
                    start_encryption <= '1';  -- Începem criptarea
                end if;
            elsif local_operation_mode = '1' then  -- Modul de decriptare
                if rx_ready = '1' then
                    internal_message <= (others => '0');
                    internal_message <= rx_data;
                    start_decryption <= '1';  -- Începem decriptarea
                end if;
            end if;
        end if;
    end process;

    -- Instanțierea modulului de criptare
    encryption_inst: entity work.encryption_top
        generic map (
            N => N
        )
        port map (
            clk          => clk,
            reset        => '0',  -- Resetul nu este folosit în acest exemplu
            start        => start_encryption, 
            message_in   => internal_message(7 downto 0),  -- Trimitem doar cei 8 biți necesari
            exponent     => PUBLIC_EXP,       
            modulus      => MODULUS,          
            encrypted_out => encrypted_out,
            done         => encryption_done
        );

    -- Instanțierea modulului de decriptare
    decryption_inst: entity work.decryption_top
        generic map (
            N => N
        )
        port map (
            clk           => clk,
            reset         => '0',
            start         => start_decryption, 
            encrypted_in  => internal_message,
            private_exp   => PRIVATE_EXP,      
            modulus       => MODULUS,          
            message_out   => decrypted_out,
            done          => decryption_done
        );

    -- Instanțierea modulului UART Receiver (pentru a primi datele)
    uart_rx : entity work.uart_receiver
        port map (
            clk      => clk,
            rst      => '0',   -- Nu se folosește un reset explicit
            baud_en  => '1',   -- Se presupune că viteza este activată
            rx       => rx,
            rx_data  => rx_data,
            rx_rdy   => rx_ready  
        );

    -- Instanțierea modulului UART Transmitter (pentru a trimite datele)
    uart_tx : entity work.uart_transmitter
        port map (
            clk     => clk,
            rst     => '0',     -- Nu se folosește un reset explicit
            baud_en => '1',     -- Se presupune că viteza este activată
            tx_en   => tx_start, 
            tx_data => tx_data,  -- Trimitem datele în funcție de modul
            tx      => tx,     
            tx_rdy  => tx_busy
        );

    -- Controlul procesului de transmitere și finalizare
    process(clk)
    begin
        if rising_edge(clk) then
            tx_start <= '0';
            done <= '0';
            if encryption_done = '1' then
                tx_start <= '1';
                tx_data <= encrypted_out;
                done <= '1';
            elsif decryption_done = '1' then
                tx_start <= '1';
                tx_data(N-1 downto 8) <= (others => '0');
                tx_data(7 downto 0) <= decrypted_out;
                done <= '1';
            end if;
        end if;
    end process;

end Behavioral;
