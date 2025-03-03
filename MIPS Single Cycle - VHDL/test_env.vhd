
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    port(
        clk : in STD_LOGIC;
        btn : in STD_LOGIC_VECTOR (4 downto 0);
        sw : in STD_LOGIC_VECTOR (15 downto 0);
        led : out STD_LOGIC_VECTOR (15 downto 0);
        an : out STD_LOGIC_VECTOR (7 downto 0);
        cat : out STD_LOGIC_VECTOR (6 downto 0)
    );
    
end test_env; 

architecture Behavioral of test_env is

    component mpg is
        port(
            enable: out std_logic;
            btn: in std_logic;
            clk: in std_logic
            );
    end component;
    
    component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
    end component;
    
    component InstructionFetch is
        Port ( 
            jumpAdress, branchAdress: in std_logic_vector(31 downto 0);
            jump, pcSrc, clk: in std_logic;
            en, rst: in std_logic; --pt pc
            pcIncrem: out std_logic_vector(31 downto 0);
            instruction: out std_logic_vector(31 downto 0)
        );
    end component;
    
    component InstructionDecode is
        Port (
            clk: in std_logic;
            instr: in std_logic_vector(25 downto 0);
            regWrite, regDst, extOp: in std_logic;
            wd: in std_logic_vector(31 downto 0);
            rd1, rd2, extImm: out std_logic_vector(31 downto 0);
            func: out std_logic_vector(5 downto 0);
            sa: out std_logic_vector(4 downto 0)        
        );
    end component;
    
    component ControlUnit is
        Port(
            opCode: in std_logic_vector(5 downto 0);
            funct: in std_logic_vector(4 downto 0);
            memToReg, memWrite, jump, branch, branchNEZ, branchG, aluSrc, regWrite, regDst, extOp: out std_logic;
            aluOp: out std_logic_vector(2 downto 0)
        );
    end component;
    
    component ExecutionUnit is
        Port ( 
            rd1, rd2, extImm, pcIncrem: in std_logic_vector(31 downto 0);
            aluSrc: in std_logic;
            aluOp: in std_logic_vector(2 downto 0);
            sa: in std_logic_vector(4 downto 0);
            func: in std_logic_vector(5 downto 0);
            aluRes, branchAddress: out std_logic_vector(31 downto 0);
            zero: out std_logic
        );
    end component;
    
    component DataMemory is
        Port ( 
            aluResIn, rd2: in std_logic_vector(31 downto 0);
            clk, memWrite: in std_logic;
            memData, aluResOut: out std_logic_vector(31 downto 0)
        );
    end component;
    
    component WriteBack is
        Port (
            memData, aluData: in std_logic_vector(31 downto 0);
            memToReg: in std_logic;
            outData: out std_logic_vector(31 downto 0)
        );
    end component;
    
    
    signal Instruction, PCp4, RD1, RD2, WD, Ext_imm : STD_LOGIC_VECTOR(31 downto 0); 
    signal JumpAddress, BranchAddress, ALURes, ALURes1, MemData : STD_LOGIC_VECTOR(31 downto 0);
    signal func : STD_LOGIC_VECTOR(5 downto 0);
    signal sa : STD_LOGIC_VECTOR(4 downto 0);
    signal zero : STD_LOGIC;
    signal digits : STD_LOGIC_VECTOR(31 downto 0);
    signal en, rst, PCSrc : STD_LOGIC;
    
    signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite, BranchNEZ, BranchG : STD_LOGIC;
    signal ALUOp : STD_LOGIC_VECTOR(2 downto 0);
    signal s1, s2, s3: std_logic;
    
begin
   
    monopulse : MPG port map(en, btn(0), clk);
    
    -- main units
    inF : InstructionFetch port map(JumpAddress, BranchAddress, Jump, PCSrc, clk, en, btn(1), PCp4, Instruction);
    inD : InstructionDecode port map(clk, Instruction(25 downto 0), RegWrite, RegDst, ExtOp, WD, RD1, RD2, Ext_imm, func, sa);
    UC : ControlUnit port map(Instruction(31 downto 26), Instruction(4 downto 0), MemtoReg, MemWrite, Jump, Branch, BranchNEZ, BranchG, ALUSrc, RegWrite, ExtOp, RegDst, ALUOp);
    EX : ExecutionUnit port map(RD1, RD2, Ext_imm, PCp4, ALUSrc, ALUOp, sa, func, ALURes, BranchAddress, Zero); 
    MEM : DataMemory port map(ALURes, RD2, clk, MemWrite, MemData, ALURes1);
    
    
    WD <= MemData when MemtoReg = '1' else ALURes1;
    
    -- branch
    s1 <= Zero and Branch;
    s2 <= Zero nand BranchNEZ;
    s3 <= not ALURes(31) and BranchG;
    
    PCSrc <= s1 or s2 or s3;
    
    JumpAddress <= PCp4(31 downto 28) & Instruction(25 downto 0) & "00";
    
    with sw(7 downto 5) select
        digits <=  Instruction when "000", 
                   PCp4 when "001",
                   RD1 when "010",
                   RD2 when "011",
                   Ext_Imm when "100",
                   ALURes when "101",
                   MemData when "110",
                   WD when "111",
                   (others => 'X') when others;
    
    led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;
    
end Behavioral;
