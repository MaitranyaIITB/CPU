library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity micro_cpu is
 generic (
		 RAM_WIDTH : integer := 16;
		 RAM_DEPTH : integer := 32
	  );
	port(
	 clk : in std_logic;
    reset : in std_logic;
	 
	 wr_en_IMEM : in std_logic;
	 wr_data_IMEM : in std_logic_vector(RAM_WIDTH - 1 downto 0);
	 
	 PC : out std_logic_vector(15 downto 0);
	 rf_data_wr : out std_logic_vector(15 downto 0);
	 rd_valid_DMEM : out std_logic;
	 mem_IR: out std_logic_vector(15 downto 0);
	 --store_data: out std_logic_vector(15 downto 0);
	 store_sel: out std_logic;
    rd_data_DMEM : out std_logic_vector(RAM_WIDTH - 1 downto 0)
	);
 end micro_cpu;
 
 
architecture behv of micro_cpu is

signal NA_1,NA_2,NA_3,NA_out,imm_net: std_logic_vector(15 downto 0);
signal PC_int: std_logic_vector(15 downto 0):= (others => '0');
signal PC1,PC2: std_logic_vector(15 downto 0);
signal rd_en_IMEM : std_logic;
signal rd_valid_IMEM : std_logic;
signal data_IMEM : std_logic_vector(RAM_WIDTH - 1 downto 0);
--signal wr_en_DMEM : std_logic;
signal enable: std_logic;
signal sel1,sel2,sel3,sel3_1,sel4,jump,jump_bar: std_logic;
signal IR_1,IR_2,IR_3,IR_4,IR_5: std_logic_vector(RAM_WIDTH - 1 downto 0);

signal data_rs : std_logic_vector(RAM_WIDTH - 1 downto 0);
signal data_rt : std_logic_vector(RAM_WIDTH - 1 downto 0);
signal data_rd : std_logic_vector(RAM_WIDTH - 1 downto 0);
signal imm_int : std_logic_vector(RAM_WIDTH - 1 downto 0);
signal data_rtf : std_logic_vector(RAM_WIDTH - 1 downto 0);
signal ALU_1 : std_logic_vector(RAM_WIDTH - 1 downto 0);
signal ALU_2 : std_logic_vector(RAM_WIDTH - 1 downto 0);
signal rs_value : std_logic_vector(RAM_WIDTH - 1 downto 0);
signal ALU_out : std_logic_vector(RAM_WIDTH - 1 downto 0);
signal ALU_output : std_logic_vector(RAM_WIDTH - 1 downto 0);
signal out_temp : std_logic_vector(RAM_WIDTH - 1 downto 0);
signal mem_out : std_logic_vector(RAM_WIDTH - 1 downto 0);
signal rsmux2,rsmux1,rsmux0: std_logic;
signal rsmux: std_logic_vector(2 downto 0);
component mux_2_1 is
	port ( I1, I0, S : in std_logic; Y : out std_logic);
end component mux_2_1;

  component reg16 is
	port (
	D : in std_logic_vector(15 downto 0); 
	clk, rst, en : in std_logic; 
	Q : out std_logic_vector(15 downto 0)
	);
	
