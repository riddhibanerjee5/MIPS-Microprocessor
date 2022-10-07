library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity board is
	port(
		clk 	 : in  std_logic;
 --       rst      : in  std_logic;
        switch   : in  std_logic_vector(9 downto 0);
        button   : in  std_logic_vector(1 downto 0);
        led0     : out std_logic_vector(6 downto 0);
        led0_dp  : out std_logic;
        led1     : out std_logic_vector(6 downto 0);
        led1_dp  : out std_logic;
        led2     : out std_logic_vector(6 downto 0);
        led2_dp  : out std_logic;
        led3     : out std_logic_vector(6 downto 0);
        led3_dp  : out std_logic;
        led4     : out std_logic_vector(6 downto 0);
        led4_dp  : out std_logic;
        led5     : out std_logic_vector(6 downto 0);
        led5_dp  : out std_logic
        );
end board;


architecture BHV of board is
	
	signal inport0   	: std_logic_vector(31 downto 0);
    signal inport1  	: std_logic_vector(31 downto 0);
	signal outport		: std_logic_vector(31 downto 0);
	signal inport0_en   : std_logic;
	signal inport1_en   : std_logic;
	signal rst	 	 	: std_logic;	
	
begin

	U_TOP_LEVEL : entity work.top_level
	generic map ( WIDTH => 32)
	port map(
		clk => clk,
		rst => rst,
		inport0 => inport0,
		inport1 => inport1,
		inport0_en => inport0_en,
		outport => outport,
		inport1_en => inport1_en
	);
	
	U_LED5 : entity work.decoder7seg
	port map(
		input  => outport(15 downto 12),
        output => led5
	);
	
	U_LED4 : entity work.decoder7seg
	port map(
		input  => outport(11 downto 8),
        output => led4
	);
	
	U_LED3 : entity work.decoder7seg
	port map(
		input  => outport(7 downto 4),
        output => led3
	);
	
	U_LED2 : entity work.decoder7seg
	port map(
		input  => outport(3 downto 0),
        output => led2
	);
	
	U_LED1 : entity work.decoder7seg
	port map(
		input  => "0000",
        output => led1
	);
	
	U_LED0 : entity work.decoder7seg
	port map(
		input  => "0000",
        output => led0
	);
	
	
	inport0 <= "00000000000000000000000" & switch(8 downto 0);
    inport1 <= "00000000000000000000000" & switch(8 downto 0);
	
	
	rst <= not button(0);
	
	inport0_en <= not button(1) and not switch(9);
	inport1_en <= not button(1) and switch(9);



end BHV;