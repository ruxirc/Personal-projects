library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;             -- Use numeric_std for unsigned and signed types
use IEEE.STD_LOGIC_TEXTIO.ALL;        -- Required for file operations (read, write, etc.)

library std;
use std.textio.ALL;

entity tb_rsa_top_module is
end tb_rsa_top_module;

architecture behavior of tb_rsa_top_module is
    -- Constants for file names
    constant input_file_name : string := "input.txt";
    constant encrypted_file_name : string := "encrypted.txt";
    constant decrypted_file_name : string := "decrypted.txt";
    
    -- Signals to connect to the rsa_top_module
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal start : std_logic := '0';
    signal letter_in : std_logic_vector(5 downto 0);  
    signal encrypted_data : std_logic_vector(5 downto 0);  
    signal done : std_logic;
    
    -- File variables
    file input_file   : text open read_mode is input_file_name;
    file encrypted_file : text open write_mode is encrypted_file_name;
    file decrypted_file : text open write_mode is decrypted_file_name;

begin

    -- Instantiate RSA Module
    uut: entity work.rsa_top_module
        port map (
            clk => clk,
            reset => reset,
            start => start,
            letter_in => letter_in,
            encrypted_data => encrypted_data,
            done => done
        );

    -- Clock Process
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Stimulus Process
    stimulus_process : process
        variable input_line : line;
        variable output_line : line;
        variable input_char : character;
        variable char_read : boolean; -- Tracks if a character is successfully read
        variable encrypted_result : integer;
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Read input file line by line
        while not endfile(input_file) loop
            readline(input_file, input_line);

            -- Process each character in the line
            char_read := true;
            while char_read loop
                read(input_line, input_char, char_read); -- Use third parameter to check successful read

                if char_read then
                    -- Check valid characters (manual range checks replace 'in')
                    if (input_char >= 'a' and input_char <= 'z') or
                       (input_char >= '0' and input_char <= '9') then
                        -- Map the character to 6-bit input
                        letter_in <= std_logic_vector(to_unsigned(character'pos(input_char), 6));

                        -- Start encryption process
                        start <= '1';
                        wait until (done = '1') for 100 ns;
                        if done /= '1' then
                            report "Timeout during encryption" severity error;
                            exit;
                        end if;
                        start <= '0';

                        -- Write encrypted data
                        encrypted_result := to_integer(unsigned(encrypted_data));
                        write(output_line, string'("Encrypted: "));
                        write(output_line, integer'image(encrypted_result));
                        writeline(encrypted_file, output_line);
                    else
                        report "Skipping unsupported character: " & character'image(input_char);
                    end if;
                end if;
            end loop;
        end loop;

        wait;
    end process;

end behavior;
