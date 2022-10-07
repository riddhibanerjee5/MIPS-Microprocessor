library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sh_left_concat is

	port(
		input 		: in std_logic_vector(25 downto 0);
		output 		: out std_logic_vector(27 downto 0)
	);
	
end sh_left_concat;

architecture BHV of sh_left_concat is

begin
	
	--output <= std_logic_vector(shift_left(unsigned(input), 2));
	output <= input & "00";

end BHV;