globals [ 
  direct-control-parents
  direct-control-police
  community-unemployment
  community-norm
  domestic-violence-rate ;; this replaces "family disruption"
  school-violence
  school-involvement
  government-initial-income ;; ticks will affect this part
  government-total-income
  funding-apply-rate ;; this is decided by investment-method on the interface
  business-index ;; how thriving this area is
  total-number-of-crimes ;; counter, totally
]

patches-own [
  personal-stress
  personal-stress-base
  self-control
  propensity-to-aggression ;; genetic
  exposure-to-delinquent-peers
  exposure-to-delinquent-peers-base ;; base
  attachment-to-parents
  attachment-to-parents-base ;; base
  family-income
  personal-goal
  personal-goal-base ;; personal
  relations-with-peers
  relations-with-peers-base ;; base
  personal-belief
  personal-belief-base ;; genetic
  delinquent-likelihood
]

to setup
  clear-all
  check-user-input
  setup-enviornment-variables
  setup-patches
  reset-ticks
end

to-report total-proportion
  let result proportion-of-family-subsidy + proportion-of-police-control + proportion-of-small-medium-business + proportion-of-educational-programs
  ifelse result > 1 [ user-message "can't be larger than 1" ]
  [ report result ]
end

to check-user-input
  if proportion-of-family-subsidy + proportion-of-police-control + proportion-of-small-medium-business + proportion-of-educational-programs > 1
  [ error "can't be larger than 1" ]
end

to setup-enviornment-variables
  set government-initial-income 10
  set government-total-income government-initial-income + additional-funding
  set community-unemployment 21 ;; NJ.com income less than $20,000 employment rate 21%
  set domestic-violence-rate 23 ;; 23% women receiving food welfare was abused in the past 12 months - page 4 http://www.vawnet.org/Assoc_Files_VAWnet/BCS15_BP.pdf
  
  set school-violence 30 ;;not sure about this
  set school-involvement 10 ;;not sure
  
  set direct-control-parents 10 ;; made up number
  set direct-control-police 20 ;; made up number (Think about "Charlestown" in the movie "The Town")
  
  if investment-method = "aggressive" [set funding-apply-rate [0.1 0.5 0.2 0.2] ] ;; Q1 -> 1, Q2 -> 2, Q3 -> 3, Q4 -> 0
  if investment-method = "smooth" [set funding-apply-rate [0.25 0.25 0.25 0.25] ]
  if investment-method = "delayed" [set funding-apply-rate [0.5 0.1 0.2 0.2] ]
  
  if community-attitude = "Positive" [ set community-norm 70 ]
  if community-attitude = "Neutral" [ set community-norm 50 ]
  if community-attitude = "Negative" [ set community-norm 30 ]
  if community-attitude = "Extremely Negative" [ set community-norm 10 ]
  
  set business-index 5
end

to setup-patches
  foreach n-values 15 [?]
  [ let $x ? - 7
    foreach n-values 15 [?] ;;this is y variable
    [ let $y ? - 7
      ;; this is the initiation of all patches
      ;;set up individual value
      ask patch $x $y [
        set self-control 20 * abs random-normal 0 50 / 100 ;;only self-control is genetic (all in 100)
        set family-income 20 * abs random-normal 0 50 / 100 ;; 10-30 are low income, 30-60 medium, 60-90 high, 100 wealthy $13,000 is the wage for McDonald's worker
        set personal-goal-base 20 * abs random-normal 0 50 / 100 ;; different people have different dreams
        set personal-belief-base 20 * abs random-normal 0 50 / 100
        set personal-stress-base direct-control-parents * 0.1 + domestic-violence-rate * 0.5 + school-violence * 0.6
        set attachment-to-parents-base 20 * abs random-normal 0 50 / 100 ;; random attachment to parents
        set relations-with-peers-base 20 * abs random-normal 0 50 / 100
        set exposure-to-delinquent-peers-base 50 * abs random-normal 0 50 / 100
        
        set propensity-to-aggression 30 * abs random-normal 0 50 / 100 ;; genetic
      ]
    ]
  ]
end

to go
  if ticks >= 40 [ stop ] ;; stop after 40 quaters (10 years)
  first-iteration ;;affects all Enviornmental factors
  patch-iteration ;;affects all agent attributes (patch)
  tick
end