end component reg16;

   component ring_buffer is
	  generic (
		 -- 16 bit data
		 RAM_WIDTH : integer := 16;
		 RAM_DEPTH : integer := 32
	  );
	  port (
		 clk : in std_logic;
		 rst : in std_logic;
	  
		 -- Write port
		 wr_en : in std_logic;
		 wr_data : in std_logic_vector(RAM_WIDTH - 1 downto 0);
	  
		 -- Read port
		 rd_en : in std_logic;
		 rd_valid : out std_logic;
		 rd_data : out std_logic_vector(RAM_WIDTH - 1 downto 0);
	  
		 -- Flags
		 empty : out std_logic;
		 empty_next : out std_logic;
		 full : out std_logic;
		 full_next : out std_logic;
	  
		 -- The number of elements in the FIFO
		 fill_count : out integer range RAM_DEPTH - 1 downto 0
	  );
	end component;

	 
	component register_file is
    port (
        clk : in std_logic;                       
        rst : in std_logic;                        -- Reset signal
        en  : in std_logic;                        -- Enable signal for writing
        addr_w : in std_logic_vector(2 downto 0);  -- 3-bit write address
        addr_r1 : in std_logic_vector(2 downto 0); -- 3-bit read address 1
        addr_r2 : in std_logic_vector(2 downto 0); -- 3-bit read address 2
        data_in : in std_logic_vector(15 downto 0); -- Data to be written/ D3
        data_out1 : out std_logic_vector(15 downto 0); -- Data read from addr_r1/ D1
        data_out2 : out std_logic_vector(15 downto 0)  -- Data read from addr_r2/ D2
    );
end component register_file;


	component sign_extension is
    Port (
        IR_6 : in STD_LOGIC_VECTOR(5 downto 0); -- 6-bit input
        IR_9 : in STD_LOGIC_VECTOR(8 downto 0); -- 9-bit input
        w13 : in STD_LOGIC;                          -- Control signal
        output_signal : out STD_LOGIC_VECTOR(15 downto 0) -- 16-bit sign-extended output
    );
end component;

	component mux_16_2_1 is
	port (
	b,a : in std_logic_vector(15 downto 0); 
	sel : in std_logic; 
	Y : out std_logic_vector(15 downto 0)
	);
end component mux_16_2_1;

	component alu is
	port (a,b: in std_logic_Vector(15 downto 0);
			sel: in std_logic_vector(3 downto 0);
			s: out std_logic_vector(15 downto 0));
end component;
 begin
 
 	rd_en_IMEM <= '1';
	--wr_en_DMEM <= '1';
	
	IMEM: ring_buffer
			port map(
				clk => clk,
				rst => reset,
				wr_en => wr_en_IMEM,
				wr_data => wr_data_IMEM,
				rd_en => rd_en_IMEM,
				rd_valid => rd_valid_IMEM,
				rd_data => data_IMEM,
				empty => open,
				empty_next => open,
				full => open,
				full_next => open,
				fill_count => open	
			);
	RPC1: reg16   port map (
                D => PC_int,
                clk => clk,
                rst => reset,
                en => enable,
                Q => PC2
            );
