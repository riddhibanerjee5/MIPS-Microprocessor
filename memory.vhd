library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is

	generic (
		WIDTH : positive := 32
	);

	port (
		clk				: in std_logic;
		rst				: in std_logic;
		inport0			: in std_logic_vector(WIDTH-1 downto 0);
		inport1			: in std_logic_vector(WIDTH-1 downto 0);
		wr_en			: in std_logic;
		inport0_en		: in std_logic;
		inport1_en		: in std_logic;
		byte_address	: in std_logic_vector(WIDTH-1 downto 0);
		wr_data			: in std_logic_vector(WIDTH-1 downto 0);
		
		out_data		: out std_logic_vector(WIDTH-1 downto 0);
		outport			: out std_logic_vector(WIDTH-1 downto 0)
		
	);
	
end memory;

architecture BHV of memory is

	signal ram_out 		: std_logic_vector(WIDTH-1 downto 0);
	signal ram_en		: std_logic;
	signal inport0_out	: std_logic_vector(WIDTH-1 downto 0);
	signal inport1_out	: std_logic_vector(WIDTH-1 downto 0);
	signal mux_sel		: std_logic_vector(1 downto 0);
	signal outport_en	: std_logic;
	

begin

	U_RAM : entity work.ram 
	port map(
		address => byte_address(9 downto 2),
		clock => clk,
		data => wr_data,
		wren => ram_en,
		q => ram_out
	);
	
	U_INPORT0 : entity work.reg 
	generic map( width => WIDTH)
	port map(
		clk => clk,
		rst => '0',
--		rst => rst,
		load => inport0_en,
		input => inport0,
		output => inport0_out
	);
	
	U_INPORT1 : entity work.reg 
	generic map( width => WIDTH)
	port map(
		clk => clk,
		rst => '0',
--		rst => rst,
		load => inport1_en,
		input => inport1,
		output => inport1_out
	);
		
	U_MUX3x1 : entity work.mux3x1
	generic map( width => WIDTH)
	port map(
		in1 => inport1_out,  -- "10"
		in2 => inport0_out, -- "01"
		in3 => ram_out,  -- "00"
		sel => mux_sel,
		output => out_data
	);
	
	U_OUTPORT : entity work.reg
	generic map( width => WIDTH)
	port map(
		clk => clk,
		rst => rst,
		load => outport_en,
		input => wr_data,
		output => outport
	);		
	
	
	process(wr_en, byte_address)
	
	begin
	
		outport_en <= '0';
		ram_en <= '0';
		mux_sel <= "11";
		
		if(unsigned(byte_address) = 16#0000FFF8#) then		-- inport0 start address

			mux_sel <= "01";
			
		elsif(unsigned(byte_address) = 16#0000FFFC#) then	-- inport1 start address
			if(wr_en = '1') then
				outport_en <= '1';
			end if;
			
			mux_sel <= "10";
			
		elsif(signed(byte_address) >= 0 and signed(byte_address) < 1024) then
			if(wr_en = '1') then
				ram_en <= '1';
			else
				ram_en <= '0';
			end if;

			mux_sel <= "00";
			
		end if;
	
	end process;
		

end BHV;