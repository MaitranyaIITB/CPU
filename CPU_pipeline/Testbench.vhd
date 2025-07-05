LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity testbench is 
end testbench;

architecture rtl of testbench is

-- Declaring component to test
	component micro_cpu is
		generic (
			 -- 16 bit data
			 RAM_WIDTH : integer := 16;
			 RAM_DEPTH : integer := 32
		  );
		port(
		 clk : in std_logic;
		 reset : in std_logic;
		 
		 -- Write to imem
		 wr_en_IMEM : in std_logic;
		 wr_data_IMEM : in std_logic_vector(RAM_WIDTH - 1 downto 0);
		 
		 -- Read from dmem
		 PC: out std_logic_vector(15 downto 0);
		 --store_data : out std_logic_vector(15 downto 0);
		 rf_data_wr : out std_logic_vector(15 downto 0);
		 mem_IR: out std_logic_vector(15 downto 0);
		 rd_valid_DMEM : out std_logic;
		 store_sel: out std_logic;
		 rd_data_DMEM : out std_logic_vector(RAM_WIDTH - 1 downto 0)
		);
	end component;
	
	-- Signal Declarations
	signal PC: std_logic_vector(15 downto 0):= (others => '0');
	signal clk : std_logic := '0';
	signal rst : std_logic := '1';
	signal wr_en_IMEM : std_logic;
	signal wr_data_IMEM : std_logic_vector(15 downto 0);
	signal rf_data_wr: std_logic_vector(15 downto 0);
	signal store_sel: std_logic;
	signal rd_valid_DMEM : std_logic;
	signal mem_IR : std_logic_vector(15 downto 0);
	--signal store_data :std_logic_vector(15 downto 0);
	signal rd_data_DMEM : std_logic_vector(15 downto 0);
	begin
	processor: micro_cpu port map(
		clk => clk,
		reset => rst,
		wr_en_IMEM => wr_en_IMEM,
		wr_data_IMEM => wr_data_IMEM,
		rf_data_wr => rf_data_wr,
		PC => PC,
		mem_IR => mem_IR,
		--store_data => store_data,
		store_sel => store_sel,
		rd_valid_DMEM => rd_valid_DMEM,
		rd_data_DMEM => rd_data_DMEM
	);
	
	clk <= not clk after 10 ns;
	rst <= '1', '0' after 5 ns;
	
	process begin
		wait for 100ns;
		
		

		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(21058,16)));--r1=r1+2
		
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(24525,16)));--r7=r7+13
		
		wait for 20ns;	
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(20490,16)));--r0=r0+10

		
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(21699,16)));--r2=r3+3
		
			
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(22789,16)));--r4=r4+5
		
			
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(4608,16)));--sw r1
		
		
		wait for 20ns;
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(32262,16)));--PC=PC+(r7+6*2)
		
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(5120,16)));--sw r2
		
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(23943,16)));--r6=r6+7
		
		
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(4096,16)));--sw r0
		
--		wait for 20ns;
--		
--		wr_en_IMEM <= '1';
--		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(23943,16)));--r6=r6+7
		
		
		
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(23364,16)));--r5=r5+4
		
		
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(18104,16)));--r3=r2*r7
		
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(0,16)));-- lw r0
		
		
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(26888,16)));-- r4=sll(r4,r1)
		
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(21058,16)));--r1=r1+2
		
		
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(15784,16)));-- r6=r6-r5
		
		
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(1024,16)));-- lw r2
		
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(22789,16)));--r4=r4+5
		
		wait for 20ns;
		
		wr_en_IMEM <= '1';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(0,16)));-- lw r0
		
		
		wait for 20ns;
		
		wr_en_IMEM <= '0';
		wr_data_IMEM <= std_logic_vector((to_UNSIGNED(24140,16)));--r7=r1+12
		

		wait;
	end process;
	
	
	
--		
--		wait for 500ns;
--		rd_en_DMEM <= '1';
--		assert(to_integer(unsigned(rd_data_DMEM)) = 1234)
--			report "wrong value"
--			severity ERROR;

end architecture;