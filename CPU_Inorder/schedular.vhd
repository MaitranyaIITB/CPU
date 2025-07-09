library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decode_types.all;

entity schedular is 
	port(
		schd_clk     : in std_logic;
		schd_reset   : in std_logic;
		FIFO_out1    : in decoded_instruction;
		FIFO_out2    : in decoded_instruction;
		FIFO_valid1  : in std_logic;
		FIFO_valid2  : in std_logic;
		Flush_sch    : in std_logic;		
		write_back1  : in std_logic_vector(4 downto 0);
		wb_valid1    : in std_logic;
		write_back2  : in std_logic_vector(4 downto 0);
		wb_valid2    : in std_logic;
		
		
		Issue_Instr1 : out decoded_instruction;
		Issue_Instr2 : out decoded_instruction;
		Issue_Valid1 : out std_logic;
		Issue_Valid2 : out std_logic;
		FIFO_stall   : out std_logic
	);
end entity;

architecture bhv of schedular is
	component scoreboard is
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
	 
	 end component;
	 
	 signal i1_type     : instr_type_enum;
	 signal write_i1    : std_logic;
	 signal read_i1     : std_logic;
	 
	 
	 signal i2_type     : instr_type_enum;
	 signal write_i2    : std_logic;
	 signal read_i2     : std_logic;
	 
	 signal busy_r1_i1  : std_logic;
	 signal busy_r2_i1  : std_logic;
	 signal busy_r1_i2  : std_logic;
	 signal busy_r2_i2  : std_logic;
	 
	 signal i1_ready    : std_logic;
	 signal valid_i1    : std_logic;
	 signal i2_ready    : std_logic;
	 signal valid_i2    : std_logic;
	 signal stall_sch   : std_logic;	 
	 signal i2_valid    : std_logic:='0';
	 signal i2_stalled_due_to_i1 : std_logic := '0';
	 
	 
	
	begin
	
	sb: scoreboard port map(
			clk          => schd_clk,  
			sb_reset     => schd_reset,
			sb_write_i1  => write_i1,
			sb_read_i1   => read_i1,
			ad_write_i1  => FIFO_out1.rd,
			ad_read1_i1  => FIFO_out1.rs1,
			ad_read2_i1  => FIFO_out1.rs2,
			
			sb_write_i2  => write_i2,
			sb_read_i2   => read_i2,
			ad_write_i2  => FIFO_out2.rd,
			ad_read1_i2  => FIFO_out2.rs1,
			ad_read2_i2  => FIFO_out2.rs2,
			
			sb_wrbk_addr1 => write_back1,
			wrbck_valid1  => wb_valid1,
			
			sb_wrbk_addr2 => write_back2,
			wrbck_valid2  => wb_valid2,
	
			
			reg_busy1_i1 => busy_r1_i1,
			reg_busy2_i1 => busy_r2_i1,
			reg_busy1_i2 => busy_r1_i2,
			reg_busy2_i2 => busy_r2_i2
	);
		
	 i1_type  <= FIFO_out1.instr_type;
	 write_i1 <= '1' when (i1_type=R or i1_type=I or i1_type=J or i1_type=U_LUI or i1_type=U_AUIPC) else '0';
	 read_i1  <= '1' when (i1_type=R or i1_type=I or i1_type=S or i1_type=B) else '0';
	 
	 i1_ready <= '1' when (read_i1 ='0' or (busy_r1_i1='0' and busy_r2_i1 ='0')) else '0';
	 valid_i1 <= '1' when (FIFO_valid1='1' and i1_ready='1' and Flush_sch ='0' and schd_reset='0') else '0';
	 
	 i2_type  <= FIFO_out2.instr_type;
	 write_i2 <= '1' when (i2_type=R or i2_type=I or i2_type=J or i2_type=U_LUI or i2_type=U_AUIPC) else '0';
	 read_i2  <= '1' when (i2_type=R or i2_type=I or i2_type=S or i2_type=B) else '0';
	 
		proc_sch:process(schd_clk)
		begin
		  if rising_edge(schd_clk) then
				if (i2_stalled_due_to_i1 = '0') then
				  if (FIFO_out2.rs1 = FIFO_out1.rd or FIFO_out2.rs2 = FIFO_out1.rd) and read_i2='1' then
					 i2_valid <= '0';
					 i2_stalled_due_to_i1 <= '1';
				  else
					 i2_valid <= '1';
				  end if;
				else
				  if busy_r1_i2 = '0' and busy_r2_i2 = '0' then
					 i2_valid <= '1';
					 i2_stalled_due_to_i1 <= '0';
				  else
					 i2_valid <= '0';
				  end if;
				end if;
			 end if;
		end process;

	 
	 i2_ready  <= '1' when (i2_valid ='1' and (read_i2 ='0' or (busy_r1_i2='0' and busy_r2_i2='0'))) else '0';
	 valid_i2  <= '1' when (valid_i1 ='1' and FIFO_valid2='1' and i2_ready='1' and Flush_sch ='0' and schd_reset='0') else '0';
	 stall_sch <= '1' when (valid_i1 ='0' or valid_i2 ='0') else '0';
		
		Issue_Instr1 <= FIFO_out1;
		Issue_Instr2 <= FIFO_out2;
		Issue_Valid1 <= valid_i1;
		Issue_Valid2 <= valid_i2;
		FIFO_stall   <= stall_sch;
	
end bhv;
	