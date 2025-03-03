library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity binary_exp is
    generic (
        N : integer := 8 -- Dimensiunea biților pentru operanzi
    );
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        start     : in  std_logic;
        base      : in  std_logic_vector(N-1 downto 0); -- Baza
        exp       : in  std_logic_vector(N-1 downto 0); -- Exponentul
        modulus   : in  std_logic_vector(N-1 downto 0); -- Modulul
        result    : out std_logic_vector(2*N-1 downto 0); -- Rezultatul (base^exp) mod modulus
        done      : out std_logic -- Indicator de finalizare
    );
end binary_exp;

architecture Behavioral of binary_exp is
    -- Semnale interne
    signal a, b, p : std_logic_vector(N-1 downto 0); -- Registre temporare
    signal exp_copy : std_logic_vector(N-1 downto 0); -- Copie a exponentului
    signal state    : integer range 0 to 6 := 0; -- Starea FSM
    signal r2_mod   : std_logic_vector(N-1 downto 0); -- Precalculat R^2 mod modulus
    signal start_temp : std_logic; -- Semnal temporar pentru start

    -- Semnale pentru ieșirile multiplicatorului Montgomery
    signal montgomery_out : std_logic_vector(2*N-1 downto 0);
    signal mont_done      : std_logic;

    -- Definire vector zero
    constant ZERO_VECTOR : std_logic_vector(2*N-1 downto 0) := (others => '0');

    -- Instanțierea componentei de multiplicare Montgomery
    component montgomery_mult
        generic (
            N : integer := 4 -- Dimensiunea biților, să corespundă cu entitatea `binary_exp`
        );
        port (
            clk : in std_logic;
            resetare : in std_logic;
            start : in std_logic;
            a : in std_logic_vector(N-1 downto 0); -- Primul operand
            b : in std_logic_vector(N-1 downto 0); -- Al doilea operand
            mod_n : in std_logic_vector(N-1 downto 0); -- Modulul
            rezultat : out std_logic_vector(2*N-1 downto 0); -- Rezultatul multiplicării Montgomery
            gata : out std_logic -- Indicator de finalizare
        );
    end component;

begin
    -- Instanțierea multiplicatorului Montgomery
    mont_mult : montgomery_mult
        generic map (
            N => N -- Dimensiunea bitilor, identică cu `binary_exp`
        )
        port map (
            clk => clk,
            resetare => reset,
            start => start_temp,         -- Semnal temporar de start
            a => a,                       -- Primul operand
            b => b,                       -- Al doilea operand
            mod_n => modulus,             -- Modulul de reducere
            rezultat => montgomery_out,   -- Ieșirea multiplicării Montgomery
            gata => mont_done             -- Indicator de finalizare multiplicare
        );

    -- FSM pentru exponentiere binară cu multiplicare Montgomery
    process(clk, reset)
    begin
        if reset = '1' then
            state <= 0;
            result <= ZERO_VECTOR; -- Rezultat inițializat la zero
            done <= '0';
            start_temp <= '0';
        elsif rising_edge(clk) then
            case state is
                when 0 => -- Starea de inițializare
                    if start = '1' then
                        exp_copy <= exp; -- Inițializăm exponentul
                        a <= base;       -- Inițializăm baza
                        p <= r2_mod;     -- Inițializăm P cu R^2 mod modulus
                        start_temp <= '1'; -- Pornim multiplicarea
                        state <= 1;
                    else
                        start_temp <= '0';
                    end if;

                when 1 => -- Conversie baza în domeniul Montgomery
                    if mont_done = '1' then
                        a <= montgomery_out(N-1 downto 0); -- Baza în domeniul Montgomery
                        p <= (others => '0'); -- Inițializăm P la 1 Montgomery
                        p(0) <= '1';
                        start_temp <= '0'; -- Resetare start_temp
                        state <= 2;
                    end if;

                when 2 => -- Buclă pentru exponentiere
                    if exp_copy(N-1) = '1' then
                        b <= p; -- Dacă bitul este 1, setăm B la P
                        state <= 3;
                    else
                        b <= p; -- Altfel, pătratul lui P în starea următoare
                        state <= 4;
                    end if;
                    exp_copy <= '0' & exp_copy(N-1 downto 1); -- Shift stânga exponent

                when 3 => -- Înmulțirea Montgomery pentru P * A
                    if mont_done = '1' then
                        p <= montgomery_out(N-1 downto 0); -- Actualizăm P
                        start_temp <= '0';   -- Resetare start_temp
                        state <= 4;
                    end if;

                when 4 => -- Pătratul lui P
                    if mont_done = '1' then
                        p <= montgomery_out(N-1 downto 0); -- Actualizăm P
                        -- Verificare finalizare exponentiere
                        if exp_copy = ZERO_VECTOR then  
                            state <= 5; -- Finalizare
                        else
                            state <= 2; -- Continuă bucla
                        end if;
                    end if;

                when 5 => -- Conversie în afara domeniului Montgomery
                    b <= (others => '0');
                    b(0) <= '1'; -- Setăm B la 1 Montgomery
                    a <= p;      -- Atribuim lui A valoarea finală a lui P
                    state <= 6;

                when 6 => -- Multiplicarea finală Montgomery pentru ieșire
                    if mont_done = '1' then
                        result <= montgomery_out; -- Rezultatul final
                        done <= '1';
                        start_temp <= '0'; -- Resetare start_temp
                        state <= 0; -- Revenire la starea de inițializare
                    end if;

                when others =>
                    state <= 0; -- Resetare în caz de stare necunoscută
            end case;
        end if;
    end process;
end Behavioral;
