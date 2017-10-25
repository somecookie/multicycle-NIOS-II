library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
port(
	clk : in std_logic;
	reset_n : in std_logic;
	en : in std_logic;
	sel_a : in std_logic;
	sel_imm : in std_logic;
	add_imm : in std_logic;
	imm : in std_logic_vector(15 downto 0);
	a : in std_logic_vector(15 downto 0);
	addr : out std_logic_vector(31 downto 0)
     );
end PC;

architecture synth of PC is
	signal counter: std_logic_vector(13 downto 0) := (others => '0');
begin

p_counter: process(clk, reset_n)
begin
	if(reset_n = '0') then
		counter <= (others => '0');
	elsif(rising_edge(clk)) then
		if(en = '1') then
			if(add_imm = '1') then
				counter <= std_logic_vector(unsigned(counter) + unsigned(imm(15 downto 2)));
			elsif(sel_imm = '1') then
				counter <= std_logic_vector(unsigned(imm(13 downto 0)));
			elsif(sel_a = '1') then
				counter <= a(15 downto 2);
			else
				counter <= std_logic_vector(unsigned(counter) + 1);
			end if;
		end if;
	end if;
end process;

addr <= (15 downto 0 => '0') & counter & "00";

end synth;
