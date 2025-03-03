library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_encoding is
    generic (
        N : integer := 6  -- Number of bits per encoded character
    );
    port (
        addr : in std_logic_vector(N-1 downto 0);  -- Address to access ROM (0-35 for '0'-'9', 'a'-'z')
        data : out std_logic_vector(N-1 downto 0)  -- Output the encoded value (6-bit encoding)
    );
end rom_encoding;

-- Architecture Definition for the ROM
architecture Behavioral of rom_encoding is
    -- Define the ROM array with 36 entries (for 0-9 and a-z)
    type rom_type is array (0 to 35) of std_logic_vector(N-1 downto 0);
    signal rom : rom_type := (
        -- Encoding for characters '0' to '9' (ASCII values for '0'-'9' converted to 6-bit values)
        "000000", "000001", "000010", "000011", "000100",  -- '0' to '4'
        "000101", "000110", "000111", "001000", "001001",  -- '5' to '9'
        
        -- Encoding for characters 'a' to 'z' (ASCII values for 'a'-'z' converted to 6-bit values)
        "001010", "001011", "001100", "001101", "001110",  -- 'a' to 'e'
        "001111", "010000", "010001", "010010", "010011",  -- 'f' to 'j'
        "010100", "010101", "010110", "010111", "011000",  -- 'k' to 'o'
        "011001", "011010", "011011", "011100", "011101",  -- 'p' to 't'
        "011110", "011111", "100000", "100001", "100010",  -- 'u' to 'y'
        "100011"                                           -- 'z'
    );
    
begin
    process(addr)
    begin
        -- Use the address to select the data from the ROM
        data <= rom(to_integer(unsigned(addr)));
    end process;
end Behavioral;
