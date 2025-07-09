library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decode_types.all;

entity testbench is 
end testbench;

architecture str of testbench is
  component inorder is
	 port(
		clk   : in std_logic;
		reset : in std_logic;
		PC            : out std_logic_vector(31 downto 0);
		instr1_if_out : out std_logic_vector(31 downto 0);
		instr2_if_out : out std_logic_vector(31 downto 0);
		
		dest_rd1 	  : out std_logic_vector(4 downto 0);
		rd_data1 	  : out std_logic_vector(31 downto 0);
		
		dest_rd2	  	  : out std_logic_vector(4 downto 0);
		rd_data2 	  : out std_logic_vector(31 downto 0)		
		
	 );
  end component;
  
  signal clk : std_logic := '0';
  signal rst : std_logic := '1';
  signal pc_inorder : std_logic_vector(31 downto 0);
  signal instr1_if  : std_logic_vector(31 downto 0);
  signal instr2_if  : std_logic_vector(31 downto 0);
  signal rf_rd_addr1: std_logic_vector(4 downto 0);
  signal rf_rd_data1: std_logic_vector(31 downto 0);
  signal rf_rd_addr2: std_logic_vector(4 downto 0);
  signal rf_rd_data2: std_logic_vector(31 downto 0);
  constant CLOCK_PERIOD : time := 20 ns;
begin
 inorder_processor: inorder port map(
	clk   => clk,
	reset => rst,
	PC    => pc_inorder,
	instr1_if_out => instr1_if,
	instr2_if_out => instr2_if,
	dest_rd1      => rf_rd_addr1,
	rd_data1      => rf_rd_data1,
	dest_rd2      => rf_rd_addr2,
	rd_data2      => rf_rd_data2
 );
 
   clk_process: process
	  begin
		 while now < CLOCK_PERIOD * 200 loop
			clk <= not clk;
			wait for CLOCK_PERIOD / 2;
		 end loop;
		 wait;
	  end process;
	 
	 proc1 : process 
	 begin
		rst <= '1';
	  wait for 20 ns;
		rst <= '0';
	  wait for 1000 ns;
	 end process;
	 
 end str;
 