library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_tb is
end top_level_tb;

architecture BHV of top_level_tb is

	signal clk		: std_logic := '0';
	signal clkEn	: std_logic := '1';
	signal rst		: std_logic;
	
	signal inport0   	: std_logic_vector(31 downto 0);
    signal inport1  	: std_logic_vector(31 downto 0);
	signal outport		: std_logic_vector(31 downto 0);
	signal inport0_en   : std_logic;
	signal inport1_en   : std_logic;	
	
begin

	U_TOP_LEVEL : entity work.top_level
	generic map ( WIDTH => 32)
	port map(
		clk => clk,
		rst => rst,
		inport0 => inport0,
		inport1 => inport1,
		outport => outport,
		inport0_en => inport0_en,
		inport1_en => inport1_en
	);
	
	clk <= not clk and clkEn after 10 ns;
	clkEn <= '0' after 9000 ns;
	
	process
	begin
		rst <= '1';
		wait for 40 ns;
		rst <= '0';
		
		inport0_en <= '1';
		inport1_en <= '1';
		inport0 <= x"000001FF";
		inport1 <= x"000001FF";
		wait for 40 ns;
		inport0_en <= '0';
		
		
		report "Simulation Finished!" severity note;
		wait;
	
	end process;
	
end BHV;