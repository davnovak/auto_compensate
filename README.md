# auto_compensate
Pipeline to compensate new CyTOF measurements routinely &amp; quickly. Used @ CLIP, 2nd Medical Faculty, Charles University.

The point of this is to allow easy access to a semi-automated tool for compensation of new CyTOF samples (using the *CATALYST* package) to people who don't want to bother with R scripting. This is an ad hoc approach which aligns with our needs.

Provided a good compensation matrix, it is desirable to run a script once in a while which assures that all newly created .fcs files are compensated (*i.e.* new compensated files are generated from them). The prerequisites are the compensation matrix, a computer with access to the sample directory and RStudio with some packages used for the actual compensation and a suffix designated to distinguish the compensated files.

To set up the desired compensation matrix & ``method`` parameter for the ``compCytof`` function, change values of parameters passed ``compensate_uncomp_files`` in the file ``run.R`` (or directly in ``functions.R`` to change the defaults). To set path to the parent directory containing .fcs files (this directory is searched recursively), change assignment to variable ``FOLDER`` in ``run.R``.

Since this tool is written for use by people who don't want to bother with R: to run the script, source the ``run.R`` file. From that point on, follow the instructions printed to the console and provide responses when prompted.

This code was created ad hoc and is not the cleanest, has not been optimised, etc. Feel free to adapt it for your own use. In case of problems, open an issue here on GitHub or e-mail me at *davidnovakcz@hotmail.com*.
