library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rsa_uart_system is
    generic (
        N : integer := 8 -- Dimensiunea biților pentru operanzi
    );
    port (
        clk       : in  std_logic;
        reset     : in  std_logic; -- Semnalul de reset global
        rx        : in  std_logic; -- UART receive line
        tx        : out std_logic  -- UART transmit line
    );
end rsa_uart_system;

architecture Behavioral of rsa_uart_system is

    -- Semnale pentru comunicația UART
    signal rx_data      : std_logic_vector(7 downto 0) := (others => '0'); -- Datele primite
    signal tx_data      : std_logic_vector(7 downto 0); -- Datele de transmis
    signal rx_ready     : std_logic; -- Date receptionate complet
    signal tx_start     : std_logic; -- Semnal de start pentru transmitere
    signal tx_busy      : std_logic; -- Semnal de stare pentru transmitter

    -- Semnale pentru controlul RSA
    signal message      : std_logic_vector(N-1 downto 0); -- Mesajul de criptat
    signal e            : std_logic_vector(N-1 downto 0); -- Exponentul public
    signal d            : std_logic_vector(N-1 downto 0); -- Exponentul privat
    signal modulus      : std_logic_vector(N-1 downto 0); -- Modulul
    signal encrypted    : std_logic_vector(2*N-1 downto 0); -- Rezultatul criptării
    signal decrypted    : std_logic_vector(2*N-1 downto 0); -- Rezultatul decriptării
    signal done_encrypt : std_logic; -- Indicator de finalizare criptare
    signal done_decrypt : std_logic; -- Indicator de finalizare decriptare
    signal start_encrypt: std_logic; -- Start pentru criptare
    signal start_decrypt: std_logic; -- Start pentru decriptare

    -- Instanțierea modulelor de exponentiere binară pentru criptare și decriptare
    component binary_exp
        generic (
            N : integer := 4
        );
        port (
            clk       : in  std_logic;
            reset     : in  std_logic;
            start     : in  std_logic;
            base      : in  std_logic_vector(N-1 downto 0);
            exp       : in  std_logic_vector(N-1 downto 0);
            modulus   : in  std_logic_vector(N-1 downto 0);
            result    : out std_logic_vector(2*N-1 downto 0);
            done      : out std_logic
        );
    end component;

    -- Instanțierea UART receiver și transmitter
    component uart_receiver
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;  -- Folosim `rst` pentru reset
            baud_en  : in  std_logic;  -- Semnal pentru activare baudrate
            rx       : in  std_logic;  -- Semnal serial de date
            rx_data  : out std_logic_vector(7 downto 0); -- Datele primite
            rx_rdy   : out std_logic   -- Semnal pentru date disponibile
        );
    end component;

    component uart_transmitter
        port (
            clk     : in  std_logic;                     -- Semnalul de ceas
            rst     : in  std_logic;                     -- Semnal de reset
            baud_en : in  std_logic;                     -- Controlul ratei baud
            tx_en   : in  std_logic;                     -- Permisiunea de inițiere a transmisiei
            tx_data : in  std_logic_vector(7 downto 0);  -- Datele de transmis
            tx      : out std_logic;                     -- Ieșirea serială
            tx_rdy  : out std_logic                      -- Semnalul de gata pentru transmisie
        );
    end component;

    -- Semnale pentru transmiterea rezultatelor
    signal transmit_result : std_logic_vector(2*N-1 downto 0);
    signal transmit_index  : integer range 0 to 2*N-1 := 0;

begin
    -- Instanțierea modulului pentru criptare
    rsa_encrypt : binary_exp
        generic map (N => N)
        port map (
            clk     => clk,
            reset   => reset,  -- Semnalul de reset global este transmis
            start   => start_encrypt,
            base    => message,
            exp     => e,
            modulus => modulus, 
            result  => encrypted,
            done    => done_encrypt
        );

    -- Instanțierea modulului pentru decriptare
    rsa_decrypt : binary_exp
        generic map (N => N)
        port map (
            clk     => clk,
            reset   => reset,  
            start   => start_decrypt,
            base    => encrypted(N-1 downto 0),
            exp     => d,
            modulus => modulus,
            result  => decrypted,
            done    => done_decrypt
        );

    -- Instanțierea UART Receiver
    uart_rx : uart_receiver
        port map (
            clk      => clk,
            rst      => reset,  
            baud_en  => '1',    -- Presupunem că activăm baudrate-ul
            rx       => rx,
            rx_data  => rx_data,
            rx_rdy   => rx_ready  
        );

    -- Instanțierea UART Transmitter
    uart_tx : uart_transmitter
        port map (
            clk     => clk,
            rst     => reset,  
            baud_en => '1',    -- Presupunem că activăm baudrate-ul
            tx_en   => tx_start, 
            tx_data => tx_data, 
            tx      => tx,     
            tx_rdy  => tx_busy  -- Semnalul de gata pentru transmisie
        );

    -- Controlul fluxului de date
    process(clk, reset)
    begin
        if reset = '1' then
            start_encrypt <= '0';
            start_decrypt <= '0';
            tx_start <= '0';
            transmit_index <= 0;
        elsif rising_edge(clk) then
            if rx_ready = '1' then
                -- Primim datele prin UART și configurăm intrările pentru criptare
                message <= rx_data; -- Presupunem că rx_data conține mesajul
                e <= "00000011";        -- Setează exponentul public (exemplu)
                d <= "00000101";        -- Setează exponentul privat (exemplu)
                modulus <= "00000111";  -- Setează modulul (exemplu) 
                start_encrypt <= '1';
            elsif done_encrypt = '1' then
                -- Criptare finalizată, inițiem decriptarea
                start_encrypt <= '0';
                start_decrypt <= '1';
            elsif done_decrypt = '1' then
                -- Decriptare finalizată, transmitem rezultatul
                start_decrypt <= '0';
                transmit_result <= decrypted;
                transmit_index <= 0;
                tx_start <= '1';
            elsif tx_start = '1' and tx_busy = '0' then
                -- Transmitere rezultată finalizată, trimitem următorul bit din rezultat
                tx_data <= transmit_result(transmit_index + 7 downto transmit_index);
                if transmit_index < 2*N-8 then
                    transmit_index <= transmit_index + 8;
                else
                    tx_start <= '0'; -- Finalizare transmitere
                end if;
            end if;
        end if;
    end process;

end Behavioral;
