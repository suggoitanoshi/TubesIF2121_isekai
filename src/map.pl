/* spesifikasi map:
 * ada 2 jenis map, dirandom di awal game
 * (R,C) itu sel di baris ke-R kolom ke-C
 * pojok kiri atas itu (1,1), pojok kanan bawah itu (nRow,nCol)
 * koordinat (1,C), (nRow,C), (R,1), (R,nCol) selalu pagar untuk 1<=R<=nRow, 1<=C<=nCol
 */

/* dynamic predicate map */
:- dynamic(nRow/1).
:- dynamic(nCol/1).
:- dynamic(fence/2).
:- dynamic(store_coordinate/2).
:- dynamic(dungeon_boss_coordinate/2).
:- dynamic(quest_coordinate/2).

/* dynamic predicate koordinat player */
:- dynamic(player_coordinate/2).

/* dynamic predicate jenis yang ditempati sel player */
/* kemungkinan player_cell:
 * kosong (-)
 * store_cell (S)
 * quest_cell (Q)
 * dungeon_boss_cell (D)
 */
:- dynamic(player_cell/1).

/* dynamuc predicate sel boss locked/unlocked */
:- dynamic(dungeon_boss_cell_state/1).

/* jenis-jenis map */
map1 :-
	/* ini map spek */
	/* hapus map yang sudah ada */
	retractall(fence(_,_)),
	retractall(store_coordinate(_,_)),
	retractall(dungeon_boss_coordinate(_,_)),
	retractall(quest_coordinate(_,_)),
	retractall(player_coordinate(_,_)),
	retractall(nRow(_)),
	retractall(nCol(_)),
	/* size map ini */
	asserta(nRow(19)),
	asserta(nCol(16)),
	/* koordinat-koordinat pagar (#) di map ini */
	asserta((fence(R,_) :- R = 1)),
	asserta((fence(R,_) :- nRow(R))),
	asserta((fence(_,C) :- C = 1)),
	asserta((fence(_,C) :- nCol(C))),
	asserta(fence(6,9)),
	asserta(fence(7,9)),
	asserta(fence(8,9)),
	asserta(fence(8,10)),
	asserta(fence(8,11)),
	asserta(fence(8,12)),
	asserta(fence(15,8)),
	asserta(fence(16,5)),
	asserta(fence(16,6)),
	asserta(fence(16,7)),
	asserta(fence(16,8)),
	asserta(fence(17,8)),
	/* koordinat store (S) di map ini */
	asserta(store_coordinate(3,3)),
	/* koordinat dungeon boss (D) di map ini */
	asserta(dungeon_boss_coordinate(18,15)),
	/* lock dungeon boss di awal game */
	asserta(dungeon_boss_cell_state(locked)),
	/* koordinat quest (Q) di map ini */
	asserta(quest_coordinate(4,8)),
	/* koordinat awal player (P) di map ini */
	asserta(player_coordinate(2,2)),
	asserta(player_cell(kosong)).

map2 :-
	/* hapus map yang sudah ada */
	retractall(fence(_,_)),
	retractall(store_coordinate(_,_)),
	retractall(dungeon_boss_coordinate(_,_)),
	retractall(quest_coordinate(_,_)),
	retractall(player_coordinate(_,_)),
	retractall(nRow(_)),
	retractall(nCol(_)),
	/* size map ini */
	asserta(nRow(10)),
	asserta(nCol(20)),
	/* koordinat-koordinat pagar (#) di map ini */
	asserta((fence(R,_) :- R = 1)),
	asserta((fence(R,_) :- nRow(R))),
	asserta((fence(_,C) :- C = 1)),
	asserta((fence(_,C) :- nCol(C))),
	asserta(fence(5,5)),
	asserta(fence(6,6)),
	asserta(fence(7,7)),
	/* koordinat store (S) di map ini */
	asserta(store_coordinate(3,3)),
	/* koordinat dungeon boss (D) di map ini */
	asserta(dungeon_boss_coordinate(3,2)),
	/* lock dungeon boss di awal game */
	asserta(dungeon_boss_cell_state(locked)),
	/* koordinat quest (Q) di map ini */
	asserta(quest_coordinate(9,19)),
	/* koordinat awal player (P) di map ini */
	asserta(player_coordinate(2,2)),
	asserta(player_cell(kosong)).

/* randomize map, dipanggil di awal game */
/* note: harus dirombak kalau mau nambah map lagi */
randomize_map :-
	%random(1,3,X),
	acak(1,3,X),
	X is 1, !,
	map1.
randomize_map :-
	map2.

/* map-printing functions */
printCell(R,C) :-
	fence(R,C),
	!,
	write('#').
printCell(R,C) :-
	player_coordinate(R,C),
	!,
	write('P').
