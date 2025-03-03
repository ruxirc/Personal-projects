----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/07/2025 01:41:36 PM
-- Design Name: 
-- Module Name: encryption_tb - Behavioral
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
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;

entity testbench_encryption is
end testbench_encryption;

architecture Tb of testbench_encryption is

    component encryption_top is
        generic (
            N : integer := 16
        );
        port (
            clk          : in std_logic;
            reset        : in std_logic;
            start        : in std_logic;
            message_in   : in std_logic_vector(7 downto 0);
            exponent     : in std_logic_vector(N-1 downto 0);
            modulus      : in std_logic_vector(N-1 downto 0);
            encrypted_out: out std_logic_vector(N-1 downto 0);
            done         : out std_logic
        );
    end component;

    constant T : time := 20 ns;

    signal clk, reset, start : std_logic := '0';
    signal message_in : std_logic_vector(7 downto 0) := (others => '0');
    signal exponent : std_logic_vector(15 downto 0) := "0000000000000011"; -- Exponent public (e = 3)
    signal modulus : std_logic_vector(15 downto 0) := "0000000000110111";  -- Modulul public (n = 55)
    signal encrypted_out : std_logic_vector(15 downto 0);
    signal done : std_logic := '0';

    signal processing_done : std_logic := '0';

begin

    -- Instanțierea modulului de criptare
    dut: encryption_top
        generic map (
            N => 16
        )
        port map (
            clk          => clk,
            reset        => reset,
            start        => start,
            message_in   => message_in,
            exponent     => exponent,
            modulus      => modulus,
            encrypted_out => encrypted_out,
            done         => done
        );
    
    clk <= not clk after T/2;    
    reset <= '0';
    start <= '1';

    -- Citirea din input.txt și procesarea caracter cu caracter
    process(clk)
        file input_file : text open read_mode is "C:\Users\Maria\Desktop\new_RSA_encryption\input.txt";
        variable line_in : line;
        variable char : character;
        file output_file : text open write_mode is "C:\Users\Maria\Desktop\new_RSA_encryption\encrypted.txt";
        variable line_out : line;
        variable character_code : integer;
        variable encrypted_value : std_logic_vector(15 downto 0);
    begin
        if rising_edge(clk) then
            while not endfile(input_file) loop
                readline(input_file, line_in);
    
                for i in line_in'range loop
                    -- Citire caracter din linia curentă
                    char := line_in(i);
    
                    -- Conversie caracter în valoarea sa ASCII (folosind character'val pentru codificare)
                    character_code := character'pos(char);
                    
                    -- Conversie în std_logic_vector de 8 biți
                    message_in <= std_logic_vector(to_unsigned(character_code, 8));
    
                    -- Pornește procesul de criptare
                    start <= '1';
    
                    -- Așteaptă finalizarea criptării
                    -- Salvare rezultat criptat
                    encrypted_value := encrypted_out;
    
                    -- Scriere în fișierul de ieșire
                    write(line_out, encrypted_value);
                    writeline(output_file, line_out);
                end loop;
            end loop;
        end if;

        file_close(input_file);
        file_close(output_file);
        processing_done <= '1';

        report "Criptarea a fost finalizata!";

    end process;


end Tb;
