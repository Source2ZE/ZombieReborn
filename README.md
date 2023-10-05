# ZombieReborn

An experimental implementation of Zombie Escape in Counter-Strike 2 using the Lua [VScript API](https://cs2.poggu.me/dumped-data/vscript-list).

[Join our Discord](https://discord.gg/QsSGf9ZEVs) for development discussion and to keep up to date!

## Installation

ZombieReborn has several requirements, you will first need to [install Metamod](https://www.sourcemm.net/downloads.php?branch=dev). Then install the [Movement Unlocker](https://github.com/Source2ZE/MovementUnlocker) and [Lua Unlocker](https://github.com/Source2ZE/LuaUnlocker) Metamod plugins for zombie knockback & Lua VScript capability respectively.

Finally, copy both the `scripts` and `cfg` directories of ZombieReborn to your `game/csgo` folder. If you've already made changes to your server cfg's, you may want to just copy the contents of ours in instead.

## Project Status?

ZombieReborn currently sits in an awkward spot, Lua VScript was disabled in the Mirage update, pending likely removal/replacement by a new official scripting system called Pulse. However with Pulse/Source2Mod not yet out, and not enough SDK work done to reimplement ZR in a Metamod plugin yet, Lua scripting still remains the only viable solution.

Due to Lua scripts not having a future, development has been generally paused. Contributions are still welcome in the mean time, but they should ideally be focused on fixes and improvements, rather than significant new features.

## Documentation

You can find the documentation of various Zombie:Reborn features [here](../../wiki/Documentation).

## Current issues

You can find the current issues with CS2 we'd like to report to Valve [here](../../wiki/CS2-Issues).