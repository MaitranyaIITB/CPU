library ieee;
use ieee.std_logic_1164.all;

entity Testbench is
end entity;

architecture Behavioural of Testbench is
  component CPU is
    	port( clk,reset : in std_logic;
				IR_ins,PC_ins,T1_ins,T2_ins,ALU_C_ins,ALU_A_ins,ALU_B_ins,mad_ins,min_ins,mout_ins : out std_logic_vector(15 downto 0);
				cflag_ins, zflag_ins : out std_logic;
				O0,O1,O2,O3,O4,O5,O6,O7 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
  end component;

  signal clk : std_logic := '1';
  signal reset : std_logic := '0';
  signal IR_ins,PC_ins,T1_ins,T2_ins,ALU_C_ins,ALU_A_ins,ALU_B_ins,mad_ins,min_ins,mout_ins : std_logic_vector(15 downto 0);
  signal cflag_ins, zflag_ins : std_logic;
  SIGNAL O0,O1,O2,O3,O4,O5,O6,O7 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  
  constant CLOCK_PERIOD : time := 10 ns;
begin
  CPU_instance: CPU port map(clk=>CLK,
										reset=>reset,
										IR_ins=>IR_ins,
										PC_ins=>PC_ins,
										cflag_ins=>cflag_ins,
										zflag_ins=>zflag_ins,
										T1_ins=>T1_ins,
										T2_ins=>T2_ins,
										ALU_C_ins=>ALU_C_ins,
										ALU_B_ins=>ALU_B_ins,
										ALU_A_ins=>ALU_A_ins,
										mad_ins=>mad_ins,
										min_ins=>min_ins,
										mout_ins=>mout_ins,
										O0=>O0,O1=>O1,O2=>O2,O3=>O3,O4=>O4,O5=>O5,O6=>O6,O7=>O7
										);

  clk_process: process
  begin
    while now < CLOCK_PERIOD * 200 loop
      clk <= not clk;
      wait for CLOCK_PERIOD / 2;
    end loop;
    wait;
  end process;
  
	
end;