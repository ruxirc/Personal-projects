library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity rsa_top_module is
    generic (
        N : integer := 6  -- Number of bits for encoding (for letters a-z and digits)
    );
    port (
        clk             : in std_logic;                      -- Clock signal
        reset           : in std_logic;                      -- Reset signal
        start           : in std_logic;                      -- Start signal for encryption/decryption
        letter_in       : in std_logic_vector(N-1 downto 0);   -- ASCII encoded letter input
        encrypted_data  : out std_logic_vector(N-1 downto 0);   -- Encrypted/decrypted result as ASCII
        done            : out std_logic                       -- Done signal for encryption/decryption
    );
end rsa_top_module;

-- Architecture for the Top module
architecture Behavioral of rsa_top_module is

    -- Signal declarations
    signal rom_data        : std_logic_vector(N-1 downto 0);  -- Encoded character from ROM
    signal binary_exp_result : std_logic_vector(2*N-1 downto 0); -- Result of binary exponentiation
    signal binary_exp_done   : std_logic;                    -- Done signal for binary exponentiation
    
    -- Internal signals for encryption/decryption
    signal mode            : std_logic := '0';              -- Mode signal (0 = encrypt, 1 = decrypt)
    signal exp             : std_logic_vector(N-1 downto 0); -- Exponent (public or private key)
    signal modulus         : std_logic_vector(N-1 downto 0); -- Modulus N
    
    -- ROM component for character encoding
    component rom_encoding is
        generic (
            N : integer := 6
        );
        port (
            addr : in std_logic_vector(N-1 downto 0);  -- 8-bit address for character input (ASCII encoded)
            data : out std_logic_vector(N-1 downto 0) -- Corresponding 6-bit encoding
        );
    end component;

    -- Binary exponentiation component (for encryption and decryption)
    component binary_exp is
        generic (
            N : integer := 6
        );
        port (
            clk     : in std_logic;
            reset   : in std_logic;
            start   : in std_logic;
            base    : in std_logic_vector(N-1 downto 0);  -- The base (encoded character)
            exp     : in std_logic_vector(N-1 downto 0);  -- The exponent (public or private key)
            modulus : in std_logic_vector(N-1 downto 0);  -- The modulus N
            result  : out std_logic_vector(2*N-1 downto 0); -- The result of base^exp mod modulus
            done    : out std_logic                       -- Done signal
        );
    end component;

begin

    -- ROM instance to map ASCII characters to 6-bit values
    rom_inst : rom_encoding
        port map (
            addr => letter_in,      -- ASCII value of the letter
            data => rom_data        -- 6-bit encoded data
        );

    -- Binary exponentiation instance for both encryption and decryption
    binary_exp_inst : binary_exp
        port map (
            clk     => clk,
            reset   => reset,
            start   => start,
            base    => rom_data,     -- Base (encoded character)
            exp     => exp,          -- Exponent (public or private key)
            modulus => modulus,     -- Modulus N
            result  => binary_exp_result,
            done    => binary_exp_done
        );

    -- Mode control (encryption or decryption)
    process (reset, start, mode)
    begin
        if reset = '1' then
            -- Reset internal signals on reset
            exp <= (others => '0');
            modulus <= (others => '0');
        elsif start = '1' then
            -- Set the appropriate exponent and modulus based on the mode
            if mode = '0' then
                -- Encryption: Use public key exponent and modulus
                exp <= "000001";  -- Example public exponent (you should replace it with actual value)
                modulus <= "110001";  -- Example modulus (you should replace it with actual value)
            else
                -- Decryption: Use private key exponent and modulus
                exp <= "000010";  -- Example private exponent (you should replace it with actual value)
                modulus <= "110001";  -- Example modulus (same as above, N)
            end if;
        end if;
    end process;

    -- Output the encrypted or decrypted result when done with encryption/decryption
    encrypted_data <= std_logic_vector(to_unsigned(to_integer(unsigned(binary_exp_result)), 6)) when binary_exp_done = '1' else (others => '0');
    done <= binary_exp_done;

end Behavioral;
