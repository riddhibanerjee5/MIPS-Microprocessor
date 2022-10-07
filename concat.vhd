library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity concat is

	port(
		input 		: in std_logic_vector(27 downto 0);
		concat_amt  : in std_logic_vector(3 downto 0);
		output 		: out std_logic_vector(31 downto 0)
	);
	
end concat;

architecture BHV of concat is

begin
	
	output <= concat_amt & input;

end BHV;