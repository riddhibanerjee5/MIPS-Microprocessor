library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_extend is

	port(
		input 		: in std_logic_vector(15 downto 0);
		output 		: out std_logic_vector(31 downto 0);
		is_Signed 	: in std_logic
	);
	
end sign_extend;


architecture BHV of sign_extend is

begin

	process(is_Signed, input)
	begin
	
	if(is_Signed = '1') then
		output <= std_logic_vector(resize(signed(input), 32));
		
	else
--		input <= input;
		output <= std_logic_vector(resize(unsigned(input), 32));
--		output <= "0000000000000000" & input;
			
	end if;
	
	end process;
	
end BHV;