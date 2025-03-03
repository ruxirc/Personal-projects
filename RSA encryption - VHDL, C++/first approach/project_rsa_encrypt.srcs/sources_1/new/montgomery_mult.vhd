library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity montgomery_mult is
    generic (
        N : integer := 8 -- Numărul de biți pentru operanzi
    );
    port (
        clk : in std_logic; -- Semnal de ceas
        resetare : in std_logic; -- Semnal de reset
        start : in std_logic; -- Semnal de start pentru începerea înmulțirii
        a : in std_logic_vector(N-1 downto 0); -- Primul operand
        b : in std_logic_vector(N-1 downto 0); -- Al doilea operand
        mod_n : in std_logic_vector(N-1 downto 0); -- Modulul N
        rezultat : out std_logic_vector(2*N-1 downto 0); -- Rezultatul final
        gata : out std_logic -- Semnal care indică finalizarea înmulțirii
    );
end entity montgomery_mult;

architecture Behavioral of montgomery_mult is
    type stare_t is (ASTEPTARE, CALCUL, FINALIZARE, AFISARE, SUPLIMENTAR); -- Stările FSM
    signal stare : stare_t; -- Starea curentă a FSM
    signal produs : unsigned(2*N downto 0); -- Produsul parțial
    signal multiplicand : unsigned(2*N downto 0); -- Deinmultitul extins la 2*N+1 biți
    signal multiplicator : unsigned(N-1 downto 0); -- Inmultitorul
    signal contor : integer range 0 to N; -- Contor pentru iterații
    signal mod_n_unsigned : unsigned(N downto 0); -- Modulul N în format unsigned
begin
    -- Conversia mod_n la format unsigned pentru a facilita operațiile
    mod_n_unsigned <= unsigned('0' & mod_n);

    process(clk, resetare)
    begin
        if resetare = '1' then -- Resetare asincronă
            stare <= ASTEPTARE;
            produs <= (others => '0');
            multiplicand <= (others => '0');
            multiplicator <= (others => '0');
            contor <= 0;
            gata <= '0';
        elsif rising_edge(clk) then
            case stare is
                when ASTEPTARE =>
                    if start = '1' then -- Dacă semnalul de start este activat
                        stare <= CALCUL;
                        produs <= (others => '0');
                        multiplicand <= '0' & resize(unsigned(a), 2*N); -- Extindem a la 2*N+1 biți
                        multiplicator <= unsigned(b); -- Convertim b la format unsigned
                        contor <= 0;
                        gata <= '0';
                    end if;

                when CALCUL =>
                    -- Dacă LSB al multiplicatorului este 1, adăugăm multiplicand-ul la produs
                    if multiplicator(0) = '1' then
                        produs <= produs + multiplicand;
                        -- Verificăm dacă produsul a depășit modulul N și aplicăm scăderea
                        if produs >= mod_n_unsigned then
                            produs <= produs - mod_n_unsigned;
                        end if;
                    end if;

                    -- Deplasare la stânga pentru multiplicand și la dreapta pentru multiplicator
                    multiplicand <= shift_left(multiplicand, 1);
                    multiplicator <= shift_right(multiplicator, 1);
                    contor <= contor + 1;

                    -- După ce contorul ajunge la N, trecem la finalizare
                    if contor = N-1 then
                        stare <= FINALIZARE;
                    end if;

                when FINALIZARE =>
                    -- În finalizare, verificăm din nou dacă produsul este în domeniul modulului N
                    if produs >= mod_n_unsigned then
                        produs <= produs - ('0' & mod_n_unsigned);
                    end if;
                    
                    stare <= AFISARE;
                    
                when AFISARE =>
                    -- În această stare, menținem rezultatul și activăm semnalul gata
                    gata <= '1';
                    rezultat <= std_logic_vector(produs(2*N-1 downto 0)); -- Atribuim rezultatul final
                    stare <= SUPLIMENTAR;
                    
                when SUPLIMENTAR =>
                    -- Stare suplimentara pentru propagarea rezultatelor
                    stare <= ASTEPTARE;
                    
                when others =>
                    stare <= ASTEPTARE;
            end case;
        
        end if;
    end process;
end architecture Behavioral;
