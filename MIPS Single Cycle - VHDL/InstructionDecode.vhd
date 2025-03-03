
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstructionDecode is
    Port (
            clk: in std_logic;
            instr: in std_logic_vector(25 downto 0);
            regWrite, regDst, extOp: in std_logic;
            wd: in std_logic_vector(31 downto 0);
            rd1, rd2, extImm: out std_logic_vector(31 downto 0);
            func: out std_logic_vector(5 downto 0);
            sa: out std_logic_vector(4 downto 0)        
    );
end InstructionDecode;

architecture Behavioral of InstructionDecode is

    type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
    signal reg_file : reg_array:= (
        X"00000001",
        X"00000002",
        X"00000003",
        others => X"00000000");
    signal wa: std_logic_vector(4 downto 0);
    signal ra1, ra2: std_logic_vector(4 downto 0);
    
    
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            if regWrite = '1' then
                reg_file(conv_integer(wa)) <= wd;
            end if;
        end if;
    end process;
    
    ra1 <= instr(25 downto 21);
    ra2 <= instr(20 downto 16);
    
    rd1 <= reg_file(conv_integer(ra1));
    rd2 <= reg_file(conv_integer(ra2));
    
    wa <= instr(20 downto 16) when regDst = '0' else
          instr(15 downto 11);
    
    extImm <= "0000000000000000" & instr(15 downto 0) when extOp = '0' else
              instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) 
                & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15 downto 0);
    
end Behavioral;
