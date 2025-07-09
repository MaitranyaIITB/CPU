library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decode_types.all;

entity wb_stage is
	port(
		wb_stage_clk : in std_logic;
		wb_reset     : in std_logic;
		
		wb_data1     : in std_logic_vector(31 downto 0);
		flush1_wb    : in std_logic;
		instr1_in_wb : in decoded_instruction;
		
		wb_data2     : in std_logic_vector(31 downto 0);
		flush2_wb    : in std_logic;
		instr2_in_wb : in decoded_instruction;
	
		sb_wb_addr1  : out std_logic_vector(4 downto 0);
		sb_wb_valid1 : out std_logic;
		rf_rd1       : out std_logic_vector(4 downto 0);
		rf_wr_en1    : out std_logic;
		rf_wr_data1  : out std_logic_vector(31 downto 0);
		
		sb_wb_addr2  : out std_logic_vector(4 downto 0);
		sb_wb_valid2 : out std_logic;
		rf_rd2       : out std_logic_vector(4 downto 0);
		rf_wr_en2    : out std_logic;
		rf_wr_data2  : out std_logic_vector(31 downto 0)
	);
end entity;

architecture str of wb_stage is
begin
	sb_wb_addr1  <= instr1_in_wb.rd;
	rf_rd1       <= instr1_in_wb.rd;
	rf_wr_data1  <= wb_data1;
	sb_wb_valid1 <= '1' when flush1_wb='0' and instr1_in_wb.reg_write ='1' else '0';
	rf_wr_en1    <= '1' when flush1_wb='0' and instr1_in_wb.reg_write ='1' and wb_reset='0' else '0';
	
	sb_wb_addr2  <= instr2_in_wb.rd;
	rf_rd2       <= instr2_in_wb.rd;
	rf_wr_data2  <= wb_data2;
	sb_wb_valid2 <= '1' when flush2_wb='0' and instr2_in_wb.reg_write ='1' else '0';
	rf_wr_en2    <= '1' when flush2_wb='0' and instr2_in_wb.reg_write ='1' and wb_reset='0' else '0';
	
end str;
	
	
	
	
	
	
