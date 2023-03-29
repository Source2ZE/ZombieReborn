# ZombieReborn

An experimental implementation of Zombie Escape in Counter-Strike 2 using the Lua [VScript API](https://cs2.poggu.me/dumped-data/vscript-list).

[Join our Discord](https://discord.gg/QsSGf9ZEVs) for development discussion and to keep up to date!

## Installation

Copy both the `scripts` and `cfg` directories to your `game/csgo` folder. If you've already made changes to your server cfg's, you may want to just copy the contents of ours in instead.

## Current issues
You can find the current issues with CS2 we'd like to report to Valve [here](issues.md)

## The Future?

It is currently unknown how the plugin ecosystem is going to work on CS2, see the [AlliedModders wiki entry](https://wiki.alliedmods.net/Introduction_to_SourceMod_Plugins#Will_SourceMod_support_Source_2.3F_Will_plugins_for_existing_games_continue_to_work_if_they_are_ported.3F) on this for more information. We currently foresee a few possible outcomes of how this repository may be useful:

- Allowing for testing of the Zombie Escape gamemode during these next few months of the CS2 beta, allowing us to test maps & identify potential engine issues
- In the event a SourceMod equivalent is not yet ready on CS2 launch, this can be used to have ZE servers running day one
- In the event of a SourceMod equivalent choosing to expand on VScript, we will have a solid codebase already existing in Lua that we can switch to using custom functions where applicable