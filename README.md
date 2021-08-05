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
##### ![image](https://user-images.githubusercontent.com/63599428/127894448-999f77c1-2159-4984-9bba-89a38bc16178.png)
##### Set the On-load Median pre-filtering to "None" if you do not wish to apply median filtering, or "Set size", then enter a value into the window that pops up if you do
##### ![image](https://user-images.githubusercontent.com/63599428/127894781-06009295-04a4-4ba6-92e4-e7e9283e3e3b.png)

#### To load data, click on the File menu item, and select either "Load single - OME.tiff" if your source data is an OME-TIFF or "Load single - image stack" if it is a series of TIFF files with sequential numbering at the end e.g. XXX_000.tif, XXX_001.tif ...
##### ![image](https://user-images.githubusercontent.com/63599428/127893894-4c06d63f-36a9-412b-a07f-7211a8e5a3d9.png)
##### In the popup window that appears, navigate using the browser on the left hand side to the folder that contains folders with OPT datasets
##### Select the dataset you wish to load, then press "Add ->", and the name of the dataset folder should appear on the right hand side of the popup window
##### ![image](https://user-images.githubusercontent.com/63599428/127895375-96458534-58a6-47d7-9922-5b946f43a3a4.png)
##### Once this loading progress bar has reached 100%...
##### ![image](https://user-images.githubusercontent.com/63599428/128340875-a8974870-5881-4f95-aafd-b2eaedd0bd36.png)
##### Then the "proj" indicator on the OPTtools window will turn blue to indicate that all projections havve been loaded
##### ![image](https://user-images.githubusercontent.com/63599428/128340984-c3796381-0589-4dad-8654-5d3bd1eeb376.png)

#### You should now select appropriate settings for the reconstruction
##### From the Settings menu item, you can set a range of properties
##### ![image](https://user-images.githubusercontent.com/63599428/128341219-f8436f56-2370-4ace-8d3d-e4ee21a4feaa.png)
##### "Pixel downsampling" will bin pixels in 3D by powers of 2 - this will allow for a faster, low-resolution reconstruction to be done
##### "Z-range" will pop up a window that will show the acquisition data of the sample spinning around. You can then select a region of interest (ROI) on the image that encompasses the region that contains the parts of the recorded data that are relevant.
##### ![image](https://user-images.githubusercontent.com/63599428/128341620-66f7e5fb-4d69-46b6-aae5-4a5907669cff.png)
##### "Reconstruction method" allows you to choose between Filtered BackProjection (FBP) and FBP-TwIST (Two-step Iterative Stretching and Thresholding - https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0136213). TwIST will produce a better image for undersampled data, but will take significantly longer to run, as it is iterative
##### "GPU" allows you to use the system GPU - this can provide a speedup of around 20x, assuming there is sufficient memory available
##### ![image](https://user-images.githubusercontent.com/63599428/128342698-0d81f109-b8f9-4a5b-a7d0-ec13cc329d08.png)
##### "Largo" allows for 'chunking' of data on systems with limited RAM - parts of the data will be processed at a time, and the whole dataset put back together later. Largo is not compatible with GPU usage at this time, so if "Largo" is "ON", "GPU" must be "OFF"
##### ![image](https://user-images.githubusercontent.com/63599428/128343032-b9de9ae0-3f2b-42a5-80b0-e616def860f7.png)
##### "FBP-interp" will select the interpolation type used in the reconstruction
##### ![image](https://user-images.githubusercontent.com/63599428/128342399-b0df049f-962d-4dba-90fa-c7974bb4240f.png)
##### "FBP filter" will select the type of filter used in the reconstruction
##### ![image](https://user-images.githubusercontent.com/63599428/128342567-ff6de8e8-184a-4918-87fc-91f99d2cbb5c.png)

