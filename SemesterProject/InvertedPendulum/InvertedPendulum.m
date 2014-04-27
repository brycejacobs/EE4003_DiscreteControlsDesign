%Inverted Pendulum

format compact
s=tf('s')
%wc=6~20
%PM=40~60 degrees

%Lower Margin
PMl=40
zetal=PMl/100
POl=exp((-pi*zetal)/(sqrt(1-zetal^2)))
% the percent overshoot cannot be higher than 25.38%

%Higer Margin
PMh=60
zetah=PMh/100
POh=exp((-pi*zetah)/(sqrt(1-zetah^2)))
% the percent overshoot cannot be lower than 9.48%

%PO= 9.48%~25.38%

%Plant for the Inverted Pendulum from Notes
kgy=2.4805
bgy=(s+5.4506)*(s-5.4506)
ag=s*(s+12.2382)*(s-5.7441)*(s+4.7535)
Gys=kgy*(bgy/ag)

kgt=7.5129
bgt=s^2
Gts=kgt*(bgt/ag)

bode(1/ag)
grid on
title('Bode Plot of plant system 1/a(s)')
pause

%Information taken from the Bode Plot
%wc = 6~20, so
%value of phaseG = -302 ~ -331
%value of GM     = -74.6 ~ -106

%pick a point on bode plot for wc between requirement in homework
%wc=18
%phaseG= -329
%GM=-103

%Choose b(s) of degree 3 that will add a value close to 180 degrees
%The absolute value of the sum of these roots must be greater than wc
%iterative design method

%first two roots
z1=.9+i  %alter values here for design, must z1 <wc, may have to use
             %complex roots for better phase compensation
z2=.9-i  %alter values here for design, must z2 <wc, may have to use
             %complex roots for better phase compensation
             %note: in the notes these values were the same (for double
             %lead purposes)
bs1=(s+z1)*(s+z2)
c1=bs1/ag
bode(c1)
grid on
title('Bode Plot of Two Degree Itertative system b(s)/a(s)')
pause

%check bode to ensure you are within the correct PM
%third root
z3=wc*1.8       %alter value here for design, z3 must wc < z3 < 2wc
%went out of boundaries found in notes for z3

bs2=bs1*(s+z3)
c2=bs2/ag
bode(c2)
grid on
title('Bode Plot of Three Degree Itertative system b(s)/a(s)')
pause

%use the bode plot here to find our K
%wc=18
phaseG1=-125
GM1=-21.1

K1=10^(GM1/-20)

bode(K1*c2)
grid on
title('Bode Plot of Three Degree Itertative system K1*b(s)/a(s)')
pause

%now we have to design the additional pole
pg=wc*4.9      % choose a value for pg, must 2.5wc < pg < 5wc

c3=bs2/((s+pg)*ag)
bode(c3)
grid on
title('Bode Plot of Three Degree Itertative system b(s)/[(s+pg)a(s)]')
pause

%use the bode plot here to find our new K2
%wc=18
phaseG2=-137
GM2=-60.2

K2=10^(GM2/-20)
c4=K2*bs2/((s+pg)*ag)
bode(c4)
grid on
title('Bode Plot of Three Degree Itertative system K2*b(s)/[(s+pg)a(s)]')
pause

Ts=K2*bs2/((s+pg)*ag + K2*bs2)
stepinfo(Ts)
step(Ts)
grid on
title('Step Response of `Ts')


%//////////////////////////////////////////////////////////////////////////
%Use this below to get your final controller after the above is satisfied
num=(s+z1)*(s+z2)*(s+z3)
%use the value solved in the above "num" as your g in the diophatine m-file

%num = s^3 + 34.2 s^2 + 60.13 s + 58.64
[alpha, beta]=diophatine([1 0 0],([1 0 -(5.4506^2)]), [ 1 34.2 60.13 58.64])

%Results from diophaite m-file:
alpha = 3.024*s + 36.1738
beta = -2.024*s + -1.9738

%input values in controller format
Dyu=(K2/2.4805)*(beta/(s+pg))
zpk(Dyu)

Dtu=(K2/7.5129)*(alpha/(s+pg))
zpk(Dtu)

%Check by pluging values into the transfer function of the system (found on
%page 2 of the "Bode Design for Inverted Pendulum" notes)
Sys_T=Dyu/(1 + (Dyu*Gys) + (Dtu*Gts))
step(Sys_T)
stepinfo(Sys_T)
grid on
title('Step Response of Inverted Pendulum Entire System Ts')