--	RPC2: reg16   port map (
--                D => PC1,
--                clk => clk,
--                rst => reset,
--                en => enable,
--                Q => PC2
--            );
					
	
	R1: reg16   port map (
                D => data_IMEM,
                clk => clk,
                rst => reset,
                en => enable,
                Q => IR_1
            );
	mux21_2: mux_2_1 port map( I1=>IR_1(11), I0=>IR_1(8),S=>sel3_1,Y=>rsmux2);
	mux21_1: mux_2_1 port map( I1=>IR_1(10), I0=>IR_1(7),S=>sel3_1,Y=>rsmux1);
	mux21_0: mux_2_1 port map( I1=>IR_1(9), I0=>IR_1(6),S=>sel3_1,Y=>rsmux0);
	
	rsmux <= rsmux2 & rsmux1 & rsmux0;
	RF: register_file port map (
	            en =>sel4, 
					addr_r1 => rsmux, --store and jump 11-9 else 8-6
					addr_r2 => IR_1(5 downto 3),
					addr_w => IR_4(11 downto 9), 
					data_out1 => data_rs, 
					data_out2 => data_rt, 
					data_in => data_rd, 
					clk => clk, 
					rst => reset);
					
 SE16: sign_extension port map (IR_6 => IR_1(5 downto 0), IR_9 => IR_1(8 downto 0), w13 => jump_bar, 
								output_signal => imm_int);		

								
 MUX1: mux_16_2_1 port map(
						a=>data_rt ,b=>imm_int, 
						sel=> sel1, 
						Y=> data_rtf
					);
	
	ALU_PC_1: alu	port map(a=> PC2,b=> "0000000000000010",
							sel=>"0010",
							s=>NA_1);
	ALU_PC_2: alu	port map(a=> data_rtf,b=> data_rtf,
							sel=>"0010",
							s=>imm_net);
	ALU_PC_3: alu	port map(a=> data_rs,b=> imm_net,
							sel=>"0010",
							s=>NA_2);
	ALU_PC_4: alu	port map(a=> PC2,b=> NA_2,
							sel=>"0010",
							s=>NA_3);
	MUXPC: mux_16_2_1 port map(
						a=>NA_1 ,b=>NA_3, 
						sel=> jump, 
						Y=> NA_out
					);
	PC_int<=NA_out;
   rs: reg16   port map (
                D => data_rs,
                clk => clk,
                rst => reset,
                en => enable,
                Q => ALU_1
            );
			
	rt: reg16   port map (
                D => data_rtf,
                clk => clk,
                rst => reset,
                en => enable,
                Q => ALU_2
            );	
	
 	R2: reg16   port map (
                D => IR_1,
                clk => clk,
                rst => reset,
                en => enable,
                Q => IR_2
            );
				
	ALU1: alu	port map(a=> ALU_1,b=> ALU_2,
							sel=>IR_2(15 downto 12),
							s=>ALU_out);
						
						
	
 	R_rs: reg16   port map (
                D => ALU_1,
                clk => clk,
                rst => reset,
                en => enable,
                Q => rs_value
            );
	
 	RALU: reg16   port map (
                D => ALU_out,
                clk => clk,
                rst => reset,
                en => enable,
                Q => ALU_output
            );
				
	R3: reg16   port map (
                D => IR_2,
                clk => clk,
                rst => reset,
                en => enable,
                Q => IR_3
            );
			
		
	DMEM: ring_buffer
		port map(
			clk => clk,
			rst => reset,
			wr_en => sel3,
			wr_data => rs_value,
			rd_en => sel2,
			rd_valid => rd_valid_DMEM,
			rd_data => mem_out,
			empty => open,
			empty_next => open,
			full => open,
			full_next => open,
			fill_count => open
		);
			
	MUX2: mux_16_2_1 port map(
						a=>ALU_output , b=> mem_out, 
						sel=> sel2, 
						Y=> out_temp
					);		
				
	R4: reg16   port map (
                D => IR_3,
                clk => clk,
                rst => reset,
                en => enable,
                Q => IR_4
            );
				
	RMEM: reg16   port map (
                D => out_temp ,
                clk => clk,
                rst => reset,
                en => enable,
                Q => data_rd
            );
		
process(clK)
    begin
			if falling_edge(clk) then 
				enable <= '1';	
			end if;
			jump<= IR_1(14) and IR_1(13) and IR_1(12);
			jump_bar<= not(IR_1(14) and IR_1(13) and IR_1(12));
			sel1 <= IR_1(14) and IR_1(12); --imm vs rt
			sel2 <= (not IR_3(14)) and (not IR_3(13)) and (not IR_3(12)); -- load 1 rest 0
			sel3 <= (not IR_3(14)) and (not IR_3(13)) and IR_3(12); --Store 1 rest 0
			sel3_1 <=((not IR_1(14)) and (not IR_1(13)) and IR_1(12)) or ((IR_1(14)) and (IR_1(13)) and (IR_1(12))); --Store and Jump 1 rest 0
			sel4 <= not ( ((not IR_4(14)) and (not IR_4(13)) and IR_4(12)) or ((IR_4(14)) and (IR_4(13)) and (IR_4(12))) ); -- Store/Jump 0 rest 1
	end process;

PC<=PC2;
mem_IR<=IR_1;
--store_data<= rs_value;
store_sel <= sel2;				
rf_data_wr <= data_rd;				
rd_data_DMEM <= mem_out;
end architecture;