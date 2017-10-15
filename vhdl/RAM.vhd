library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        rddata  : out std_logic_vector(31 downto 0));
end RAM;

architecture synth of RAM is
signal flag : std_logic;
signal temp_add : std_logic_vector(9 downto 0);
type memory_block is array (0 to 1023) of std_logic_vector(31 downto 0);
signal memory: memory_block := (others => (others => '0'));

begin

reading_save : process(clk)
begin
	if(rising_edge(clk)) then	
		flag <= read and cs;
		temp_add <= address;
end if;
end process;

reading : process(flag, memory, temp_add)
begin
   if(flag = '1') then
	rddata <= memory(to_integer(unsigned(temp_add)));
   else 
       rddata <= (others => 'Z');
   end if;
end process;


writing : process(clk)
begin
    if(rising_edge(clk)) then
	if(cs = '1' and write = '1') then
	    memory(to_integer(unsigned(address))) <= wrdata;
	end if;
    end if;
end process;


end synth;
