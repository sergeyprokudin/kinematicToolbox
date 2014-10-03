% BEAT Toolbox
%   Version 1.0 06.10.2001
%
% File Access Functions
%   DUMPDATA     - Save data and labels to disk or database (DB interface tk).
%   LOADACQ      - Load an Acqknowledge format file of analog data.
%   LOADLABVIEW  - Load a binary Labview file of analog data.
%   LOADMRF      - Load MacReflex data file from disk.
%   LOADMYOHDR   - Utility to load header of Noraxon MyoSoft data file; used by LOADNOR.
%   LOADNOR      - Load a Noraxon Winmyo file of analog data ASCII format or MyoSoft format.
%   LOADVSA      - A function that loads a .VSA type data file obtained from the VScope system.
%   SAVESTATS    - Save data from user to a tab-delimited file, appending if file exists.
%
% Motion and EMG Analysis Functions
%   GETDROPS     - Get dropouts in data.
%   FILLGAPS     - Fill in gaps and make sure points are consecutive.
%   FIXDROPS     - Fix dropouts in data obtained using GETDROPS.
%   H_STRIKE     - Pick heel strike events from data.
%   MAKE_CYCLES  - Divide cyclic data into its component cycles, and create average cycle.
%   MEANFREQ     - Compute mean frequency of a signal.
%   MEDFREQ      - Compute median frequency of a signal.
%   RMS_EMG      - Rectify and RMS an EMG signal.
%   SET_BASELINE - Set the baseline level of a signal
%   TOE_OFF      - Pick toe off events from data.
%
% Statistics
%   COMC         - Compute coefficient of multiple correlation of a data series.
%
% User Interface
%   DONEBUT      - Function to indicate the pressing of a 'Done' button.
%                  Deprecated in recent versions of MATLAB which allow for easy
%                  dialog creation.
%   EXCL_RAD     - Callback function to make radio buttons mutually exclusive
%   RB_STARTEND  - Pick start and end points of event using a rubber-band box.
%                  Superceded by RBBOX.
%
% Plotting Tools
%   MAKEAXIS     - Take sampling interval and generate true x-axis for plots.
%
% Miscellaneous Matrix and Vector Calculations
%   COMPANG      - Compute the (2-D or 3-D) angle created by three markers.
%                  (works like: 180 - subspace(line1, line2))
%   DOTPROD      - Vector dot product.	
%                  (superceded by dot)
%   FILLGAPS     - Fill in gaps and make sure points are consecutive.
%   VECTMAG      - A function that will compute the magnitude of a vector x.
%                  (replace with norm)

