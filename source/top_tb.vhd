library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity top_tb is
end top_tb;

architecture sim of top_tb is

  constant clk_hz : integer := 12e6; -- 100MHz, slow down for simulation
  constant clk_period : time := 1 sec / clk_hz;

  constant sclk_hz : integer := 4e6; --4MHz

  signal clk : std_logic := '1';
  signal rst : std_logic := '0';

  signal cs : std_logic := 'H';
  signal sclk : std_logic;
  signal miso : std_logic := '0';

  signal led_out : std_logic_vector(7 downto 0);

  signal input_data : std_logic_vector(15 downto 0) := "0000101101110000";
  constant sclk_period : time := 1 sec / sclk_hz;
 

begin

  clk <= not clk after clk_period / 2;

  TOP : entity work.top(rtl)
  port map (
    clk => clk,
    rst => rst,
    cs => cs,
    sclk => sclk,
    miso => miso,
    led_out =>led_out
  );



  CHECK_PROC : process
  begin
    wait for clk_period * 200; --for reset to fall back to '0'
      first_miso : for i in 0 to 15 loop
          miso <= input_data(i);
          wait for sclk_period * 1;
      end loop first_miso;
      wait for clk_period * 200;

      finish;
  end process;

end architecture;