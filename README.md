# ZombieReborn

An experimental implementation of Zombie Escape in Counter-Strike 2 using the Lua [VScript API](https://cs2.poggu.me/dumped-data/vscript-list).

[Join our Discord](https://discord.gg/QsSGf9ZEVs) for development discussion and to keep up to date!

## Installation

You will first need to [install Metamod](https://www.sourcemm.net/downloads.php?branch=dev). Then, install [CS2Fixes](https://github.com/Source2ZE/CS2Fixes) for several required features and ZR integrations.

Finally, copy both the `scripts` and `cfg` directories of ZombieReborn to your `game/csgo` folder. If you've already made changes to your server cfg's, you may want to just copy the contents of ours in instead.

## Project Status?

ZombieReborn currently sits in an awkward spot, Lua VScript was disabled in the Mirage update, pending likely removal/replacement by a new official scripting system called Pulse. Therefore, development has been generally paused. Contributions are still welcome in the mean time, but they should ideally be focused on fixes and improvements, rather than significant new features.

We're currently planning a ZR rewrite in [Metamod within CS2Fixes](https://github.com/Source2ZE/CS2Fixes) or as a separate [CounterStrikeSharp](https://github.com/roflmuffin/CounterStrikeSharp) plugin.

## Documentation

You can find the documentation of various Zombie:Reborn features [here](../../wiki/Documentation).

## Current issues

You can find the current issues with CS2 we'd like to report to Valve [here](../../wiki/CS2-Issues).