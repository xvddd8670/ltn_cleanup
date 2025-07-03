I wrote my own implementation of the LTN Cleanup mod.
It doesn't have as broad functionality as the original mod, but it works.
For stations with multiple types of cargo, a universal station is used that supports all cargo types.
If no suitable station is found, the train will be stopped to avoid breaking the entire logistics system by mixing items.
If there are both items and fluids, or more than one type of fluid, the train will also be stopped, since implementing such advanced logic is complicated and rarely used.
Stations work either with a single type of cargo, or with all cargo types except fluids.

====

How to use:
In the name of the desired cleanup station, include:
[LTN-cleanup icon][item or fluid icon]
or
[LTN-cleanup icon][ltncleanup all (with a star) icon]
