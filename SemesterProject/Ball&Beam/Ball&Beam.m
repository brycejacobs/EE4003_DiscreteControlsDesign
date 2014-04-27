%Ball-Beam System

%Given specifications
format compact
s=tf('s')
g=9.8
r=0.0254
L=0.42545

%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
%Feedback Compensator for DC servo / Inner Loop
%Given specifications
ts1=0.3
PO1=.1

zeta1=sqrt((log(PO1))^2/((pi^2+(log(PO1))^2)))
%zeta1 = 0.5912
PM1=100*zeta1
%PM1 = 59.1155

wn1=4.6/(zeta1*ts1)%use this as your value of wn

wWBs1=wn1*sqrt(1-2*zeta1^2+sqrt(2+4*zeta1^4-4*zeta1^2))
wc1=(4.6)*wWBs1 %multiply wWBs to get value between 10~30
     %to speed up the process, we will set wc1 in between the required
     %values

wc1=24          %DESIGN

Gs=tf(61.54, [1 35.1 0])
bode(Gs)
grid on
title('Bode Plot of DC Servo')
pause

%Using wc1, we gather from the Bode Plot
GMs1=-24.5
PhaseGs1=-125

phim1=PM1-(180+PhaseGs1)+3 %add a 3~5 due to the possible presence of lag
                     %the compensator that will destroy a few degrees of PM

%check the value of phim to see if the system requires a double lead
%compensator
alpha1=((1-sind(phim1))/(1+sind(phim1)))

K1=10^(GMs1/-20) %confirmed that this is the correct way
z1=wc1*(sqrt(alpha1))
p1=wc1/(sqrt(alpha1))

Dlds1=(K1/alpha1)*tf([1 z1],[1 p1])

D1_s=Dlds1
zpk(D1_s)

PID_D1 = pid(D1_s)

%Transfer function of DC Servo/Inner Loop
Ts1=feedback(D1_s*Gs,1)
bode(Ts1)
grid on
title('Bode Plot of DC Servo/Inner Loop')
pause

step(Ts1)
title('Feedback Loop of DC Servo')
s1=stepinfo(Ts1)
pause
%by observing the result from the stepinfo, it is confirmed that the
%specifications for the inner loop have been satisfied

%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////

%Feedback Compensator for Ball and Beam / Outer Loop
%Given specifications
ts2=5
PO2=.15
%percent overshoot needs to be less than 15% so we can set PO2 to any value
%below that. This is ultimately done to change the value of alpha2
PO2=.071

zeta2=sqrt((log(PO2))^2/((pi^2+(log(PO2))^2)))
%zeta2 = 0.5169
PM2=100*zeta2
%PM2 = 51.6931

wn2=4.6/(zeta2*ts2)%use this as your value of wn

wWB2=wn2*sqrt(1-2*zeta2^2+sqrt(2+4*zeta2^4-4*zeta2^2))
wc2=(4.7)*wWB2 %multiply wWBs to get value between 1~5
    %to speed up the process, we will set wc2 in between the required
    %values

wc2=2.65         %DESIGN

Gbs2=g*tf(5,[7 0 0])
bode(Gbs2)
grid on
title('Bode Plot of Ball & Beam System')
pause

%Using wc2, we gather from the Bode Plot
GM2=-0.0101
PhaseG2=-180

phim2=PM2-180-PhaseG2+3 %add a 3~5 due to the possible presence of lag
                     %the compensator that will destroy a few degrees of PM
%check the value of phim to see if the system requires a double lead
%compensator
alpha2=((1-sind(phim2))/(1+sind(phim2)))
%this result is that alpha2=0.1013 when PO=15%. This value needs to be
%altered

mag2=10^(GM2/-20)

%set alpha to reach desired gain to aquire appropriate step response
%alpha2=.04 .... to achieve this we reduced the PO at the beginning
K2=sqrt(alpha2)/mag2
z2=wc2*(sqrt(alpha2))
p2=wc2/(sqrt(alpha2))

Dld2=(K2/alpha2)*tf([1 z2],[1 p2])

D2_s=Dld2
zpk(D2_s)

PID_D2 = pid(D2_s)

%Transfer function of Ball and Beam system
Ts2=feedback(D2_s*Gbs2,1)
bode(Ts2)
grid on
title('Bode Plot of DC Ball without Ball&Beam/Outer Loop')
pause

step(Ts2)
title('Feedback Loop of Ball without Ball&Beam')
s2=stepinfo(Ts2)
pause

%Transfer function of entire Ball and Beam system

Tsf=feedback(Ts1*D2_s*Gbs2,1)
bode(Tsf)
grid on
title('Bode Plot of Entire Ball and Beam system')
pause

step(Tsf);
title('Feedback Loop of Ball with DC Servo/Entire System')
s3=stepinfo(Tsf)
pause