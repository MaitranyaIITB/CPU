library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity inst_fetch is
	port(
		branch_taken : in std_logic;
		branch_target: in std_logic_vector(31 downto 0);
		stall_IF : in std_logic;
		flush_IF :in std_logic;
		clk: in std_logic;
		reset: in std_logic;
		
		inst1:out std_logic_vector(31 downto 0);
		inst2:out std_logic_vector(31 downto 0);
		PC_next4: out std_logic_vector(31 downto 0); --value of PC2 in ID
		PC_next8: out std_logic_vector(31 downto 0); --from here next inst is fetched 
		fetch_valid : out std_logic;
		PC_curr: out std_logic_vector(31 downto 0)	--value of PC1 in ID
	);
	
end entity;

architecture behv of inst_fetch is 
	signal PC : std_logic_vector(31 downto 0):= (others => '0');
	signal inst1_in:std_logic_vector(31 downto 0);
	signal inst2_in:std_logic_vector(31 downto 0);
	signal rst_flush: std_logic;
		


	component inst_mem is
	port(
		mem_clk:in std_logic;
		mem_addr:in std_logic_vector(31 downto 0);
		mem_inst1:out std_logic_vector(31 downto 0);
		mem_inst2:out std_logic_vector(31 downto 0)		
	);
	end component;
	
	
begin	
		
	PC_curr <= std_logic_vector(unsigned(PC)-8);
	PC_next4 <= std_logic_vector(unsigned(PC)-4);
	PC_next8 <=PC;
	
	
	inst_fetch: process(clk)
		begin
		if reset='1' then
				PC <= (others => '0');	
				
		elsif rising_edge(clk) then
		
		   if branch_taken ='1' then 
				PC <= branch_target;
				
			elsif stall_IF='0' then
				PC    <= std_logic_vector(unsigned(PC)+8);		
				inst1 <= inst1_in;
				inst2 <= inst2_in;	
		
			end if;
		end if;
	end process;

	fetch_valid <= '1' when flush_IF='0' and stall_IF='0' else '0';

end behv;
				
				
			
		