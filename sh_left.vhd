library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sh_left is

	port(
		input 		: in std_logic_vector(31 downto 0);
		output 		: out std_logic_vector(31 downto 0)
	);
	
end sh_left;

architecture BHV of sh_left is

begin
	
	output <= std_logic_vector(shift_left(unsigned(input), 2));

end BHV;