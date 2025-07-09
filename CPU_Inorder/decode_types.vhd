library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package decode_types is

  type instr_type_enum is (R, I, S, B, U_LUI, U_AUIPC, J, INVALID);

  type decoded_instruction is record
    opcode     : std_logic_vector(6 downto 0);
    funct3     : std_logic_vector(2 downto 0);
    funct7     : std_logic_vector(6 downto 0);
    rs1        : std_logic_vector(4 downto 0);
    rs2        : std_logic_vector(4 downto 0);
    rd         : std_logic_vector(4 downto 0);
    imm        : std_logic_vector(31 downto 0);
    pc         : std_logic_vector(31 downto 0);
	 alu_op     : std_logic_vector(3 downto 0);
    instr_type : instr_type_enum;
    valid      : std_logic;
	 reg_write  : std_logic;
    mem_read   : std_logic;
	 mem_write  : std_logic;
	 alu_src    : std_logic;--1 for imm
	 branch     : std_logic;
	 jump       : std_logic;
  end record;

end package;