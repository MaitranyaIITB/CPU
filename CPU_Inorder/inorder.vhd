library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decode_types.all;

entity inorder is
	 port(
		clk           : in std_logic;
		reset         : in std_logic;
		PC            : out std_logic_vector(31 downto 0);
		instr1_if_out : out std_logic_vector(31 downto 0);
		instr2_if_out : out std_logic_vector(31 downto 0);
		
		dest_rd1 	  : out std_logic_vector(4 downto 0);
		rd_data1 	  : out std_logic_vector(31 downto 0);
		
		dest_rd2 	  : out std_logic_vector(4 downto 0);
		rd_data2 	  : out std_logic_vector(31 downto 0)		
		
	 );
end entity;

architecture str of inorder is

	component inst_fetch is
		port(
			branch_taken : in std_logic;
			branch_target: in std_logic_vector(31 downto 0);
			stall_IF     : in std_logic;
			flush_IF     : in std_logic;
			clk          : in std_logic;
			reset        : in std_logic;
			
			inst1        :out std_logic_vector(31 downto 0);
			inst2        :out std_logic_vector(31 downto 0);
			PC_next4     :out std_logic_vector(31 downto 0); --value of PC2 in ID
			PC_next8     :out std_logic_vector(31 downto 0); --from here next inst is fetched 
			fetch_valid  :out std_logic;
			PC_curr       :out std_logic_vector(31 downto 0)	--value of PC1 in ID
		);	
	end component;
	
	component inst_dec is
		port(
			instr1_ID: in std_logic_vector(31 downto 0);
			instr2_ID: in std_logic_vector(31 downto 0);
			PC1_ID   : in std_logic_vector(31 downto 0);
			PC2_ID   : in std_logic_vector(31 downto 0);
			stall_ID : in std_logic;
			flush_ID : in std_logic;
			reset_ID : in std_logic;
			fetch_valid : in std_logic;
		
			valid_decode1 : out std_logic;
			valid_decode2 : out std_logic;
			stall_fetch  : out std_logic;
			decoded1_out : out decoded_instruction;
			decoded2_out : out decoded_instruction
	  );
   end component;
	  
	 component FIFO_Queue is
		port(
			FIFO_clk      : in std_logic;
			FIFO_reset    : in std_logic;
			decoded_instr1: in decoded_instruction;
			decoded_instr2: in decoded_instruction;
			decoded_valid1: in std_logic;
			decoded_valid2: in std_logic;
			stall_FIFO    : in std_logic;
			flush_FIFO    : in std_logic;
			
			FIFO_out1     : out decoded_instruction;
			FIFO_out2     : out decoded_instruction;
			FIFO_valid1   : out std_logic;
			FIFO_valid2   : out std_logic;
			
			stall_dec     : out std_logic
		);
	 end component;
	 
	 component schedular is 
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
	 end component;
	 
	 component alu_ex is
		port(
			ex_instr1   : in decoded_instruction;
			ex_valid1   : in std_logic;
			
			ex_instr2   : in decoded_instruction;
			ex_valid2   : in std_logic;
			
			rs1_1_data  : in std_logic_vector(31 downto 0);
			rs2_1_data  : in std_logic_vector(31 downto 0);
			rs1_2_data  : in std_logic_vector(31 downto 0);
			rs2_2_data  : in std_logic_vector(31 downto 0);
				
			rs1_1       : out  std_logic_vector(4 downto 0);
			rs2_1       : out  std_logic_vector(4 downto 0);
			rs1_2       : out  std_logic_vector(4 downto 0);
			rs2_2       : out  std_logic_vector(4 downto 0);
			
			alu_res1    : out  std_logic_vector(31 downto 0);   
			alu_res2    : out  std_logic_vector(31 downto 0);  
			
			br_taken1   : out  std_logic;
			br_target1  : out  std_logic_vector(31 downto 0);
			
			br_taken2   : out  std_logic;
			br_target2  : out  std_logic_vector(31 downto 0);
			
			instr1_out  : out  decoded_instruction;
			instr2_out  : out  decoded_instruction;
			flush_ex1   : out  std_logic;
			flush_ex2   : out  std_logic;		
			
			flush_ex    : out std_logic;
			
			rs2_1_val   : out std_logic_vector(31 downto 0);
			rs2_2_val   : out std_logic_vector(31 downto 0)
			);
	end component;
	
		
	component register_file is
	  port (
		 rf_clk      : in  std_logic;

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
	end component;
	
	
	component mem_stage is 
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
	end component;
	
	component wb_stage is
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
	end component;
	
	--IF stage
	signal br_taken_in : std_logic;
	signal br_target_in: std_logic_vector(31 downto 0);
	
	signal if_instr1_out : std_logic_vector(31 downto 0);
	signal if_instr2_out : std_logic_vector(31 downto 0);
	
	signal if_stall_in   : std_logic;
	signal if_valid_out  : std_logic;
	
	signal pc_instr2_out   : std_logic_vector(31 downto 0); -- PC of inst2
	signal pc_next8_if     : std_logic_vector(31 downto 0); -- next group PC
	signal pc_instr1_out   : std_logic_vector(31 downto 0); -- PC of inst1
	
	signal flush_if_in  : std_logic;

	--ID stage
	
	signal id_stall_in    : std_logic;
	signal id_stall_out    : std_logic;
	signal instr1_dec_out : decoded_instruction;
	signal instr2_dec_out : decoded_instruction;
	signal id_valid_in   : std_logic;
	
	signal id_instr1_in : std_logic_vector(31 downto 0);
	signal id_instr2_in : std_logic_vector(31 downto 0);
	
	signal pc_instr1_in   : std_logic_vector(31 downto 0);
	signal pc_instr2_in   : std_logic_vector(31 downto 0);
	signal id_valid1_out : std_logic;
	signal id_valid2_out : std_logic;
	
	signal flush_id_in  : std_logic;
	
	--fifo stage
	signal fifo_valid1_in : std_logic;
	signal fifo_valid2_in : std_logic;
	
	signal instr1_fifo_in : decoded_instruction;
	signal instr2_fifo_in : decoded_instruction;
	
	signal fifo_stall_in  : std_logic;
	signal fifo_stall_out : std_logic;
	
	signal instr1_fifo_out : decoded_instruction;
	signal instr2_fifo_out : decoded_instruction;
	
	signal fifo_valid1_out : std_logic;
	signal fifo_valid2_out : std_logic;
	
	signal flush_fifo_in  : std_logic;
	
	--schd stage
	signal instr1_schd_in : decoded_instruction;
	signal instr2_schd_in : decoded_instruction;
	
	signal schd_valid1_in : std_logic;
	signal schd_valid2_in : std_logic;
	
	signal sb_wb_addr1_in  : std_logic_vector(4 downto 0);
	signal sb_wb_valid1_in : std_logic;
	signal sb_wb_addr2_in  : std_logic_vector(4 downto 0);
	signal sb_wb_valid2_in : std_logic;
	
	signal instr1_schd_out : decoded_instruction;
	signal instr2_schd_out : decoded_instruction;
	
	signal schd_valid1_out : std_logic;
	signal schd_valid2_out : std_logic;
	
	signal schd_stall_out  : std_logic;
	signal flush_schd_in  : std_logic;
	--alu execute
	signal execute_valid1_in : std_logic;
	signal execute_valid2_in : std_logic;
	
	signal br_taken1  : std_logic;
	signal br_taken2  : std_logic;
	signal br_target1 : std_logic_vector(31 downto 0);
	signal br_target2 : std_logic_vector(31 downto 0);
	
	signal flush1_ex_out : std_logic;
	signal flush2_ex_out : std_logic;
	signal flush_ex_out  : std_logic;
	
	signal instr1_alu_ex_in : decoded_instruction;
	signal instr2_alu_ex_in : decoded_instruction;
	
	signal rf_rs1_1_data_in : std_logic_vector(31 downto 0);
	signal rf_rs2_1_data_in : std_logic_vector(31 downto 0);
	signal rf_rs1_2_data_in : std_logic_vector(31 downto 0);
	signal rf_rs2_2_data_in : std_logic_vector(31 downto 0);
	
	signal rf_rs1_1_out : std_logic_vector(4 downto 0);
	signal rf_rs2_1_out : std_logic_vector(4 downto 0);
	signal rf_rs1_2_out : std_logic_vector(4 downto 0);
	signal rf_rs2_2_out : std_logic_vector(4 downto 0);
	
	signal alu_res1_out : std_logic_vector(31 downto 0);
	signal alu_res2_out : std_logic_vector(31 downto 0);
	
	signal rs2_1_data_mem_out : std_logic_vector(31 downto 0);
	signal rs2_2_data_mem_out : std_logic_vector(31 downto 0);
	
	signal instr1_alu_ex_out : decoded_instruction;
	signal instr2_alu_ex_out : decoded_instruction;
	
	--register file
	signal rf_rd1_in      : std_logic_vector(4 downto 0);
	signal rf_wr_data1_in : std_logic_vector(31 downto 0);
	signal rf_wr_en1_in   : std_logic;
	signal rf_rd2_in      : std_logic_vector(4 downto 0);
	signal rf_wr_data2_in : std_logic_vector(31 downto 0);
	signal rf_wr_en2_in   : std_logic;
	
	signal rf_rs1_1_data_out : std_logic_vector(31 downto 0);
	signal rf_rs2_1_data_out : std_logic_vector(31 downto 0);
	signal rf_rs1_2_data_out : std_logic_vector(31 downto 0);
	signal rf_rs2_2_data_out : std_logic_vector(31 downto 0);
	
	signal rf_rs1_1_in : std_logic_vector(4 downto 0);
	signal rf_rs2_1_in : std_logic_vector(4 downto 0);
	signal rf_rs1_2_in : std_logic_vector(4 downto 0);
	signal rf_rs2_2_in : std_logic_vector(4 downto 0);
	
	--mem stage
	signal flush1_mem_in     : std_logic;
	signal flush2_mem_in     : std_logic;
	signal flush1_mem_out    : std_logic;
	signal flush2_mem_out    : std_logic;
	signal alu_res1_in       : std_logic_vector(31 downto 0);
	signal alu_res2_in       : std_logic_vector(31 downto 0);
	signal rs2_1_data_mem_in : std_logic_vector(31 downto 0);
	signal rs2_2_data_mem_in : std_logic_vector(31 downto 0);
	
	signal instr1_mem_in     : decoded_instruction;
	signal instr2_mem_in     : decoded_instruction;
	
	signal instr1_mem_out     : decoded_instruction;
	signal instr2_mem_out     : decoded_instruction;
	
	signal wb_data1_out      : std_logic_vector(31 downto 0);
	signal wb_data2_out      : std_logic_vector(31 downto 0);
	
	--wb stage
	signal flush1_wb_in     : std_logic;
	signal flush2_wb_in     : std_logic;
	
	signal instr1_wb_in     : decoded_instruction;
	signal instr2_wb_in     : decoded_instruction;
	
	signal wb_data1_in      : std_logic_vector(31 downto 0);
	signal wb_data2_in      : std_logic_vector(31 downto 0);
	
	signal sb_wb_addr1_out  : std_logic_vector(4 downto 0);
	signal sb_wb_valid1_out : std_logic;
	signal sb_wb_addr2_out  : std_logic_vector(4 downto 0);
	signal sb_wb_valid2_out : std_logic;
	signal rf_rd1_out       : std_logic_vector(4 downto 0);
	signal rf_wr_data1_out  : std_logic_vector(31 downto 0);
	signal rf_wr_en1_out    : std_logic;
	signal rf_rd2_out       : std_logic_vector(4 downto 0);
	signal rf_wr_data2_out  : std_logic_vector(31 downto 0);
	signal rf_wr_en2_out    : std_logic;
	
	--misc
	signal br_taken_out  : std_logic;
	signal br_target_out :  std_logic_vector(31 downto 0);
	
begin 
	br_taken_out  <= br_taken1 or br_taken2;
	br_target_out <= br_target1 when br_taken1='1' else br_target2;
	
	
	
fetch: inst_fetch port map(
			branch_taken   => br_taken_in,
			branch_target  => br_target_in,
			stall_IF       => if_stall_in,
			flush_IF       => flush_if_in,
			clk				=> clk,
			reset				=> reset,
			inst1				=> if_instr1_out,
			inst2          => if_instr2_out,
			PC_next4       => pc_instr2_out,
			PC_next8       => pc_next8_if, 
			fetch_valid    => if_valid_out,
			PC_curr         =>	pc_instr1_out
		);
		
decode: inst_dec port map(
			instr1_ID    => id_instr1_in,
			instr2_ID    => id_instr2_in,
			PC1_ID       => pc_instr1_in,
			PC2_ID       => pc_instr2_in,
			stall_ID     => id_stall_in,
			
			flush_ID     => flush_id_in,
			reset_ID     => reset,
			fetch_valid  => id_valid_in,
		
			valid_decode1 => id_valid1_out,
			valid_decode2 => id_valid2_out,
			stall_fetch   => id_stall_out,
			
			decoded1_out => instr1_dec_out,
			decoded2_out => instr2_dec_out
		); 
		
fifo : FIFO_Queue port map(
		   FIFO_clk          => clk,
			FIFO_reset    		=> reset,
			
			decoded_instr1		=> instr1_fifo_in,
			decoded_instr2		=> instr2_fifo_in,
			
			decoded_valid1		=> fifo_valid1_in,
			decoded_valid2		=> fifo_valid2_in,
			
			stall_FIFO    		=> fifo_stall_in,
			flush_FIFO    		=> flush_fifo_in,
			
			FIFO_out1     		=> instr1_fifo_out,
			FIFO_out2     		=> instr2_fifo_out,
			
			FIFO_valid1   		=> fifo_valid1_out,
			FIFO_valid2   		=> fifo_valid2_out,
		
	
			stall_dec         => fifo_stall_out
			
		);
		
schd : schedular port map(
			schd_clk     => clk,
			schd_reset   => reset,
			
			FIFO_out1    => instr1_schd_in,
			FIFO_out2    => instr2_schd_in,
			
			FIFO_valid1  => schd_valid1_in,
			FIFO_valid2  => schd_valid2_in,
			Flush_sch    => flush_schd_in,
			
			write_back1  => sb_wb_addr1_in,
			wb_valid1    => sb_wb_valid1_in,
			write_back2  => sb_wb_addr2_in,
			wb_valid2    => sb_wb_valid2_in,
			
			Issue_Instr1 => instr1_schd_out,
			Issue_Instr2 => instr2_schd_out,
			
			Issue_Valid1 => schd_valid1_out,
			Issue_Valid2 => schd_valid2_out,
			FIFO_stall   => schd_stall_out

		);
		
exceute: alu_ex port map(
			ex_instr1   => instr1_alu_ex_in,
			ex_valid1   => execute_valid1_in,
			ex_instr2   => instr2_alu_ex_in,
			ex_valid2   => execute_valid2_in,
			
			rs1_1_data  => rf_rs1_1_data_in,
			rs2_1_data  => rf_rs2_1_data_in,
			rs1_2_data  => rf_rs1_2_data_in,
			rs2_2_data  => rf_rs2_2_data_in,
				
			rs1_1       => rf_rs1_1_out,
			rs2_1       => rf_rs2_1_out,
			rs1_2       => rf_rs1_2_out,
			rs2_2       => rf_rs2_2_out,
			
			alu_res1    => alu_res1_out,
			alu_res2    => alu_res2_out,
			
			br_taken1   => br_taken1,
			br_target1  => br_target1,
			
			br_taken2   => br_taken2,
			br_target2  => br_target2,
			
			instr1_out  => instr1_alu_ex_out,
			instr2_out  => instr2_alu_ex_out,
			flush_ex1   => flush1_ex_out,
			flush_ex2   => flush2_ex_out,
			flush_ex    => flush_ex_out,
			
			rs2_1_val   => rs2_1_data_mem_out,
			rs2_2_val   => rs2_2_data_mem_out
	);

rf: register_file port map(
		 rf_clk      => clk,
		 rs1_1       => rf_rs1_1_in,
		 rs2_1       => rf_rs2_1_in,
		 rs1_2       => rf_rs1_2_in,
		 rs2_2       => rf_rs2_2_in,
		 
		 rd1         => rf_rd1_in,
		 wr_data1    => rf_wr_data1_in,
		 wr_en1      => rf_wr_en1_in,
		 rd2         => rf_rd2_in,
		 wr_data2    => rf_wr_data2_in,
		 wr_en2      => rf_wr_en2_in,

		 -- Outputs
		 rs1_1_data  => rf_rs1_1_data_out,
		 rs2_1_data  => rf_rs2_1_data_out,
		 rs1_2_data  => rf_rs1_2_data_out,
		 rs2_2_data  => rf_rs2_2_data_out

	);
	
mem : mem_stage port map(

		mem_stage_clk    => clk,  
		alu_res1         => alu_res1_in,  
		rs2_1_data       => rs2_1_data_mem_in,    
		instr1_in_mem    => instr1_mem_in,  
		instr1_out_mem   => instr1_mem_out,    
		wb_data1         => wb_data1_out,    

		alu_res2         => alu_res2_in, 
		rs2_2_data       => rs2_2_data_mem_in,   
		instr2_in_mem    => instr2_mem_in,   
		instr2_out_mem   => instr2_mem_out,    
		wb_data2         => wb_data2_out, 

		flush1_in_mem    => flush1_mem_in,		
		flush2_in_mem    => flush2_mem_in,

		flush1_out_mem   => flush1_mem_out,
		flush2_out_mem   => flush2_mem_out  

);

wb : wb_stage port map(

		wb_stage_clk    => clk, 
		wb_reset        => reset,    
		wb_data1        => wb_data1_in,   
		flush1_wb       => flush1_wb_in,    
		instr1_in_wb    => instr1_wb_in,    
		wb_data2        => wb_data2_in,  
		flush2_wb       => flush2_wb_in,   
		instr2_in_wb    => instr2_wb_in,    

		sb_wb_addr1     => sb_wb_addr1_out,
		sb_wb_valid1    => sb_wb_valid1_out,
		rf_rd1          => rf_rd1_out,    
		rf_wr_en1       => rf_wr_en1_out, 
		rf_wr_data1     => rf_wr_data1_out, 
		sb_wb_addr2     => sb_wb_addr2_out,		
		sb_wb_valid2    => sb_wb_valid2_out,  
		rf_rd2          => rf_rd2_out,
		rf_wr_en2       => rf_wr_en2_out, 
		rf_wr_data2     => rf_wr_data2_out   

);

process(clk)
begin
	if rising_edge(clk) then
		--pc
		pc_instr1_in <= pc_instr1_out;
		pc_instr2_in <= pc_instr2_out;
		
		--reg write and data
		sb_wb_addr1_in  <= sb_wb_addr1_out;
		sb_wb_valid1_in <= sb_wb_valid1_out;
		sb_wb_addr2_in  <= sb_wb_addr2_out;
		sb_wb_valid2_in <= sb_wb_valid2_out;
		
		rf_rd1_in      <= rf_rd1_out;
		rf_wr_data1_in <= rf_wr_data1_out;
		rf_wr_en1_in   <= rf_wr_en1_out;
		rf_rd2_in      <= rf_rd2_out;
		rf_wr_data2_in <= rf_wr_data2_out;
		rf_wr_en2_in   <= rf_wr_en2_out;
		
		rf_rs1_1_in <= rf_rs1_1_out;
		rf_rs2_1_in <= rf_rs2_1_out;
		rf_rs1_2_in <= rf_rs1_2_out;
		rf_rs2_2_in <= rf_rs2_2_out;	
		
		rf_rs1_1_data_in <= rf_rs1_1_data_out;
		rf_rs2_1_data_in <= rf_rs2_1_data_out;
		rf_rs1_2_data_in <= rf_rs1_2_data_out;
		rf_rs2_2_data_in <= rf_rs2_2_data_out;
		
		alu_res1_in <= alu_res1_out;
		alu_res2_in <= alu_res2_out;
		
		rs2_1_data_mem_in <= rs2_1_data_mem_out;
		rs2_2_data_mem_in <= rs2_2_data_mem_out;
		
		wb_data1_in <= wb_data1_out;
		wb_data2_in <= wb_data2_out;
		
		--stall
		if_stall_in   <= id_stall_out;
		id_stall_in   <= fifo_stall_out;
		fifo_stall_in <= schd_stall_out;
		
		--flushes
		
		flush_if_in   <= flush_ex_out;
		flush_id_in   <= flush_ex_out;
		flush_fifo_in <= flush_ex_out;
		flush_schd_in <= flush_ex_out;
		
		flush1_mem_in <= flush1_ex_out;
		flush2_mem_in <= flush2_ex_out;
		
		flush1_wb_in <= flush1_mem_out;
		flush2_wb_in <= flush2_mem_out;
		
		--branch
		br_taken_in  <= br_taken_out;
		br_target_in <= br_target_out;
		
		--validity
		
		id_valid_in <= if_valid_out;
		 
		fifo_valid1_in <= id_valid1_out;
		fifo_valid2_in <= id_valid2_out;
		
	   schd_valid1_in <= fifo_valid1_out;
		schd_valid2_in <= fifo_valid2_out;
		
		execute_valid1_in <= schd_valid1_out;
		execute_valid2_in <= schd_valid2_out;
		
		--instructions
		
		id_instr1_in  <=if_instr1_out;
		id_instr2_in  <=if_instr2_out;
		 
		instr1_fifo_in <= instr1_dec_out;
		instr2_fifo_in <= instr2_dec_out;
		
		instr1_schd_in<=instr1_fifo_out;
		instr2_schd_in<=instr2_fifo_out;
		
		instr1_alu_ex_in<=instr1_schd_out;
		instr2_alu_ex_in<=instr2_schd_out;
		
		instr1_mem_in <= instr1_alu_ex_out;
		instr2_mem_in <= instr2_alu_ex_out;
		
		instr1_wb_in <=instr1_mem_out; 
		instr2_wb_in <=instr2_mem_out; 
    end if;
end process;

	PC             <=   pc_instr1_out;  
	instr1_if_out  <=   if_instr1_out;
	instr2_if_out  <=   if_instr2_out;
	
	dest_rd1  <= rf_rd1_out; 	  
	rd_data1  <= rf_wr_data1_out; 
	
	dest_rd2  <= rf_rd2_out; 	  
	rd_data2  <= rf_wr_data2_out;

end str;
