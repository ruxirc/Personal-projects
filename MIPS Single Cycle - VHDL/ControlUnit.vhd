
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ControlUnit is
    Port(
        opCode: in std_logic_vector(5 downto 0);
        funct: in std_logic_vector(4 downto 0);
        memToReg, memWrite, jump, branch, branchNEZ, branchG, aluSrc, regWrite, regDst, extOp: out std_logic;
        aluOp: out std_logic_vector(2 downto 0)
    );
end ControlUnit;

architecture Behavioral of ControlUnit is

begin
    
    memToReg <= '0';
    memWrite <= '0';
    jump <= '0';
    branch <= '0';
    branchNEZ <= '0';
    branchG <= '0';
    aluSrc <= '0';
    regWrite <= '0';
    regDst <= '0';
    extOp <= '0';
    aluOp <= "000";

    process(opCode)
    begin
        case opCode is
            -- instructiune de tip R
            when "000000" =>
                aluOp <= "000";     -- foloseste func
                regDst <= '1';
                regWrite <= '1';
            -- lw
            when "100011" =>
                aluOp <= "001";     -- +
                regWrite <= '1';
                aluSrc <= '1';
                extOp <= '1';
                memToReg <= '1';
            -- sw
            when "101011" =>
                aluOp <= "001";     -- +
                aluSrc <= '1';
                extOp <= '1';
                memWrite <= '1';
            -- andi
            when "100100" =>
                aluOp <= "010";     -- and
                regWrite <= '1';
                aluSrc <= '1';
            -- beq
            when "000100" =>
                aluOp <= "011";     -- -
                extOp <= '1';
                branch <= '1';
            -- bnez
            when "000101" =>
                aluOp <= "011";     -- -
                extOp <= '1';
                branchNEZ <= '1';
            -- bg
            when "000111" =>
                aluOp <= "011";     -- -
                extOp <= '1';
                branchG <= '1';
            when others =>
                regDst <= 'X'; extOp <= 'X'; aluSrc <= 'X'; 
                branch <= 'X'; jump <= 'X'; memWrite <= 'X';
                memToReg <= 'X'; regWrite <= 'X'; branchNEZ <= 'X'; branchG <= 'X';
                aluOp <= "XXX";
        end case;
    end process;

end Behavioral;
