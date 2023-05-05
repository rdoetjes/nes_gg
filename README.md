# NES Game Genie code generator

The Game Genie was created im 1990 at the end of the NES' life cycle. It served to reduce the compexity of the games of the day, as it allowed the player to "cheat". The Game Genie was delivered with a book with codes for different and you could subscribe or buy extra issues of the books.

## Game Genie Codes
A Game Genie code either exists out of 6 or 8 characters, which actually encode a code update for the ROM cardridge inserted.
<p>
The structure for the 6 character code consists of the address of which you want to change the data and the data that is just a single bute, it would need to become.
<p>
The structure of the 8 character code adds a compare byte. The compare byte that is encoded is checked to exist on the address that is past, and only then it will change that byte to the new data byte. This added some protection because certain cardridges from Japan, Europe and USA had slightly different code bases and randomly changing the data on an address could cause the game to lock up.

## nes-game-genie
This little command line tool, was created in zig as a second lesson on programming in zig for performing bit wise operations and conversion from hex to int.
<p>
The application takes 2 or 3 arguments, creating respectively a 6 character or 8 character Game Genie cheat code.
<p>
<b>6 char code</b>
```
./nes-game-genie 0x812d 0xff
```
The resulting code when entered in the Game Genie, will instruct the Game Genie, to change the data byte that is on 0x812d of the inserted cardridge to be changed into 0xff, irrespective what is there.
<p>
<b>8 char code</b>
```
./nes-game-genie 0x812d 0xff 0xca
```
The resulting code when entered in the Game Genie, will instruct the Game Genie, to change the data byte that is on 0x812d of the inserted cardridge to be changed into 0xff <b>only</b> when the data on the cardridge located on address 812b, contains 0xca
