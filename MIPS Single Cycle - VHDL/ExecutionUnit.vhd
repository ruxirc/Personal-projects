
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ExecutionUnit is
    Port ( 
        rd1, rd2, extImm, pcIncrem: in std_logic_vector(31 downto 0);
        aluSrc: in std_logic;
        aluOp: in std_logic_vector(2 downto 0);
        sa: in std_logic_vector(4 downto 0);
        func: in std_logic_vector(5 downto 0);
        aluRes, branchAddress: out std_logic_vector(31 downto 0);
        zero: out std_logic
    );
end ExecutionUnit;

architecture Behavioral of ExecutionUnit is
    signal mux1out: std_logic_vector(31 downto 0);
    signal aluCtrl: std_logic_vector(2 downto 0);
    signal aluRes1: std_logic_vector(31 downto 0);
begin
    
    mux1out <= rd2 when aluSrc = '0' else
            extImm;
    
    -- ALU control
    process(aluOp)
    begin
        case aluOp is
            when "000" => 
                --instructiuni de tip R
                case func is
                    when "100000" => 
                        aluCtrl <= "001"; -- +
                    when others => aluCtrl <= "000";  
                end case;
            when "001" => aluCtrl <= "001"; -- +
            when "010" => aluCtrl <= "010"; -- and
            when "011" => aluCtrl <= "011"; -- -
                when others => aluCtrl <= "000";
            
        end case;
    end process;
    
    --ALU
    aluRes1 <= x"00000000";
    process(aluCtrl)
    begin
        case aluCtrl is
            when "001" =>
                aluRes1 <= rd1 + mux1out;
            when "010" =>
                aluRes1 <= rd1 and mux1out;
            when "011" =>
                aluRes1 <= rd1 - mux1out;
            when others => 
                aluRes1 <= (others => 'X');
        end case;
    end process;

    -- 0 detector
    zero <= '1' when aluRes1 = x"00000000" else
            '0';
    
    -- branch address
    branchAddress <= pcIncrem + extImm;

    
    aluRes <= aluRes1;
    
end Behavioral;
