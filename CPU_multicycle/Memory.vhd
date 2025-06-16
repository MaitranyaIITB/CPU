library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity Memory is 
    port(clk      : in  std_logic;                -- Clock
        m_wr      : in  std_logic;                -- Memory Write Enable
        m_rd      : in  std_logic;                -- Memory Read Enable
        mem_addr  : in  std_logic_vector(15 downto 0); -- Memory Address
        mem_in    : in  std_logic_vector(15 downto 0); -- Memory Input Data
        mem_out   : out std_logic_vector(15 downto 0)  -- Memory Output Data
    ); 
end entity; 

architecture Behavioral of Memory is
		
		-- Memory Array
    type mem_vec is array(0 to 255) of std_logic_vector(7 downto 0);
	 
    signal mem_vals : mem_vec := (
		-- Memory Initialization
		1  => "10010000", 0  => "00000010",  --LLI load 2 into R0
		3  => "10001110", 2  => "00000101",  --LHI load 1280 into R7
		5  => "10010010", 4  => "00000101",  --LLI load 5 into R1
		7  => "00000000", 6  => "01010000",  --R2=R0+R1=7
		9  => "00100000", 8  => "01011000",  --R3=R0-R1=(-3)
		11 => "00110000", 10 => "01100000",  --R4=R0*R1=10
		13 => "01010010", 12 => "10101000",  --R5=R1 OR R2
		15 => "01000010", 14 => "10101000",  --R5= R1 AND R2
		17 => "01101110", 16 => "01110000",  --R6= R7->R1
		19 => "00010100", 18 => "10000011",  --ADI R2=R2+3=7+3=10
		21 => "11001000", 20 => "10001100",  --BEQ(R2==R4) THEREFORE PC=PC+IMM*2=20+12*2=44
		29 => "11101110", 28 => "00010011",  --(Jump)PC= PC+IMM*2=28+19*2=28+38=66
		45 => "11000101", 44 => "11001100",  --BEQ(R2!=R7) therefore PC=PC+2
		47 => "10011000", 46 => "00111100",  --LLI R4=60
		49 => "10010110", 48 => "00110011",  --LLI R3=51
		51 => "10110111", 50 => "00111100",  --STORE R3 AT ADDRESS R4+IMM=60+60=120
		53 => "10101011", 52 => "00111100",  --LOAD IN R5 FROM ADDRESS R4+IMM=60+60=120,
		55 => "11011110", 54 => "00000100",  --JAL PC = PC + IMM*2=54+4*2=62  store 62 into R7
		63 => "00001101", 62 => "10010000",  -- R2=R6+R6
		65 => "10010000", 64 => "00011100",  --LLI load 28 into R0
		67 => "11111110", 66 => "00000000",  --JLR instruction update PC = RegB(28) then store updated pc in RegA {RegA=R7, RegB=R0)
		others => "00000000"
		);
		
		
	

begin

	mem_read_process : process(m_rd)
		begin
			if m_rd = '1' then
                mem_out(15 downto 8) <= mem_vals(to_integer(unsigned(mem_addr))+1);
					 mem_out(7  downto 0) <= mem_vals(to_integer(unsigned(mem_addr)));
            end if;
		end process;
		
    -- Memory Process
    mem_process : process (m_wr,clk)
    begin
			if rising_edge(clk) then
				if m_wr = '1' then
                mem_vals(to_integer(unsigned(mem_addr))+1) <= mem_in(15 downto 8);
					 mem_vals(to_integer(unsigned(mem_addr)))   <= mem_in(7  downto 0);
				end if;
			end if;
    end process;

end Behavioral;