----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/11/2024 12:49:38 PM
-- Design Name: 
-- Module Name: modular_pow - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity modular_pow is
  generic (
        N : integer := 16  -- Lungimea în biți a numerelor
    );
    port (
        clk             : in std_logic;                      
        reset           : in std_logic;                      
        start           : in std_logic;                      
        base            : in std_logic_vector(N-1 downto 0); -- Baza ridicării la putere
        exponent        : in std_logic_vector(N-1 downto 0); -- Exponentul
        modulus         : in std_logic_vector(N-1 downto 0); -- Modulul
        result          : out std_logic_vector(N-1 downto 0);-- Rezultatul (base^exponent mod modulus)
        done            : out std_logic                      
    );
end modular_pow;

architecture Behavioral of modular_pow is
    
    type state_type is (IDLE, LOAD, COMPUTE, WAIT_RESULT, WAIT_BASE, FINISHED);
    signal state : state_type := IDLE;

    
    signal base_reg        : unsigned(N-1 downto 0);
    signal exponent_reg    : unsigned(N-1 downto 0);
    signal modulus_reg     : unsigned(N-1 downto 0);
    signal result_reg      : unsigned(N-1 downto 0);
    signal intermediate    : unsigned(N*2-1 downto 0); 
    signal exponent_count  : unsigned(N-1 downto 0);   -- Contor pentru exponent

    signal pending_update  : std_logic := '0';         -- Semnal pentru propagarea intermediarului
begin
    process(clk, reset)
begin
    if reset = '1' then
        state          <= IDLE;
        base_reg       <= (others => '0');
        modulus_reg    <= (others => '0');
        result_reg     <= (others => '0');
        exponent_count <= (others => '0');
        done           <= '0';
        pending_update <= '0';
    elsif rising_edge(clk) then
        case state is
            when IDLE =>
                if start = '1' then
                    base_reg       <= unsigned(base) mod unsigned(modulus); -- Reducere baza
                    modulus_reg    <= unsigned(modulus);
                    result_reg     <= "0000000000000001"; 
                    exponent_count <= unsigned(exponent); 
                    state          <= LOAD;
                end if;

            when LOAD =>
                if exponent_count = 0 then
                    -- Dacă contorul a ajuns la 0, procesul este finalizat
                    state <= FINISHED;
                else
                    -- Calculare produs intermediar pentru rezultat
                    intermediate   <= result_reg * base_reg;
                    pending_update <= '1';
                    state          <= WAIT_RESULT;
                end if;

            when WAIT_RESULT =>
                if pending_update = '0' then
                    -- Actualizare rezultat cu produsul intermediar și reducere modulară
                    result_reg     <= intermediate mod modulus_reg;
                    -- Decrementare contor exponent
                    exponent_count <= exponent_count - 1;
                    -- Calculare bază nouă pentru următorul ciclu
                    intermediate   <= base_reg * base_reg;
                    pending_update <= '1';
                    state          <= WAIT_BASE;
                else
                    -- Finalizare propagare pentru rezultat
                    pending_update <= '0';
                end if;

            when WAIT_BASE =>
                if pending_update = '0' then
                    -- Actualizare bază cu reducerea modulară
                    base_reg       <= intermediate mod modulus_reg;
                    state          <= LOAD;
                else
                    -- Finalizare propagare pentru bază
                    pending_update <= '0';
                end if;

            when FINISHED =>
                -- Transferare rezultat final
                result <= std_logic_vector(result_reg);
                done   <= '1';
                if start = '0' then
                    state <= IDLE;
                    done  <= '0';
                end if;

            when others =>
                state <= IDLE;
        end case;
    end if;
end process;

end Behavioral;