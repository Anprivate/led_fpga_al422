onerror {resume}
quietly WaveActivateNextPane {} 0
delete wave *
add wave -noupdate /al422b_2rgb_8s_vlg_tst/in_nrst
add wave -noupdate /al422b_2rgb_8s_vlg_tst/in_clk
add wave -noupdate -radix hexadecimal /al422b_2rgb_8s_vlg_tst/address
add wave -noupdate -radix hexadecimal /al422b_2rgb_8s_vlg_tst/i1/in_data
add wave -noupdate -radix hexadecimal /al422b_2rgb_8s_vlg_tst/i1/data_decoder/in_data_buffer
add wave -noupdate /al422b_2rgb_8s_vlg_tst/i1/comparator_out
add wave -noupdate /al422b_2rgb_8s_vlg_tst/i1/color_cntr
add wave -noupdate /al422b_2rgb_8s_vlg_tst/i1/rgb_1_2
add wave -noupdate /al422b_2rgb_8s_vlg_tst/i1/data_decoder/phase_reg
add wave -noupdate /al422b_2rgb_8s_vlg_tst/i1/data_decoder/tmp_rgb
add wave -noupdate /al422b_2rgb_8s_vlg_tst/rgb1
add wave -noupdate /al422b_2rgb_8s_vlg_tst/rgb2
add wave -noupdate /al422b_2rgb_8s_vlg_tst/led_clk_out
add wave -noupdate /al422b_2rgb_8s_vlg_tst/led_lat_out
add wave -noupdate /al422b_2rgb_8s_vlg_tst/led_oe_out
add wave -noupdate /al422b_2rgb_8s_vlg_tst/i1/pix_cntr_strobe
add wave -noupdate -radix hexadecimal /al422b_2rgb_8s_vlg_tst/i1/pixel_counter
add wave -noupdate /al422b_2rgb_8s_vlg_tst/i1/row_cntr_strobe
add wave -noupdate -radix hexadecimal /al422b_2rgb_8s_vlg_tst/led_row
add wave -noupdate -radix hexadecimal /al422b_2rgb_8s_vlg_tst/i1/pwm_cntr
add wave -noupdate -radix hexadecimal /al422b_2rgb_8s_vlg_tst/i1/pwm_for_decoder
add wave -noupdate /al422b_2rgb_8s_vlg_tst/al422_nrst
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {150 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {348 ps}
restart -force
run 20000
wave cursor time -time 0 1
wave cursor configure 1 -name default
wave cursor see 1
