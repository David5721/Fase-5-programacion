%% RETO 3 - MICRO-RED HIBRIDA CON GESTION SOC - SIGE

% Contextualizacion Tecnica: Junta Tecnica

clear; clc;

%% PASO 1: PARAMETROS DE DISEÑO 
horas = 1:24;
Pmax_solar = 12; % kW hora 12
Pmax_eolica = 8; % kW limite superior
Capacidad_Bat = 35; % kWh 
SOC = 50; % % Estado inicial 

%% Generacion Solar - Modelado senoidal
P_solar = zeros(1,24);
for h = 6:18
    P_solar(h) = Pmax_solar * sin(pi * (h - 6) / 12);
end

%% Generacion Eolica 
P_eolica = Pmax_eolica*(0.3 + 0.7 * rand(1,24)) + 0.5*randn(1,24);
P_eolica(P_eolica < 1) = 1 + rand; % corrige negativos a minimo 1kW
P_eolica(P_eolica > Pmax_eolica) = Pmax_eolica; % corte maximo 15kW

%% Generacion Hibrida
P_total = P_solar + P_eolica; % Egen = Solar + Eolica (literal b)

%% Demanda de la comunidad - Edem
P_demanda = zeros(1,24);
P_demanda(1:5) = 2 + 2*rand(1,5);
P_demanda(22:24) = 2 + 2*rand(1,3);
P_demanda(6:17) = 6 + 4*rand(1,12);
P_demanda(18) = 12 + 1*rand;
P_demanda(19) = 14 + 1*rand;
P_demanda(20) = 15;
P_demanda(21) = 12.5 + 1.5*rand;

%% PASO 2: ALGORITMO SIGE - GESTION SOC Y PRIORIZACION DE CARGAS

SOC_vector = zeros(1,24);
Estado_Escuela = strings(1,24);
Estado_Bombeo = strings(1,24);
Estado_Alumbrado = strings(1,24);
Balance = zeros(1,24);

SOC_actual = SOC;

for h = 1:24
    Egen = P_total(h);
    Edem = P_demanda(h);
    Balance(h) = Egen - Edem; % >0 superavit, <0 deficit

    if Egen >= Edem
        % Excedente
        Excedente = Egen - Edem;
        SOC_nuevo = SOC_actual + (Excedente / Capacidad_Bat * 100);
        SOC_nuevo = min(SOC_nuevo, 100); % Limitar a 100% maximo

        Estado_Escuela(h) = "ACTIVO";
        Estado_Bombeo(h) = "ACTIVO";
        Estado_Alumbrado(h) = "ACTIVO";
    else
        % Faltante y logica de deficit
        Faltante = Edem - Egen;
        SOC_nuevo = SOC_actual - (Faltante / Capacidad_Bat * 100);
        SOC_nuevo = max(SOC_nuevo, 0); % Limitar a 0% minimo

        % Priorizacion de cargas
        if SOC_actual > 40
            Estado_Escuela(h) = "ACTIVO";
            Estado_Bombeo(h) = "ACTIVO";
            Estado_Alumbrado(h) = "ACTIVO";
        elseif SOC_actual > 20
            Estado_Escuela(h) = "ACTIVO";
            Estado_Bombeo(h) = "ACTIVO";
            Estado_Alumbrado(h) = "SUSPENDIDO";
        else
            Estado_Escuela(h) = "ACTIVO";
            Estado_Bombeo(h) = "SUSPENDIDO";
            Estado_Alumbrado(h) = "SUSPENDIDO";
        end
    end

    SOC_vector(h) = SOC_nuevo;
    SOC_actual = SOC_nuevo;
end

%% Visualizacion
figure;% Crea una nueva ventana grafica
plot(horas, P_total, "b-", "LineWidth", 2.5); hold on;
plot(horas, P_demanda, "r-", "LineWidth", 2.5);
plot(horas, Balance, "g--", "LineWidth", 1.5);
grid on;
title("Reto 3: Balance Energetico con Gestion SOC");
xlabel("Tiempo (horas)");
ylabel("Potencia (kW) / SOC (%)");
legend("Generacion Total (Egen)", "Demanda (Edem)", "Balance");

%% REPORTE POR CONSOLA 
fprintf("\n=================================================================\n");
fprintf("REPORTE HORARIO SIGE - MICRO-RED HIBRIDA - RETO 3\n");
fprintf("=================================================================\n");
fprintf("Hora | Egen(kW) | Edem(kW) | Balance | SOC(%%) | Escuela | Bombeo | Alumbrado\n");
fprintf("-----------------------------------------------------------------\n");

for h = 1:24
    fprintf("%2d:00 | %6.2f | %6.2f | %6.2f | %5.1f%% | %7s | %6s | %9s\n", ...
        h, P_total(h), P_demanda(h), Balance(h), SOC_vector(h), ...
        Estado_Escuela(h), Estado_Bombeo(h), Estado_Alumbrado(h));
end

fprintf("=================================================================\n");
fprintf("Resumen: SOC Inicial 50%% -> SOC Final %.1f%%\n", SOC_vector(24));
