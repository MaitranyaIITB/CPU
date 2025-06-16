library ieee;
use ieee.std_logic_1164.all;

entity Register_file is
	port ( clk, Enable : in std_logic;
			 Data3 : in std_logic_vector(15 downto 0);
			 A1, A2, A3 : in std_logic_vector(2 downto 0);
			 Data1 : out std_logic_vector(15 downto 0);
			 Data2 : out std_logic_vector(15 downto 0);
			 O0,O1,O2,O3,O4,O5,O6,O7 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
			 );
end entity Register_file;

architecture bhv of Register_file is

	component REG is
		port (clk : in std_logic;
				Enable : in std_logic;
				Din : in std_logic_vector(15 downto 0);
				Dout : out std_logic_vector(15 downto 0));
	end component REG;
	
	component Mux_8_to_1_16bit is
		port (
			D0, D1, D2, D3, D4, D5, D6, D7  : in std_logic_vector(15 downto 0);
			Sel    : in std_logic_vector(2 downto 0);  
			Dout   : out std_logic_vector(15 downto 0) 
		);
	end component Mux_8_to_1_16bit;

	component Demux_1_to_8_16bit is
		port (
			Din    : in std_logic_vector(15 downto 0); 
			Sel    : in std_logic_vector(2 downto 0);  
			D0, D1, D2, D3, D4, D5, D6, D7 : out std_logic_vector(15 downto 0) 
		);
	end component Demux_1_to_8_16bit;
	
	component Demux_1_to_8_1bit is
		port (
			Din    : in std_logic;                     
			Sel    : in std_logic_vector(2 downto 0);  
			D0, D1, D2, D3, D4, D5, D6, D7 : out std_logic 
		);
	end component Demux_1_to_8_1bit;

	
	signal D0,D1,D2,D3,D4,D5,D6,D7 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal En0,En1,En2,En3,En4,En5,En6,En7 : std_logic;

begin

reg0 : REG port map(clk=>clk, Din=>D0, Dout=>Q0, Enable=>En0);
reg1 : REG port map(clk=>clk, Din=>D1, Dout=>Q1, Enable=>En1);
reg2 : REG port map(clk=>clk, Din=>D2, Dout=>Q2, Enable=>En2);
reg3 : REG port map(clk=>clk, Din=>D3, Dout=>Q3, Enable=>En3);
reg4 : REG port map(clk=>clk, Din=>D4, Dout=>Q4, Enable=>En4);
reg5 : REG port map(clk=>clk, Din=>D5, Dout=>Q5, Enable=>En5);
reg6 : REG port map(clk=>clk, Din=>D6, Dout=>Q6, Enable=>En6);
reg7 : REG port map(clk=>clk, Din=>D7, Dout=>Q7, Enable=>En7);

DEMUX  : Demux_1_to_8_16bit port map(Sel => A3, Din=>Data3,     D7=>D7, D6=>D6, D5=>D5, D4=>D4, D3=>D3, D2=>D2, D1=>D1, D0=>D0);
Demux2 : Demux_1_to_8_1bit  port map(Sel => A3, Din=>Enable, D7=>En7, D6=>En6, D5=>En5, D4=>En4, D3=>En3, D2=>En2, D1=>En1, D0=>En0);

Mux1 : Mux_8_to_1_16bit port map(Sel => A1, D0=>Q0, D1=>Q1, D2=>Q2, D3=>Q3, D4=>Q4, D5=>Q5, D6=>Q6, D7=>Q7, Dout=>Data1);
Mux2 : Mux_8_to_1_16bit port map(Sel => A2, D0=>Q0, D1=>Q1, D2=>Q2, D3=>Q3, D4=>Q4, D5=>Q5, D6=>Q6, D7=>Q7, Dout=>Data2);

O0<=Q0;
O1<=Q1;
O2<=Q2;
O3<=Q3;
O4<=Q4;
O5<=Q5;
O6<=Q6;
O7<=Q7;

end architecture bhv;