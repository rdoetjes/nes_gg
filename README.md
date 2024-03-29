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

```bash
./nes-game-genie 0x812d 0xff
```

The resulting code will be: <b>NYZEIO</b> <br/>
When entered in the Game Genie, will instruct the Game Genie, to change the data byte that is on 0x812d of the inserted cardridge to be changed into 0xff, irrespective what is there.
<p>
<b>8 char code</b>

```bash
./nes-game-genie 0x812d 0xff 0xca
```

The resulting code will be: <b>NYXEIOXK</b> <br/>
When entered in the Game Genie, will instruct the Game Genie, to change the data byte that is on 0x812d of the inserted cardridge to be changed into 0xff <b>only</b> when the data on the cardridge located on address 812b, contains 0xca

## Change introduced afer video
A viewer noticed that the code did not compile on zig 0.11, truncate in 0.11 expects one argument and it doesn't want to cast to a lower value the way we do in the video. So I just changed the code to already use a u5 in the print routine. This works and arguably is also cleaner as we avoid a cast/truncate.

```zig
pub fn print_gg_nes(encoded: u32, is_eight: bool) !void {
    const CHR = [_]u8{ 'A', 'P', 'Z', 'L', 'G', 'I', 'T', 'Y', 'E', 'O', 'X', 'U', 'K', 'S', 'V', 'N' };
    var i: u5 = undefined;

    if (is_eight) i = 7 else i = 5;
    while (i > 0) : (i -= 1) {
        try stdout.print("{c}", .{CHR[(encoded >> i * 4 & 0xf)]});
    } else {
        try stdout.print("{c}", .{CHR[(encoded >> i * 4 & 0xf)]});
        try stdout.print("\n", .{});
    }
}
```

## Building nes-game-genie
There is a build.zig file which is akin to the Makefile in C, although zig comfortably creates the scaffolding for you after creating a project with zig init <project name> therefore building the project is as simple as running

```bash
zig build
```

Then in the directory zig-out/bin which will be created is the binary nes-game-genie
