
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity InstructionFetch is
  Port ( 
        jumpAdress, branchAdress: in std_logic_vector(31 downto 0);
        jump, pcSrc, clk: in std_logic;
        en, rst: in std_logic; --pt pc
        pcIncrem: out std_logic_vector(31 downto 0);
        instruction: out std_logic_vector(31 downto 0)
  );
end InstructionFetch;


architecture Behavioral of InstructionFetch is

    type ROM is array (0 to 31) of std_logic_vector (31 downto 0);
    signal tROM: ROM := (
        B"100011_00000_00001_0000000000000000",      --1     -- lw n, 0($0)	     -- extrag N
        B"100011_00000_00010_0000000000000100",      --2     -- lw a, 4($0)	     -- extrag adresa de inceput
        B"000000_00000_00000_00011_00000_100000",    --3     -- add i, $0, $0     -- i = 0, contor
        B"000000_00000_00010_00100_00000_100000",    --4     -- add max, $0, a 	 -- initializez Max
        B"000100_00011_00001_0000000000001001",      --5     -- beq i, n, 9
        B"100011_00011_00101_0000000000000011",      --6        -- lw x, a(i)		    -- aduc in x elementul curet
	    B"100100_00110_00101_0000000000000001",      --7        -- andi aux, x, 1   	-- aux = x & 1
	    B"000101_00110_000000000000000001011",       --8        -- bnez aux, 11		    -- verific daca numarul e par
		B"001000_00011_00011_0000000000000001",      --9              -- add i, i, 1          	-- i++
		B"000010_00000000000000000000000101",        --10             -- j 5 			        -- conditia nu e indeplinita => urmatoarea iteratie a buclei
		B"000111_00101_00100_0000000000001101",      --11       -- bg x, max, 13 	    --verific daca  x > Max
		B"000000_00100_00000_00101_00000_100000",    --12             -- add x, max, $0		    -- x = max
    	B"001000_00011_00011_0000000000000001",      --13       -- add i, i, 1			-- i++
	    B"000010_00000000000000000000000101",        --14       -- j 5			        -- sar la inceputul buclei
        B"101011_00000_00100_0000000000001000",      --15    -- sw max, 8($0) 	-- stochez max la adresa 8
        others => x"0000"
    );
    
    signal PCout: std_logic_vector(31 downto 0);
    signal PCin: std_logic_vector(31 downto 0); --mux2 out
    signal mux1out: std_logic_vector(31 downto 0);
    signal cntout: std_logic_vector(31 downto 0);

begin

    process(clk, rst)
    begin
        if rst = '1' then PCout <= x"00000000";
        elsif en = '1' then
            if rising_edge(clk) then
                PCout <= PCin;
            end if;
        end if;
    end process;
            
    cntout <= PCout + 4;
    
    mux1out <=  cntout when pcSRC = '0' else
                branchAdress;
    
    PCin <= jumpAdress when jump = '1' else
            mux1out;
    
    pcIncrem <= cntout;
    
    instruction <= tROM(conv_integer(PCout(6 downto 2)));

end Behavioral;
