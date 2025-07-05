library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	port (a,b: in std_logic_Vector(15 downto 0);
			sel: in std_logic_vector(3 downto 0);
			s: out std_logic_vector(15 downto 0));
end entity;

architecture struct of alu is
	
	function add(a, b: in std_logic_vector(15 downto 0))
		return std_logic_vector is
			variable sum: std_logic_vector(15 downto 0) := (others => '0');
		begin
			sum:= std_logic_vector(to_signed((to_integer(signed(a)) + to_integer(signed(b))),16));
		return sum;		
	end add;

	function sub(a, b: in std_logic_vector(15 downto 0))
		return std_logic_vector is
			variable diff: std_logic_vector(15 downto 0) := (others => '0');
		begin
			diff:= std_logic_vector(to_signed((to_integer(signed(a)) - to_integer(signed(b))),16));
		return diff;
	end sub;
	
	function mult(a, b: in std_logic_vector(15 downto 0))
		return std_logic_vector is
			variable prod: std_logic_vector(15 downto 0) := (others => '0');
		begin
			prod:= std_logic_vector(to_signed((to_integer(signed(a)) * to_integer(signed(b))),16));
		return prod;
	end mult;
	
	function and_2(a, b: in std_logic_vector(15 downto 0))
		return std_logic_vector is
			variable and_2: std_logic_vector(15 downto 0) := (others=> '0');
		begin
			for i in 0 to 15 loop
				and_2(i) := a(i) and b(i);
			end loop;
		return and_2;
	end and_2;
	
	function or_2(a, b: in std_logic_vector(15 downto 0))
		return std_logic_vector is
			variable or_2: std_logic_vector(15 downto 0) := (others=> '0');
		begin
			for i in 0 to 15 loop
				or_2(i) := a(i) or b(i);
			end loop;
		return or_2;
	end or_2;
	
	function imp_2(a, b: in std_logic_vector(15 downto 0))
		return std_logic_vector is
			variable imp_2: std_logic_vector(15 downto 0) := (others=> '0');
		begin
			for i in 0 to 15 loop
				imp_2(i) := not(a(i)) or b(i);
			end loop;
		return imp_2;
	end imp_2;
	
	-- Function: SLL (Shift Left Logical)
   function sll_2(
    a : std_logic_vector(15 downto 0);
    b : std_logic_vector(15 downto 0)
) return std_logic_vector is
    variable sll_2 : std_logic_vector(15 downto 0) := (others => '0');
    variable amt    : integer := to_integer(unsigned(b(3 downto 0)));  -- use only lowest 4 bits of b
begin
    for i in 0 to 15 loop
        if i >= amt then
            sll_2(i) := a(i - amt);
        end if;
    end loop;
    return sll_2;
end sll_2;

	
begin
	alu_process: process(a,b,sel)
	begin
		report "ALU_PROCESS_STARTING";
		if (sel="0010") then
			s<=add(a,b);
		elsif (sel="0011") then
			s<=sub(a,b);
		elsif (sel="0100") then
			s<=mult(a,b);
		elsif (sel="0110") then
			s<=sll_2(a,b);
		else
			s <= add(a, b);
		end if;
	end process;
end struct;
			
	
		
					