to first-iteration
  
  set direct-control-parents direct-control-parents + item remainder ticks 4 funding-apply-rate * government-total-income * proportion-of-family-subsidy * 0.1 + item remainder ticks 4 funding-apply-rate * government-total-income * proportion-of-small-medium-business * 0.1
  set domestic-violence-rate domestic-violence-rate + item remainder ticks 4 funding-apply-rate * government-total-income * proportion-of-family-subsidy * -0.2
  set school-involvement school-involvement + item remainder ticks 4 funding-apply-rate * government-total-income * proportion-of-family-subsidy * 0.1 + item remainder ticks 4 funding-apply-rate * government-total-income * proportion-of-educational-programs * 0.5
  set direct-control-police direct-control-police + item remainder ticks 4 funding-apply-rate * government-total-income * proportion-of-police-control * 0.5
  set school-violence school-violence + item remainder ticks 4 funding-apply-rate * government-total-income * proportion-of-police-control * -0.15 + item remainder ticks 4 funding-apply-rate * government-total-income * proportion-of-educational-programs * -0.1
  set community-unemployment community-unemployment + item remainder ticks 4 funding-apply-rate * government-total-income * proportion-of-small-medium-business * -0.1
  set community-norm community-norm + item remainder ticks 4 funding-apply-rate * government-total-income * proportion-of-educational-programs * 0.2

  ;; this should also be tied to deliquent rate, direct-police control
  set business-index business-index + item remainder ticks 4 funding-apply-rate * government-total-income * proportion-of-small-medium-business * 0.15

end

