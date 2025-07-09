library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decode_types.all;

entity data_memory is
  port (
    dmem_clk       : in  std_logic;

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
end entity;

architecture str of data_memory is
  type ram_type is array (0 to 1023) of std_logic_vector(31 downto 0);
  signal dmem : ram_type := (others => (others => '0'));
begin
  process(dmem_clk)
  begin
    if rising_edge(dmem_clk) then
      if write_en1 = '1' then
        dmem(to_integer(unsigned(addr1(11 downto 2)))) <= wdata1;
      end if;
      if write_en2 = '1' then
        dmem(to_integer(unsigned(addr2(11 downto 2)))) <= wdata2;
      end if;
    end if;
  end process;

  rdata1 <= dmem(to_integer(unsigned(addr1(11 downto 2))));
  rdata2 <= dmem(to_integer(unsigned(addr2(11 downto 2))));
end str;