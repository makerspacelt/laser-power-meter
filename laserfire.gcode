%
G21 ; set units to MM (required)
G90 ; absolute position mode (required)
G64P0.1Q0.02
M4 S500
M68 E0 Q80

; fire
G0 Z-1.000
G1 X0.000 Y0.000 F100

#1 = 1 (assign parameter #1 the value of 0)
o101 while [#1 LT 200]
  G1 X0.000 Y0.000
  G1 X1.500 Y0.000
  G1 X1.500 Y1.500
  G1 X0.000 Y1.500
  G1 X0.000 Y0.000
  #1 = [#1+1] (increment the test counter)
o101 endwhile

; stop firing
G0 Z0.000

M5 ; program end
%
