
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DataMemory is
    Port ( 
        aluResIn, rd2: in std_logic_vector(31 downto 0);
        clk, memWrite: in std_logic;
        memData, aluResOut: out std_logic_vector(31 downto 0)
    );
end DataMemory;

architecture Behavioral of DataMemory is
    type ram_type is array (0 to 63) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (
        others => X"00000000");
        
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
                if memWrite = '1' then
                    ram(conv_integer(aluResIn(7 downto 2))) <= rd2;
                    memData <= rd2;
                end if;
        end if;
    end process;

    memData <= ram(conv_integer(aluResIn(7 downto 2)));
    aluResOut <= aluResIn;
    
end Behavioral;
