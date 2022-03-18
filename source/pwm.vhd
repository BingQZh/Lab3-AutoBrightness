----------------------------------------------------------------------------------
-- Course: ENSC462
-- Group #: 9 
-- Engineer: Valeriya Svichkar and Bing Qiu Zhang

-- Module Name: pwm - Behavioral
-- Project Name: Lab3
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity pwm is
    generic (
        pwm_res : natural :=8
    );
    port(
        clock: IN std_logic;
        rst : IN std_logic;
        duty_cycle: IN std_logic_vector(pwm_res-1 downto 0);
        pwm_count: OUT integer range 0 to (2**pwm_res)-1;
        pwm_out: OUT std_logic
    );
end pwm;

architecture rtl of pwm is
    -- clk_counter holds the value of clock cycles passed in the current duty_cycle
    signal clk_counter: integer range 0 to (2**pwm_res)-1 := 0;
    signal pwm: std_logic := '0';
    signal pwm_counter: integer := 0;
    constant cycle_max: integer := (2**pwm_res)-1; --255 periods in a complete cycle if 8 bit resolution
begin
   
    PRESCALER_PROC : process(clock)
    begin
        if rising_edge(clock) then
            if rst = '1' then
                pwm <= '0';
                clk_counter <= 0;
            else
                -- output pwm_out ='1' when clock_counter is smaller than duty_cycle
                if clk_counter < to_integer(unsigned(duty_cycle)) then
                    pwm <= '1';
                    clk_counter <= clk_counter + 1;
                else
                    pwm <= '0';
                    clk_counter <= clk_counter + 1; 
                end if;
                
                -- reset clock counter when max cycle reached
                if clk_counter = cycle_max-1 then --reset clock counter
                    clk_counter <= 0;
                end if;
            end if;
        end if;

        pwm_count <= clk_counter ;
        pwm_out <= pwm;

    end process;

end rtl;