to patch-iteration
foreach n-values 15 [?]
  [ let $x ? - 7
    foreach n-values 15 [?] ;;this is y variable
    [ let $y ? - 7
      ;; this is the random initiation of all patches
      ;; color range from lowest blue 105 to 109, then to magenta 129 to 125 (red 15 flash means crime)
      
      ;;set up individual value
      ask patch $x $y [
        ;; these two are not very certain, adjust them if you must
        set personal-stress personal-stress-base + direct-control-parents * 0.1 + domestic-violence-rate * 0.5 + school-violence * 0.6 + 10 * abs random-normal 0 50 / 100 ;; plus random events
        set exposure-to-delinquent-peers exposure-to-delinquent-peers-base + direct-control-parents * -0.25 + direct-control-police * -0.25 + school-violence * 0.5
        
        set family-income family-income + business-index / 50 + random-normal 0 1 * business-index ;; first part base, second part adjust the base
        
        set personal-goal personal-goal-base + community-unemployment * 0.15 + school-involvement * 0.1
        set attachment-to-parents attachment-to-parents-base + domestic-violence-rate * -0.23
        set relations-with-peers relations-with-peers-base - school-violence * 0.3 + school-involvement * 0.2
        
        set personal-belief personal-belief-base + community-norm * 0.25
        
        set delinquent-likelihood propensity-to-aggression * 0.5 + personal-stress * 0.23 - self-control * 0.165 + exposure-to-delinquent-peers * 0.556 - attachment-to-parents * 0.155 - family-income * 0.009 - personal-goal * 0.1 - relations-with-peers * 0.165 - personal-goal * 0.08
        
        ;; set up patch color dependent on the delinquent-likelihood
        
        set pcolor scale-color blue delinquent-likelihood 100 0
        
        ;; this should be the right way to do it
        
        if delinquent-likelihood > 0 [
            let crime-dice random delinquent-likelihood
            if crime-dice >= 35 [ 
              set pcolor 15 
              set total-number-of-crimes total-number-of-crimes + 1
            ]
        ]
        
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
302
10
687
416
7
7
25.0
1
10
1
1
1
0
1
1
1
-7
7
-7
7
0
0
1
ticks
30.0

BUTTON
11
14
84
47
Setup
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
100
14
171
47
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
183
14
253
47
Step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
10
62
255
95
proportion-of-family-subsidy
proportion-of-family-subsidy
0
1
0
0.01
1
NIL
HORIZONTAL

SLIDER
9
108
255
141
proportion-of-police-control
proportion-of-police-control
0
1
1
0.01
1
NIL
HORIZONTAL

SLIDER
9
154
256
187
proportion-of-small-medium-business
proportion-of-small-medium-business
0
1
0
0.01
1
NIL
HORIZONTAL

SLIDER
9
201
257
234
proportion-of-educational-programs
proportion-of-educational-programs
0
1
0
0.01
1
NIL
HORIZONTAL

MONITOR
13
247
127
292
Total Proportion
total-proportion
4
1
11

PLOT
247
474
492
679
Quaterly Number of Crimes
Quarter
crime rate
0.0
40.0
0.0
200.0
true
false
"" ""
PENS
"number-of-deliquent-juveniles" 1.0 0 -16777216 true "" "plot total-number-of-crimes"

MONITOR
130
247
257
292
Number of Crimes
total-number-of-crimes
17
1
11

PLOT
5
474
247
679
Quarterly Average Family Income 
Quarter
Average Household Income
0.0
40.0
0.0
100.0
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [family-income] of patches"

PLOT
492
474
741
679
Quarterly unemployment rate
Quarter
unemployment rate
0.0
40.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot community-unemployment"

MONITOR
11
308
130
353
Government Income
government-initial-income + additional-funding
17
1
11

SLIDER
10
423
255
456
additional-funding
additional-funding
0
40
0
1
1
NIL
HORIZONTAL

TEXTBOX
8
688
158
706
Community Status
13
0.0
1

MONITOR
7
713
162
758
NIL
direct-control-parents
4
1
11

MONITOR
170
713
314
758
NIL
direct-control-police
4
1
11

MONITOR
321
713
482
758
NIL
community-unemployment
4
1
11

MONITOR
489
713
618
758
NIL
community-norm
4
1
11

MONITOR
7
766
165
811
NIL
domestic-violence-rate
4
1
11

MONITOR
169
766
281
811
NIL
school-violence
4
1
11

MONITOR
285
766
421
811
NIL
school-involvement
4
1
11

MONITOR
426
766
600
811
NIL
government-total-income
4
1
11

CHOOSER
135
308
282
353
investment-method
investment-method
"aggressive" "smooth" "delayed"
1

CHOOSER
11
365
177
410
community-attitude
community-attitude
"Postive" "Neutral" "Negative" "Extremely Negative"
0

MONITOR
605
766
715
811
NIL
business-index
4
1
11

@#$#@#$#@
## WHAT IS IT?

This is a simulation project designed to study the effect of policy on Juvenile Delinquency rate within a predefined community. It is developed by three undergraduate students: Aiming Nie (team leader, and main programmer), Qi Wu (Sociology student, research analyst), Guhan Wang (data collection) in Emory University, under the advisory of Dr. M.J. Prietula.

The goal of this model is to provide fresh insight into this complicated socioeconomical problem through agent-based modeling.

## HOW IT WORKS

This model uses parameters and statistics from Agnew’s book Juvenile Delinquency: Causes and Control. It is heavily dependent upon already-exisiting sociological model, and the result should only be interpreted in the scope of Agnew's statistical model proposed in the book. Agnew has defined relevant factors related to juvenile delinquency. We have divided these factors into two groups: individual factors and community/environment factors. Program is written as an influential network , where factors affect each other through links. Most links are uni-directional.

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Juvenile Deliquency Education" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>total-number-of-crimes</metric>
    <metric>mean [family-income] of patches</metric>
    <enumeratedValueSet variable="proportion-of-police-control">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-small-medium-business">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-educational-programs">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-family-subsidy">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="additional-funding">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-attitude">
      <value value="&quot;Postive&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investment-method">
      <value value="&quot;smooth&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Juvenile Deliquency Police" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>total-number-of-crimes</metric>
    <metric>mean [family-income] of patches</metric>
    <enumeratedValueSet variable="proportion-of-police-control">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-small-medium-business">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-educational-programs">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-family-subsidy">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="additional-funding">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-attitude">
      <value value="&quot;Postive&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investment-method">
      <value value="&quot;smooth&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Juvenile Deliquency Family Subsidy" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>total-number-of-crimes</metric>
    <metric>mean [family-income] of patches</metric>
    <enumeratedValueSet variable="proportion-of-police-control">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-small-medium-business">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-educational-programs">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-family-subsidy">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="additional-funding">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-attitude">
      <value value="&quot;Postive&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investment-method">
      <value value="&quot;smooth&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Juvenile Deliquency Business" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>total-number-of-crimes</metric>
    <metric>mean [family-income] of patches</metric>
    <enumeratedValueSet variable="proportion-of-police-control">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-small-medium-business">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-educational-programs">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-family-subsidy">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="additional-funding">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-attitude">
      <value value="&quot;Postive&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investment-method">
      <value value="&quot;smooth&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Juvenile Deliquency Balance" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>total-number-of-crimes</metric>
    <metric>mean [family-income] of patches</metric>
    <enumeratedValueSet variable="proportion-of-police-control">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-small-medium-business">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-educational-programs">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-family-subsidy">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="additional-funding">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-attitude">
      <value value="&quot;Postive&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investment-method">
      <value value="&quot;smooth&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Juvenile Deliquency Police Only" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>total-number-of-crimes</metric>
    <metric>mean [family-income] of patches</metric>
    <enumeratedValueSet variable="proportion-of-police-control">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-small-medium-business">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-educational-programs">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-of-family-subsidy">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="additional-funding">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="community-attitude">
      <value value="&quot;Postive&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investment-method">
      <value value="&quot;smooth&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
