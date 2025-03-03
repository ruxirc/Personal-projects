----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/27/2024 11:28:49 AM
-- Design Name: 
-- Module Name: decryption_top - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decryption_top is
    generic (
        N : integer := 16  
    );
    port (
        clk           : in std_logic;                        
        reset         : in std_logic;                        
        start         : in std_logic;                        
        encrypted_in  : in std_logic_vector(N-1 downto 0);   -- Mesajul criptat (c)
        private_exp   : in std_logic_vector(N-1 downto 0);   -- Exponentul privat (d)
        modulus       : in std_logic_vector(N-1 downto 0);   -- Modulul public (n)
        message_out   : out std_logic_vector(7 downto 0);    -- Mesajul decriptat (m)
        done          : out std_logic                        
    );
end decryption_top;

architecture Behavioral of decryption_top is


    signal modular_pow_start : std_logic := '0';
    signal modular_pow_done  : std_logic := '0';
    signal result            : std_logic_vector(N-1 downto 0);

begin

    modular_pow_inst: entity work.modular_pow
        generic map (
            N => N  
        )
        port map (
            clk      => clk,
            reset    => reset,
            start    => modular_pow_start,
            base     => encrypted_in,       -- Mesajul criptat (c)
            exponent => private_exp,        -- Exponentul privat (d)
            modulus  => modulus,            -- Modulul public (n)
            result   => result,             -- Rezultatul decriptat (m)
            done     => modular_pow_done    
        );


    process(clk, reset)
    begin
        if reset = '1' then
            modular_pow_start <= '0';
            message_out       <= (others => '0');
            done              <= '0';
        elsif rising_edge(clk) then
            if start = '1' and modular_pow_start = '0' then
                modular_pow_start <= '1';  -- Pornește calculul
            elsif modular_pow_done = '1' then
                message_out       <= result(7 downto 0); -- Transferă partea de 8 biți ca mesaj
                done              <= '1';                -- Semnalizează finalizarea
                modular_pow_start <= '0';                -- Resetează semnalul de start
            elsif start = '0' then
                done <= '0';  
            end if;
        end if;
    end process;

end Behavioral;