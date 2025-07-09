library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity inst_mem is
	port(
		mem_clk:in std_logic;
		mem_addr:in std_logic_vector(31 downto 0);
		mem_inst1:out std_logic_vector(31 downto 0);
		mem_inst2:out std_logic_vector(31 downto 0)		
	);
end entity;

architecture behv of inst_mem is
	type mem_array is array (0 to 255) of std_logic_vector(31 downto 0);
	signal mem : mem_array:=(
		 0 => x"00100093", -- ADDI x1, x0, 1     (x1 = 1)
		 1 => x"00208113", -- ADDI x2, x1, 2     (x2 = x1 + 2 = 3)
		 2 => x"403101b3", -- SUB  x3, x2, x3    (x3 = x2 - x3=3)
		 3 => x"0041a233", -- ADD  x4, x3, x4    (x4 = x3 + x4=3)
		 4 => x"00300293", -- ANDI x6, x0, 3
		 5 => x"00F00193", -- XORI x4, x0, 0x0F
		 others => (others => '0')
	);
	
begin
		mem_read:process(mem_clk)
		begin 
		if falling_edge(mem_clk) then 
			mem_inst1 <= mem(to_integer(unsigned(mem_addr(9 downto 2))));
			mem_inst2 <= mem(to_integer(unsigned(mem_addr(9 downto 2)))+1);
		end if;
		end process;
end behv;
		
		

