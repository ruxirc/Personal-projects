library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity testbench_decryption is
end testbench_decryption;

architecture Tb of testbench_decryption is

    -- Componenta de decriptare
    component decryption_top is
        generic (
            N : integer := 16  -- Dimensiunea (N) a exponentului și a modulului
        );
        port (
            clk           : in std_logic;
            reset         : in std_logic;
            start         : in std_logic;
            encrypted_in  : in std_logic_vector(N-1 downto 0);   -- Mesajul criptat
            private_exp   : in std_logic_vector(N-1 downto 0);   -- Exponentul privat
            modulus       : in std_logic_vector(N-1 downto 0);   -- Modulul public
            message_out   : out std_logic_vector(7 downto 0);    -- Mesajul decriptat
            done          : out std_logic                         -- Semnal de terminare
        );
    end component;

    constant T : time := 20 ns;

    signal clk, reset, start : std_logic := '0';
    signal encrypted_in : std_logic_vector(15 downto 0) := "0000000000110111";  -- Exemplu de mesaj criptat
    signal private_exp : std_logic_vector(15 downto 0) := "0000000000001011";   -- Exemplu de exponent privat (d = 11)
    signal modulus : std_logic_vector(15 downto 0) := "0000000000110111";  -- Modulul public (n = 55)
    signal message_out : std_logic_vector(7 downto 0);
    signal done : std_logic := '0';

    -- Fișiere pentru input și output
    signal processing_done : std_logic := '0';

begin

    -- Instanțierea componentelor
    dut: decryption_top
        generic map (
            N => 16  -- Dimensiunea (N)
        )
        port map (
            clk          => clk,
            reset        => reset,
            start        => start,
            encrypted_in => encrypted_in,
            private_exp  => private_exp,
            modulus      => modulus,
            message_out  => message_out,
            done         => done
        );

    -- Generarea semnalului de ceas
    clk <= not clk after T/2;    
    reset <= '0';
    start <= '1';

    -- Citirea din fișierul de intrare și procesarea caracter cu caracter
    process(clk)
        file input_file : text open read_mode is "C:\Users\Maria\Desktop\new_RSA_encryption\encrypted.txt";
        variable line_in : line;
        variable encrypted_char : std_logic_vector(15 downto 0);
        file output_file : text open write_mode is "C:\Users\Maria\Desktop\new_RSA_encryption\decrypted.txt";
        variable line_out : line;
        variable decrypted_character : integer;
    begin
        if rising_edge(clk) then
            while not endfile(input_file) loop
                readline(input_file, line_in);

                for i in line_in'range loop
                    -- Citirea caracterului criptat din fișierul de intrare
                    encrypted_char := line_in(i);

                    -- Procesul de decriptare
                    encrypted_in <= encrypted_char;  -- Intrare criptată

                    -- Pornește procesul de decriptare
                    start <= '1';

                    -- Așteaptă finalizarea decriptării
                    if done = '1' then
                        -- Conversie din std_logic_vector în caracter ASCII
                        decrypted_character := to_integer(unsigned(message_out));

                        -- Scrierea caracterului decriptat în fișierul de ieșire
                        write(line_out, character'val(decrypted_character));
                        writeline(output_file, line_out);
                    end if;
                end loop;
            end loop;
        end if;

        file_close(input_file);
        file_close(output_file);
        processing_done <= '1';

        report "Decriptarea a fost finalizata!";
    end process;

end Tb;
