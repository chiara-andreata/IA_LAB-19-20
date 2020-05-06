% DEMO DEL PROGETTO DI ASP
% 8 corsi, 10 docenti e 6 settimane di cui la 3 e la 5 complete
% totale slot-ore calendario = 142, ovvero 13 x 4 + 45 x 2
% totale ore di lezione da distribuire = 120

% 6 settimane
settimana(1..6).

% Giorni dal LUN al SAB = 6 giorni di lezioni
giorno(1..6).

% 8 ore al giorno massimo di lezione
ora(1..8).

% Lista insegnamenti
insegnamento(corso_1; corso_2; corso_3; corso_4; corso_5; corso_6; corso_7; corso_8).
insegnamento(presentazione_master).
insegnamento(recupero).

% Lista Docenti
docente(docente1; docente2; docente3; docente4; docente5).

% Relazioni Docente-Insegnamento
insegna(corso_1, docente1).
insegna(corso_2, docente2).
insegna(corso_3, docente2).
insegna(corso_4, docente3).
insegna(corso_5, docente4).
insegna(corso_6, docente5).
insegna(corso_7, docente5).
insegna(corso_8, docente5).

%------------------------- Suddivisione del calendario -------------------------------

% Il calendario è suddiviso in slot orari, cisacuno contrassegnato dalla tripla <settimana,giorno,ora>
% A ciascuno slot del calendario è eventualmente assegnata una lezione
{ si_svolge(I, S, G, O) : insegnamento(I) } 1 :- settimana(S), giorno(G), ora(O).

% Definizione degli slot del calendario, lezioni, in base alla settimana
% Settimana 3, giorni lun-ven, max 8h di lezione
lezione(I,S,G,O) :-             
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S = 3, si_svolge(I,S,G,O).

% Settimana 3, sabato, max 5h di lezione
lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S = 3, G=6, O<6, si_svolge(I,S,G,O).

% Settimana 5, giorni lun-ven, max 8h di lezione
lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S = 5, si_svolge(I,S,G,O).

% Settimana 5, sabato, max 5h di lezione
lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S = 5, G=6, O<6, si_svolge(I,S,G,O).

% Settimana normale, venerdì, max 8h di lezione
lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S != 3, S!=5, G = 5, si_svolge(I,S,G,O).

% Settimana normale, sabato, max 5h di lezione
lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S != 3, S!=5, G = 6, O < 6, si_svolge(I,S,G,O).

%------------------------- Assegnazione id a ciascuno slot del calendario -------------------
% Ogni ora, o slot, del calendario viene contrasseganata con un id progressivo nel soddisfacimento 
% di alcuni vincoli

idOra(S, G, O, COUNT) :-
    settimana(S), giorno(G), ora(O),
    S < 3,
    COUNT = (S - 1) * 12 + (G - 5) * 8 + O.

idOra(S, G, O, COUNT) :-
    settimana(S), giorno(G), ora(O),
    S == 3,
    COUNT = (S - 1) * 12 + (G - 1) * 8 + O.

idOra(S, G, O, COUNT) :-
    settimana(S), giorno(G), ora(O),
    S > 3, S < 5,
    COUNT = (S - 2) * 12 + (G - 5) * 8 + O + 44.

idOra(S, G, O, COUNT) :-
    settimana(S), giorno(G), ora(O),
    S == 5,
    COUNT = (S - 2) * 12 + (G - 1) * 8 + O + 44.

idOra(S, G, O, COUNT) :-
    settimana(S), giorno(G), ora(O),
    S > 5,
    COUNT = (S - 3) * 12 + (G - 5) * 8 + O + 44 + 44.



%------------------------- Definizione vincoli rigidi -------------------------------

%--- Vincolo 1 -- max 4 ore al giorno per docente ---
v1 :- docente(D), insegnamento(I), insegna(I,D),
    #count{O: lezione(I, S, G, O), insegnamento(I), ora(O), settimana(S), giorno(G)} > 4.

%--- Vincolo 2 -- ciascun insegnamento min 2 e max 4 ore al giorno ---
v2min :- insegnamento(I),settimana(S), giorno(G),ora(O), lezione(I, S, G, O), #count{O1: lezione(I, S, G, O1), ora(O1)} < 2.
v2max :- insegnamento(I),settimana(S), giorno(G),ora(O), lezione(I, S, G, O), #count{O1: lezione(I, S, G, O1), ora(O1)} > 4.

%--- Vincolo 3 -- 2 ore di presentazione master il primo giorno ---
v3 :- lezione(presentazione_master, 1, 5, 1), lezione(presentazione_master, 1, 5, 2).

%--- Vincolo 4 -- 2 blocchi da 2 ore per recuperi ---
v4 :- lezione(recupero, S, G, O),ora(O), settimana(S), giorno(G), 
    lezione(recupero, S1, G1, O1), settimana(S1), giorno(G1), ora(O1), 
    idOra(S,G,O,N), idOra(S1,G1,O1,N1), N != N1, N > N1 + 2.                 

%--- Vincolo 5 -- ...
%--- Vincolo 6 -- ...
%--- Vincolo 7 -- ...


% ------------------------- Definizione Vincoli auspicabili---------------------------



% ------------------------ Definizione dei goal --------------------------
goal :- 

% conteggio ore di lezione per ciascuna materia
#count{S, G, O: lezione(presentazione_master, S, G, O), settimana(S), giorno(G),ora(O)} == 2,
#count{S, G, O: lezione(corso_1, S, G, O), settimana(S), giorno(G),ora(O)} == 20,
#count{S, G, O: lezione(corso_2, S, G, O), settimana(S), giorno(G),ora(O)} == 15,
#count{S, G, O: lezione(corso_3, S, G, O), settimana(S), giorno(G),ora(O)} == 15,
#count{S, G, O: lezione(corso_4, S, G, O), settimana(S), giorno(G),ora(O)} == 20,
#count{S, G, O: lezione(corso_5, S, G, O), settimana(S), giorno(G),ora(O)} == 20,
#count{S, G, O: lezione(corso_6, S, G, O), settimana(S), giorno(G),ora(O)} == 10,
#count{S, G, O: lezione(corso_7, S, G, O), settimana(S), giorno(G),ora(O)} == 4,
#count{S, G, O: lezione(corso_8, S, G, O), settimana(S), giorno(G),ora(O)} == 10,
#count{S, G, O: lezione(recupero, S, G, O), settimana(S), giorno(G),ora(O)} == 4,

v3, v4, v1,
not v2min,
not v2max.



:- not goal.

#show lezione/4.