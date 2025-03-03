library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_receiver is
    Port (
        clk     : in  STD_LOGIC; -- Semnal de ceas pentru sincronizare
        rst     : in  STD_LOGIC; -- Semnal de reset
        baud_en : in  STD_LOGIC; -- Semnal de activare baudrate
        rx      : in  STD_LOGIC; -- Semnal serial de date
        rx_data : out STD_LOGIC_VECTOR (7 downto 0); -- Vector de 8 biți pentru datele recepționate
        rx_rdy  : out STD_LOGIC  -- Semnal pentru date disponibile
    );
end uart_receiver;

architecture Behavioral of uart_receiver is
    -- Definirea stărilor FSM
    type state_type is (idle, start, bits, stop, ready);
    signal state : state_type := idle;

    -- Contoare pentru baudrate și biți
    signal baud_cnt : integer := 0;  -- Contor de baudrate de tip integer
    signal bit_cnt  : integer := 0;  -- Contor de biți de tip integer (0 la 7)

    -- Registru pentru stocarea temporară a datelor
    signal shift_reg : std_logic_vector (7 downto 0) := (others => '0');

    -- Semnal intern pentru `rx_rdy`
    signal rx_rdy_sgn : std_logic := '0';

begin
    -- Legare semnal intern `rx_rdy_int` la ieșirea `rx_rdy`
    rx_rdy <= rx_rdy_sgn;

    -- FSM-ul principal, cu tranzitiile de stare
    process(clk, rst)
    begin
        if rst = '1' then
            state <= idle;
            baud_cnt <= 0;
            bit_cnt <= 0;
            shift_reg <= (others => '0');
            rx_rdy_sgn <= '0';
        elsif rising_edge(clk) then
            if baud_en = '1' then
                case state is
                    when idle =>
                        if rx = '0' then  -- Detectare start bit
                            state <= start;
                            baud_cnt <= 0;
                        end if;

                    when start =>
                        if baud_cnt = 15 then -- Jumătatea perioadei de start bit
                            baud_cnt <= 0;
                            state <= bits;
                            bit_cnt <= 0;
                        else
                            baud_cnt <= baud_cnt + 1;
                        end if;

                    when bits =>
                        if baud_cnt = 15 then
                            baud_cnt <= 0;
                            shift_reg(bit_cnt) <= rx; -- Recepționează bitul în shift register
                            if bit_cnt = 7 then  -- Toți cei 8 biți de date au fost recepționați
                                state <= stop;
                            else
                                bit_cnt <= bit_cnt + 1;
                            end if;
                        else
                            baud_cnt <= baud_cnt + 1;
                        end if;

                    when stop =>
                        if baud_cnt = 15 then  -- La sfârșitul stop bitului
                            rx_data <= shift_reg;   -- Setează datele recepționate
                            rx_rdy_sgn <= '1';      -- Setează semnalul intern `rx_rdy` la 1
                            state <= ready;
                        else
                            baud_cnt <= baud_cnt + 1;
                        end if;

                    when ready =>
                        -- Așteaptă să fie resetat semnalul `rx_rdy_int` pentru a intra în `idle`
                        if rx_rdy_sgn = '0' then
                            state <= idle;
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- Resetare semnal intern `rx_rdy_int` pentru așteptare date noi
    process(clk, rst)
    begin
        if rst = '1' then
            rx_rdy_sgn <= '0';
        elsif rising_edge(clk) then
            if rx_rdy_sgn = '1' and state = ready then
                rx_rdy_sgn <= '0'; -- Se resetează după ce datele au fost procesate
            end if;
        end if;
    end process;

end Behavioral;
