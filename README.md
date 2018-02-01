# SupportXMRMonitor
## About
This is a small utility I threw together to display the current XMR I've earned on SupportXMR.com

I got annoyed by having to go load up the page to take a quick peek at the current values.

## Language
It's built in Object Pascal using Lazarus and FreePascal.

## How to use it
Start it, if it's the first time it'll prompt you to enter the name of your miner group.

It saves the info to an INI file so on the next start you don't need to enter anything.

You can change miner group by right-clicking in the window and selecting "Set Miner Group".

Adjust the update interval by right-clicking and selecting "Set Update Interval", defaults to 60000 milliseconds (1 minute interval)

## Notes

It should be cross platform but I have only tested in on my Mac, I plan to make binaries for the three major platforms at some point (Mac, Windows, Linux)
