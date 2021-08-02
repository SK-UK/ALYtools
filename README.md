# ALYtools

Set of various Bioimaging analysis applications

Project massively uses Open Source code designed by other researchers. 
Many thanks to all of you, and apologies for not keeping references.
On the other hand, if you find any of ALYtools solutions/ideas worth taking, - please use without reference either.

# ic_OPTTools

MATLAB software for reconstructing OPT datasets, with a GUI. An installation of Icy (http://icy.bioimageanalysis.org/) is recommended for ease of viewing the reconstructed data.

#### To install ic_OPTTools, clone the repository on github at https://github.com/yalexand/ALYtools to a folder that does not require special access privileges on the machine you wish to use it on.
#### To start ic_OPTTools, set the working directory in MATLAB to the one which contains ic_OPTTools.m, then run the file.
##### You should see a progress bar while various tasks are run in the background, followed by the appearance of this window:  
##### ![image](https://user-images.githubusercontent.com/63599428/127892790-95fe6d2c-646a-4dda-b848-96efd8c87974.png)

#### Before loading ny data, it is useful to set some options in advance, under the Settings menu item
##### Set the on-load registration to "None" if your data is pre-registered, "Rotation axis shift only" if the data only has a lateral displacement of the rotation axis from the centre of the image, and "M1" if there is a rotation of the axis as well (Warning! This may be slow!)
#####![image](https://user-images.githubusercontent.com/63599428/127894448-999f77c1-2159-4984-9bba-89a38bc16178.png)
##### Set the On-load Median pre-filtering to "None" if you do not wish to apply median filtering, or "Set size", then enter a value into the window that pops up if you do
##### ![image](https://user-images.githubusercontent.com/63599428/127894781-06009295-04a4-4ba6-92e4-e7e9283e3e3b.png)

#### To load data, click on the File menu item, and select either "Load single - OME.tiff" if your source data is an OME-TIFF or "Load single - image stack" if it is a series of TIFF files with sequential numbering at the end e.g. XXX_000.tif, XXX_001.tif ...
#### ![image](https://user-images.githubusercontent.com/63599428/127893894-4c06d63f-36a9-412b-a07f-7211a8e5a3d9.png)

