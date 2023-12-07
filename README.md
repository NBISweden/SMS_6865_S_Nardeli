# SMS_6865_S_Nardeli

- Last modified: 2023-Dec-23
- Sign: JN

## Description

NBIS project <https://projects.nbis.se/issues/6865>

Details on the task are given in the project link (above), but briefly:

Given pair-end libraries containing sequences with a two-part design ("bait+araport"), count the number of reads that matches reference sequences in a data base ("Baits", each bait sequence is 100 bp). The match in the "bait-part" have to fulfill certain requirements (on exact match or not) over certain regions of the reference sequence. In addition, for each read where one part matches a sequence in the Baits db, we also want to know if the second part of the read matches a sequence in a second data base ("Araport", protein coding sequences of varying length) - and if that "araport-part" is in or out of frame.

See first [Notebook.md](Notebook.md) and then [6865.ipynb](6865.ipynb) for analyses.

Note that input data are confidential, and is provided by the PI.
