library ieee;
use ieee.std_logic_1164.all;

entity extend is
    port(
        imm16  : in  std_logic_vector(15 downto 0);
        signed : in  std_logic;
        imm32  : out std_logic_vector(31 downto 0)
    );
end extend;

architecture synth of extend is
signal zeros : std_logic_vector(15 downto 0) := (others => '0');
signal ones : std_logic_vector(15 downto 0) := (others => '1');
begin
extending: process(imm16,signed)
begin
	if(signed = '0') then
		imm32 <= zeros & imm16;
	else
		if(imm16(15) = '1') then
			imm32 <= ones & imm16;
		else
			imm32 <= zeros & imm16;
		end if;
	end if;
end process;
end synth;
