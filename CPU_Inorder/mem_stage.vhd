library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decode_types.all;

entity mem_stage is 
 port (
	 mem_stage_clk   : in std_logic;
	 
    alu_res1        : in std_logic_vector(31 downto 0);
    rs2_1_data      : in std_logic_vector(31 downto 0);--port to rs_2_1_val from ex in main code
	 instr1_in_mem   : in decoded_instruction;
    instr1_out_mem  : out decoded_instruction;
	 wb_data1        : out std_logic_vector(31 downto 0);--for writeback
    
    alu_res2        : in std_logic_vector(31 downto 0);
    rs2_2_data      : in std_logic_vector(31 downto 0);
	 instr2_in_mem   : in decoded_instruction;
    instr2_out_mem  : out decoded_instruction;
	 wb_data2        : out std_logic_vector(31 downto 0);--for writeback

	 flush1_in_mem   : in std_logic;
	 flush1_out_mem  : out std_logic;
	 flush2_in_mem   : in std_logic;
	 flush2_out_mem  : out std_logic
  );
end entity;

architecture str of mem_stage is
	component data_memory is
	  port (
		 dmem_clk  : in  std_logic;

		 -- Port 1
		 addr1     : in  std_logic_vector(31 downto 0);
		 wdata1    : in  std_logic_vector(31 downto 0);
		 write_en1 : in  std_logic;
		 rdata1    : out std_logic_vector(31 downto 0);

		 -- Port 2
		 addr2     : in  std_logic_vector(31 downto 0);
		 wdata2    : in  std_logic_vector(31 downto 0);
		 write_en2 : in  std_logic;
		 rdata2    : out std_logic_vector(31 downto 0)
	  );
	end component;
	
	signal wr_en1   : std_logic;
	signal mem_out1 : std_logic_vector(31 downto 0);
	signal wr_en2   : std_logic;
	signal mem_out2 : std_logic_vector(31 downto 0);
	
begin
	wr_en1         <= instr1_in_mem.mem_write when flush1_in_mem='0' else '0';
	wr_en2         <= instr2_in_mem.mem_write when flush2_in_mem='0' else '0';
	 
	data_mem: data_memory port map(
		 dmem_clk  => mem_stage_clk,
		 
		 addr1     => alu_res1,
		 wdata1    => rs2_1_data,
		 write_en1 => wr_en1,
		 rdata1    => mem_out1,

		 addr2     => alu_res2,
		 wdata2    => rs2_2_data,
		 write_en2 => wr_en2,
		 rdata2    => mem_out2
	);
	
	 
	 wb_data1       <= mem_out1 when instr1_in_mem.mem_read='1' else alu_res1;
	 wb_data2       <= mem_out2 when instr2_in_mem.mem_read='1' else alu_res2;
	 
	 instr1_out_mem <= instr1_in_mem;
	 instr2_out_mem <= instr2_in_mem;
	
	 flush1_out_mem <= flush1_in_mem;
	 flush2_out_mem <= flush2_in_mem;
	
end str;

