----------------------------------------------------------------------------------
-- Course: ENSC462
-- Group #: 9 
-- Engineer: Valeriya Svichkar and Bing Qiu Zhang

-- Module Name: prescaler - rtl
-- Project Name: Lab3
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity prescaler is
    generic (
        fpga_clk : integer; --:100e6
        pwm_clk : integer; --:=4e6
        pwm_res : integer --8
    );
    port(
        clk     : IN std_logic;
        rst     : IN std_logic;
        clock_out   : OUT std_logic
    );
end prescaler;

architecture rtl of prescaler is
    signal counter  : integer := 0;
    signal out_clock : std_logic := '0';

    -- Calculate the maximum counter limit
    constant clock_ctr : integer := fpga_clk/pwm_clk*((2**pwm_res)-1);
    
begin

    PRESCALER_PROC : process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;
            if counter = (clock_ctr-1) then
                counter <= 0;
            end if;

            if counter < (clock_ctr/2 - 1) then
                out_clock <= '0';
            else
                out_clock <= '1';
            end if;
        end if;
    end process;

    clock_out <= out_clock;

end architecture;