printCell(R,C) :-
	store_coordinate(R,C),
	!,
	write('S').
printCell(R,C) :-
	dungeon_boss_coordinate(R,C),
	!,
	write('B').
printCell(R,C) :-
	quest_coordinate(R,C),
	!,
	write('Q').
printCell(_,_) :-
	write('-').

map :-
  state(S),
  S = not_started, !,
  write('Permainan belum dimulai.\n').
  
map :-
  state(S),
  S = tutorial, !,
  write('Map belum tersedia di tutorial.\n').
map :-
	nRow(R),
	nCol(C),
	forall(between(1,R,I),(
		forall(between(1,C,J),(
			printCell(I,J)
		)),
		nl
	)).

/* unlock dungeon boss cell */
unlock_dungeon_boss_cell :-
	retractall(dungeon_boss_cell_state(_)),
	asserta(dungeon_boss_cell_state(unlocked)),
	write('Karena jasa Anda mengalahkan para tubes, kamu telah diundang ke Istana Raja Naga Keri!\n'),
	write('Pintu ke istana terbuka untuk Anda.\n').

/* interact with dungeon boss cell */
interact_with_dungeon_boss_cell :-
	dungeon_boss_cell_state(locked),
	!,
	write('Istana tertutup untuk orang luar. Anda tidak bisa masuk istana.\n').
interact_with_dungeon_boss_cell :-
	name(X),
	boss(X).

/* cell-checking util., buat ganti-ganti player_cell */
cekCell(R,C) :-
	store_coordinate(R,C),
	!,
	retractall(player_cell(_)),
	asserta(player_cell(store_cell)).
cekCell(R,C) :-
	quest_coordinate(R,C),
	!,
	retractall(player_cell(_)),
	asserta(player_cell(quest_cell)).
cekCell(R,C) :-
	dungeon_boss_coordinate(R,C),
	!,
	retractall(player_cell(_)),
	asserta(player_cell(dungeon_boss_cell)),
	interact_with_dungeon_boss_cell.
cekCell(_,_) :-
	retractall(player_cell(_)),
	asserta(player_cell(kosong)),
	monster_encounter.

/* player movements */
w :-
	state(free),
	player_coordinate(R,C),
	NewR is R - 1,
	fence(NewR,C),
	!,
	write('Kamu berusaha berjalan ke utara, tapi kamu menabrak pagar.'), nl.
w :-
	state(free),
	player_coordinate(R,C),
	NewR is R - 1,
	retractall(player_coordinate(_,_)),
	asserta(player_coordinate(NewR,C)), !,
	write('Kamu telah bergerak ke utara.'), nl,
	cekCell(NewR,C).

w :-
	state(X),
	X \= free,
	format('Kamu tidak dapat berjalan selagi kamu dalam ~w.', [X]).

a :-
	state(free),
	player_coordinate(R,C),
	NewC is C - 1,
	fence(R,NewC),
	!,
	write('Kamu berusaha berjalan ke barat, tapi kamu menabrak pagar.'), nl.
a :-
	state(free),
	player_coordinate(R,C),
	NewC is C - 1,
	retractall(player_coordinate(_,_)),
	asserta(player_coordinate(R,NewC)), !,
	write('Kamu telah bergerak ke barat.'), nl,
	cekCell(R,NewC).
a :-
	state(X),
	X \= free,
	format('Kamu tidak dapat berjalan selagi kamu dalam ~w.', [X]).

s :-
	state(free),
	player_coordinate(R,C),
	NewR is R + 1,
	fence(NewR,C),
	!,
	write('Kamu berusaha berjalan ke selatan, tapi kamu menabrak pagar.'), nl.
s :-
	state(free),
	player_coordinate(R,C),
	NewR is R + 1,
	retractall(player_coordinate(_,_)),
	asserta(player_coordinate(NewR,C)), !,
	write('Kamu telah bergerak ke selatan.'), nl,
	cekCell(NewR,C).
s :-
	state(X),
	X \= free,
	format('Kamu tidak dapat berjalan selagi kamu dalam ~w.', [X]).

d :-
	state(free),
	player_coordinate(R,C),
	NewC is C + 1,
	fence(R,NewC),
	!,
	write('Kamu berusaha berjalan ke timur, tapi kamu menabrak pagar.'), nl.
d :-
	state(free),
	player_coordinate(R,C),
	NewC is C + 1,
	retractall(player_coordinate(_,_)),
	asserta(player_coordinate(R,NewC)), !,
	write('Kamu telah bergerak ke timur.'), nl,
	cekCell(R,NewC).
d :-
	state(X),
	X \= free,
	format('Kamu tidak dapat berjalan selagi kamu dalam ~w.', [X]).
