----------------------------------------------------------------------------------
-- Course: ENSC462
-- Group #: 9 
-- Engineer: Valeriya Svichkar and Bing Qiu Zhang

-- Module Name: prescaler - Behavioral
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
    --constant fpga_clk : integer := 100e6;-- Integer representing the FPGA clock frequency
    --constant pwm_clk  : integer := 100000000;-- Ingeter representing the clock frequency for pwm ****USING HIGHER PWM_CLK FOR MODELSIM
    --constant pwm_res  : integer := 8;-- Integer of pwm resolution, 8 bits in this lab

    signal counter  : integer := 0;
    signal out_clock : std_logic := '0';

    -- Calculate the maximum counter limit
    constant clock_ctr : integer := fpga_clk/pwm_clk*((2**pwm_res)-1);
    
begin

    PRESCALER_PROC : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                counter <= 0;
                out_clock <= '0';
            else
                -- Increment clock clounter at every FPGA clock
                -- Reset clock counter when maximum counter reached,
                -- invert the resulted clock when half counter reched.
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
        end if;
    end process;

    clock_out <= out_clock;

end architecture;