----------------------------------------------------------------------------------
-- Course: ENSC462
-- Group #: 9 
-- Engineer: Valeriya Svichkar and Bing Qiu Zhang

-- Module Name: spi_master_tb
-- Project Name: Lab3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity spi_master_tb is
end spi_master_tb;

architecture sim of spi_master_tb is

    constant clk_hz : integer := 100e6;
    constant clk_period : time := 1 sec / clk_hz;
    constant sclk_hz : integer := 4e6; --sensor’s frequency 
    constant sclk_period : time := 1 sec / sclk_hz;
    signal clk : std_logic := '1';
    signal rst : std_logic := '0';
    signal valid: std_logic;
    signal cs : std_logic;
    signal sclk : std_logic; -- sclk is high when cs is '1'
    signal miso : std_logic; -- data is written on falling edge of sclk and read on rising edge of sclk
    signal ready : std_logic := '0';
    signal data : std_logic_vector(7 downto 0);
    signal input_data : std_logic_vector(15 downto 0) := "0000101101110000";

begin

    clk <= not clk after clk_period / 2;

    DUT : entity work.spi_master(rtl)
    port map (
        clk => clk,
        rst => rst,
        valid => valid,
        cs => cs,
        sclk => sclk,
        miso => miso,
        ready => ready,
        data => data
    );

    -- procedure verify(constand d : unsigned (7 downto 0)) is
    --     begin
    --         print("Expecting : " & to_string(d));
    --         next_sample <= d;
    --         ready <= '1';
    --         wait until valid = '1';
    --         ready <= '0'
    --         assert data = std_logic_vector(d)
    --             report "Incorrect data received from DUT. Received: " & to_string(data) &
    --                     ", Expected: " & to_string(d) severity failure;
    --         print("     Test: Passed. ");
    --     end procedure;

    CHECK_PROC : process
    begin

        wait for clk_period * 5;
        ready <= '1';
        first_miso : for i in 0 to 15 loop
            miso <= input_data(i);
            wait for sclk_period * 1;
        end loop first_miso;
        wait for clk_period * 5;

        finish;
    end process;

end architecture;