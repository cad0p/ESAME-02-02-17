-- Prova di esame, 02/02/2017
-- Esercizio 4 (Problema con diagramma a stati finiti)
-- Si progetti una rete sequenziale sincrona avente ingresso A e uscita Y. L'uscita Y deve assumere,
-- con un ritardo di due intervalli di clock, il valore presente sull'ingresso A, ma solo
-- se A ha mantenuto quel valore per più di due intervalli di clock (se A ha mantenuto quel
-- valore solo per uno o due intervalli, l'uscita Y deve ignorarlo e mantenere il valore che aveva
-- prima della variazione di A). Si disegni il grafo degli stati secondo il modello di Mealy e si
-- progetti la rete utilizzando FF di tipo D.

-- IMPORTANTE:
-- 1. il file di TestBench MAKE.BAT è già predisposto per la simulazione 
-- 2. disegnare con precisione il circuito NON è facoltativo ma assolutamente OBBLIGATORIO, e facilita l'esecuzione della prova
-- 3. si realizzi l'esercizio mediante l'istanziazione dei COMPONENT già previsti nel testo
-- 4. per avere un'idea dell'andamento che devono avere i segnali e per provare la procedura 
-- di compilazione e visualizzazione, prima di scrivere alcunché, si esegua 
-- tutta la procedura, utilizzando il file MAKE.BAT già predisposto
-- 5. direttamente da NOTEPAD++ dal menu USEGUI -> Open current dir CMD e poi digirare MAKE
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

-- descrizione del componente FFD - Flip Flop di tipo D
-- questa parte non deve essere modificata
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

	entity FFD is
  	port(
		CLK, reset : in std_logic;
		D : in std_logic;
		Q : out std_logic
		);
	end FFD;
	
	architecture behaviour of FFD is
	begin
		process(CLK, reset)
		begin
			if reset='1' then Q<='0';  
			elsif (clk'event and clk='1') then Q<=D;
			else null;
			end if;
		end process;		
	end behaviour;


----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

-- descrizione dell'entità TOP 
-- si modifichi solo la sezione 'architecture'
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TOP is
	port(	
		CLK: in std_logic;
		RESET: in std_logic;
		A: in std_logic;
		GOAL: inout std_logic
		);
end TOP;

architecture RTL of TOP is

-- dichiarazione dei COMPONENT - NON MODIFICARE
component FFD is port(CLK, reset, D : in std_logic; Q : out std_logic); end component;


-- ATTENZIONE a dichiarare opportunamente i signal che si intende utilizzare
-- ESEMPIO di dichiarazione dei segnali
-- signal A2, A1, A0, NA2, NA1, NA0, UUU, B2, B1, B0: std_logic;
signal NA, in2, in1, in0, out2, out1, out0, nout2, nout1, nout0, GOAL1: std_logic;

begin
NA <= not A;
nout2 <= not out2; nout1<=not out1; nout0 <= not out0;
in2<= A;
in1<= (out1 or out0) and (out2 xnor A);
in0<= (out2 or out1 or nout0 or A) and (nout2 or out1 or nout0 or NA);
--ATTENZIONE ESEMPIO di piazzamento dell'istanza
-- label: COMPONENT_NAME port map (porta_componente => segnale, ...);
ffd2: FFD port map (CLK=>CLK, reset=>reset, D=>in2,  Q=>out2);
ffd1: FFD port map (CLK=>CLK, reset=>reset, D=>in1,  Q=>out1);
ffd0: FFD port map (CLK=>CLK, reset=>reset, D=>in0,  Q=>out0);
GOAL <= not((nout2 and nout1 and nout0) or (nout2 and out1 and out0)) and ((out2 and out1 and out0) or GOAL1);
ffdy: FFD port map (CLK=>CLK, reset=>reset, D=>GOAL, Q=>GOAL1);

end architecture RTL;

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

-- descrizione del Test_bench
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TOP_tb is
end TOP_tb;

architecture behaviour of TOP_tb is

--dichiarazione dei COMPONENT ovvero la Unit Under Test
component TOP is
	port(	
		CLK: in std_logic;
		RESET: in std_logic;
		A: in std_logic;
		GOAL: inout std_logic
		);
end component;

-- Clock period definitions
constant clk_period : time := 1 us; 
   
signal CLK_tb: std_logic := '0';
signal RESET_tb: std_logic := '1';
signal A_tb: std_logic := '0';
signal GOAL_tb: std_logic :='0';

signal I : integer := 0; -- variabile per il conteggio dei clock
signal GOAL_ideale : std_logic := '0'; -- uscita ideale 
signal errore: std_logic := '0'; -- segnale di errore

begin
		clk_process: process --processo di generazione del CLK
		begin
			CLK_tb <= '0';
			wait for clk_period/2;
			CLK_tb <= '1';
			wait for clk_period/2;
			I<=I+1;
		
			if I=35 then wait; -- durata della simulazione = 30 periodi di CLK
			else null;
			end if;
		
		end process;
	
	-- istanziazione della Unit Under Test
	UUT: TOP port map (CLK=>CLK_tb, RESET=>RESET_tb, A=>A_tb, GOAL=>GOAL_tb);

	Processo_stimoli_reset: process
    begin		
		RESET_tb <= '1';
		wait for clk_period*3;
		RESET_tb <= '0';		
		wait for clk_period*17;
		RESET_tb <= '1';
		wait for clk_period*1;
		RESET_tb <= '0';
		wait;		
    end process;
	
	
	Processo_di_Test: process
	begin
		A_tb <= '0'; GOAL_ideale <= '0'; 
		wait for clk_period*3;
		
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2; 
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2; 
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2; 
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2; 
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2; GOAL_ideale <= '0';
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '1'; wait for clk_period/2; 
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2; 
		A_tb <= '1'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2;
		A_tb <= '0'; wait for clk_period/2; GOAL_ideale <= '0'; wait for clk_period/2;


		wait;
	end process;
	
   
   ERRORE <= '0' when (GOAL_tb=GOAL_ideale) else '1' after 1 ns;  
   assert (ERRORE='0')
   report "attenzione! controlla con GTKWAVE"
   severity WARNING;
   
end behaviour;
	
	
	
	