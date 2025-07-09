library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
  port (
    rf_clk : in  std_logic;

    -- Read ports
    rs1_1       : in  std_logic_vector(4 downto 0);
    rs2_1       : in  std_logic_vector(4 downto 0);
    rs1_2       : in  std_logic_vector(4 downto 0);
    rs2_2       : in  std_logic_vector(4 downto 0);

    rd1         : in  std_logic_vector(4 downto 0);
    wr_data1    : in  std_logic_vector(31 downto 0);
    wr_en1      : in  std_logic;

    rd2         : in  std_logic_vector(4 downto 0);
    wr_data2    : in  std_logic_vector(31 downto 0);
    wr_en2      : in  std_logic;

    -- Outputs
    rs1_1_data  : out std_logic_vector(31 downto 0);
    rs2_1_data  : out std_logic_vector(31 downto 0);
    rs1_2_data  : out std_logic_vector(31 downto 0);
    rs2_2_data  : out std_logic_vector(31 downto 0)
  );
end register_file;

architecture str of register_file is
  type reg_file_type is array (0 to 31) of std_logic_vector(31 downto 0);
  signal regs : reg_file_type := (others => (others => '0'));
begin

  -- READS (Combinational)
  rs1_1_data <= regs(to_integer(unsigned(rs1_1)));
  rs2_1_data <= regs(to_integer(unsigned(rs2_1)));
  rs1_2_data <= regs(to_integer(unsigned(rs1_2)));
  rs2_2_data <= regs(to_integer(unsigned(rs2_2)));

  -- WRITES (Synchronous)
  process(rf_clk)
  begin
    if rising_edge(rf_clk) then
      if wr_en1 = '1' and rd1 /= "00000" then
        regs(to_integer(unsigned(rd1))) <= wr_data1;
      end if;

      if wr_en2 = '1' and rd2 /= "00000" then
        regs(to_integer(unsigned(rd2))) <= wr_data2;
      end if;
    end if;
  end process;
end str;

