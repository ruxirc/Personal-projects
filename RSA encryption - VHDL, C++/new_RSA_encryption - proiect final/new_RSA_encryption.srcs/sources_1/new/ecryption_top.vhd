----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2024 10:45:55 PM
-- Design Name: 
-- Module Name: rsa_top - Behavioral
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity encryption_top is
    generic (
        N : integer := 16  
    );
    port (
        clk          : in std_logic;                        
        reset        : in std_logic;                        
        start        : in std_logic;                        
        message_in   : in std_logic_vector(7 downto 0);     -- Mesajul de criptat (un caracter)
        exponent     : in std_logic_vector(N-1 downto 0);   -- Exponentul public (e)
        modulus      : in std_logic_vector(N-1 downto 0);   -- Modulul public (n)
        encrypted_out: out std_logic_vector(N-1 downto 0);  -- Mesajul criptat (c)
        done         : out std_logic                        
    );
end encryption_top;

architecture Behavioral of encryption_top is

    signal modular_pow_start : std_logic := '0';
    signal modular_pow_done  : std_logic := '0';
    signal result            : std_logic_vector(N-1 downto 0);

    -- Extindere mesaj la N biți pentru compatibilitate cu modular_pow
    signal message_extended  : std_logic_vector(N-1 downto 0);

begin
    message_extended <= (N-1 downto 8 => '0') & message_in;

    modular_pow_inst: entity work.modular_pow
        generic map (
            N => N  
        )
        port map (
            clk      => clk,
            reset    => reset,
            start    => modular_pow_start,
            base     => message_extended,  -- Mesajul extins (m)
            exponent => exponent,          -- Exponentul public (e)
            modulus  => modulus,           -- Modulul public (n)
            result   => result,            
            done     => modular_pow_done   
        );
        
        
    process(clk, reset)
    begin
        if reset = '1' then
            modular_pow_start <= '0';
            encrypted_out     <= (others => '0');
            done              <= '0';
        elsif rising_edge(clk) then
            if start = '1' and modular_pow_start = '0' then
                modular_pow_start <= '1';  -- Pornește calculul
            elsif modular_pow_done = '1' then
                encrypted_out     <= result;  -- Transferă rezultatul
                done              <= '1';     -- Semnalizează finalizarea
                modular_pow_start <= '0';     -- Resetează semnalul de start
            elsif start = '0' then
                done <= '0';  
            end if;
        end if;
    end process;

end Behavioral;
