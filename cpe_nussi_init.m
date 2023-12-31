%% Sammelschienenkurzschluss
% Daniel Nussbaum, 16.11.2023
clearvars;
close all;

%% Sammelschiene-Q
SS_Q_U = 20e3; % Volt

%% Sammelschiene-A
SS_A_U = 400; % Volt

%% Sammelschiene-B
SS_B_U = 400; % Volt

%% Generator

% Konstant
G_Sr = 510e3; % Volt Ampere
G_Ur = 480; % Volt
G_xxd = 8/100; % Prozent
G_CosPhi = 0.65; % Radianten
G_R2X = 0;
G_C = 1.1;

% Berechnung
G_X = G_xxd * (G_Ur^2 / G_Sr);
G_R = G_X * G_R2X;
G_Z = G_R + G_X * 1i;
G_K = G_C / (1 + G_xxd * sin(acos(G_CosPhi))) * (SS_A_U / G_Ur);
G_Z = G_Z * G_K;

%% Transformator

% Konstanten
T_Sr = 1.038e6; % Volt Ampere
T_U1_zu_U2 = 20e3 / 0.4e3; % 1
T_R2X = 0.1; % 1
T_uk = 4 / 100; % 1

% Berechnung
T_Z_Betrag = (T_uk*SS_A_U^2)/T_Sr;
T_X = T_Z_Betrag/(sqrt(1 + T_R2X^2));
T_R = T_X * T_R2X;
T_Z = T_R + T_X * 1i;


%% Ersatz Netz

% Konstanten
N_SSk = 8.743e6; % Volt Ampere
N_UQ1 = 20e3; % Volt
N_R2X = 0.1; % 1
N_Faktor = 1.1; % 1

% Berechnung
N_Z_Betrag = (N_Faktor*SS_A_U^2) / N_SSk;
N_X = N_Z_Betrag / sqrt(1 + N_R2X^2);
N_R = N_X * N_R2X;
N_Z = N_R + N_X * 1j;

%% Leitungen

% Konstanten
L_A = 95; % mm²
L_Xk = 0.1; % Ohm pro km
L_Gama = 56; % Leitwert Simens Meter / mm²
L_Tc = 45; % Grad Celcis
L_Tk = L_Tc+273.15; % Grad Kelvin

L1_l = 430; % Meter
L2_l = 206; % Meter

% Berechnung
L1_R = L1_l/(L_Gama*L_A)*(1+0.004*(L_Tc-20));
L1_Rkm = L1_R/(L1_l/1000);
L1_X = L_Xk*L1_l*0.001;
L1_Xkm = L1_X/(L1_l/1000);
L1_Z = L1_R+L1_X*1i;

L2_R = L2_l/(L_Gama*L_A)*(1+0.004*(L_Tc-20));
L2_Rkm = L2_R/(L2_l/1000);
L2_X = L_Xk*L2_l*0.001;
L2_Xkm = L2_X/(L2_l/1000);
L2_Z = L2_R+L2_X*1i;


%% Asynchronmaschiene

% Konstanten
ASM_Pr = 109e3; % Watt
ASM_n = 85/100; % Prozent
ASM_Ian2In = 7; % 1
ASM_Ur = 400; % Volt
ASM_CosPhi = 0.65; % Radianten
ASM_R2X = 0.42; % 1

% Berechnung
ASM_Z_Betrag = ((ASM_n * ASM_CosPhi) / ASM_Ian2In) * (ASM_Ur^2 / ASM_Pr);
ASM_X = ASM_Z_Betrag / sqrt(1 + ASM_R2X^2);
ASM_R = ASM_X * ASM_R2X;
ASM_Z = ASM_R + ASM_X * 1j;

%% Sonstiges

% Gesamtimpedanz
Ges_Z_temp_1 = (L1_Z*L2_Z)/(L1_Z+L2_Z);
Ges_Z_temp_2 = (G_Z*ASM_Z)/(G_Z+ASM_Z);
Ges_Z_temp_3 = Ges_Z_temp_1 + T_Z + N_Z;
Ges_Z = (Ges_Z_temp_2*Ges_Z_temp_3)/(Ges_Z_temp_2+Ges_Z_temp_3);

Ges_R = real(Ges_Z);
Ges_X = imag(Ges_Z);
Ges_R2X = Ges_R / Ges_X;
Ges_Phi = atan(Ges_X / Ges_R);

% Anfangskurzschlusswechselstrom
Ik_C = 1.1;
Ik= (Ik_C * SS_B_U)/(sqrt(3)*Ges_Z);

% Stoßkurzschlussstrom
ip_K = 1.02+0.98*exp(-3*Ges_R2X);
ip = ip_K * sqrt(2) * Ik;

% Stromverlauf (SV)
SV_t = 120e-3;
SV_f = 50;
SV_Psi = deg2rad(20);
    
SV_L = (tan(Ges_Phi) * Ges_R) / (2*pi*SV_f);
SV_tau = SV_L / Ges_R;

SV_t = linspace(0,SV_t, 1000);
SV_I_ks = sqrt(2)*Ik*sin(2*pi*SV_f*SV_t+SV_Psi-Ges_Phi);

% Stromverlauf Plot
hold on;
grid on;
plot(SV_t,SV_I_ks);
xlabel("Zeit t/s");
ylabel("Kurzschlussstrom I/A");
title("Kurzschlussstromverlauf");