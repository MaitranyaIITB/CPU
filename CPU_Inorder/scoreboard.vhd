library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scoreboard is
 port(
		clk          :in std_logic;	
		sb_reset     :in std_logic;
		sb_write_i1  :in std_logic;
		sb_read_i1   :in std_logic;
		ad_write_i1  :in std_logic_vector(4 downto 0);	
		ad_read1_i1  :in std_logic_vector(4 downto 0);
		ad_read2_i1  :in std_logic_vector(4 downto 0);
		
		sb_write_i2  :in std_logic;
		sb_read_i2   :in std_logic;
		ad_write_i2  :in std_logic_vector(4 downto 0);	
		ad_read1_i2  :in std_logic_vector(4 downto 0);
		ad_read2_i2  :in std_logic_vector(4 downto 0);
		
		sb_wrbk_addr1 :in std_logic_vector(4 downto 0);
		wrbck_valid1  :in std_logic;
		sb_wrbk_addr2 :in std_logic_vector(4 downto 0);
		wrbck_valid2  :in std_logic;
		
		reg_busy1_i1 :out std_logic;
		reg_busy2_i1 :out std_logic;
		reg_busy1_i2 :out std_logic;
		reg_busy2_i2 :out std_logic
 );
 
 end entity;
 
 
 architecture bhv of scoreboard is 
	 
	 type sb is array(0 to 31) of std_logic;
	 
	 signal sb_array: sb := (others => '0');
	 
	 signal busy_r1_i1, busy_r2_i1 : std_logic;
    signal busy_r1_i2, busy_r2_i2 : std_logic;
 
	 
	 begin
	 proc: process(clk)
	 begin
			if sb_reset = '1' then
				sb_array <= (others => '0');

			elsif rising_edge(clk) then
				
				if wrbck_valid1='1' and sb_wrbk_addr1 /= "00000"  then 
					sb_array(to_integer(unsigned(sb_wrbk_addr1))) <= '0';
				end if;
				
				if wrbck_valid2='1' and sb_wrbk_addr2 /= "00000"  then 
					sb_array(to_integer(unsigned(sb_wrbk_addr2))) <= '0';
				end if;
				
				if sb_write_i1='1'and ad_write_i1 /= "00000" then
					sb_array(to_integer(unsigned(ad_write_i1))) <= '1';
				end if;
				
				 if sb_write_i2 = '1' and ad_write_i2 /= "00000" and not ((ad_write_i1 = ad_read1_i2) or (ad_write_i1 = ad_read2_i2)) then
               sb_array(to_integer(unsigned(ad_write_i2))) <= '1';
            end if;
			end if;			
	end process;

	 busy_r1_i1 <= sb_array(to_integer(unsigned(ad_read1_i1)));
    busy_r2_i1 <= sb_array(to_integer(unsigned(ad_read2_i1)));

    busy_r1_i2 <= sb_array(to_integer(unsigned(ad_read1_i2)));
    busy_r2_i2 <= sb_array(to_integer(unsigned(ad_read2_i2)));

    reg_busy1_i1 <= busy_r1_i1;
    reg_busy2_i1 <= busy_r2_i1;
    reg_busy1_i2 <= busy_r1_i2;
    reg_busy2_i2 <= busy_r2_i2;	 

end bhv;
--There is a possible issue if instr is not writeback and in case by chance if ad_write matches ad_read1 is stalls i2 with no intention
				 
					