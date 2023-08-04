clear variables
close all

% load matrix of example ca2+ traces, where each coloumn is a time series
% along with acquisition frame time and time of swim onset (in seconds)
load('roisExample.mat')

% visualize plots of processed traces
showfigures = true;

%% Start the main loop

% extract number of frames from example traces, which is equal to number of
% rows, and number of time series, which is the number of coloumns

num_of_frames = size(sdata_rois,1);

num_of_rois = size(sdata_rois,2);

% this for loop takes each time series at a time and processes it
for roi = 1 : num_of_rois
    
    % a single coloumn vector for an individual time series
    DFF_roi = sdata_rois(:,roi);
    
    % moving median time window of length 5 to reduce high frequency noise
    DFF_roi_medfilt = movmedian(DFF_roi,5);
    
    DFF_roi_sort = sort(DFF_roi_medfilt);
    
    % baseline is taken as the mean of the lowest 60 percent values
    DFF_baseline = mean(DFF_roi_sort(1:round(0.6 * end)));
    
    % std is taken as the std of the lowest 33 percent values
    % a constant times std describes different thresholds for signal
    % detection
    DFF_std = std( DFF_roi_sort(1:round(0.33 * end)) );
    
    % threshold where signal rises aproximately above the baseline noise
    % defined as a constant times std above the baseline
    DFF_threshold_start = DFF_baseline + 1.5 * DFF_std;
    
    % minimum threshold that signal must cross to be detected as activity
    % defined as a constant times std above the baseline
    DFF_threshold_peak = DFF_baseline  + 6.0 * DFF_std;
    
    % point of signal crossing used to determine the time onset of an
    % activity relative to swim time onset
    DFF_threshold_rise = DFF_baseline  + 3.0 * DFF_std;
    
    % swim time onset in frame number 
    swim_loc = floor(swim_time/frame_time);
    
    % peaks are detected as defining activity
    [~,locs] = findpeaks(DFF_roi_medfilt , 'MinPeakWidth',4);
    
    % in case of multiple peak activities, only the peak activity nearest 
    % to the swim onset is kept
    ind = abs(locs - swim_loc) == min(abs(locs - swim_loc));
    at_DFF_max = locs(ind);
    % selects one of the equidistant peak activities
    at_DFF_max = min(at_DFF_max);
    % create an exception for non-active signal
    if isempty(at_DFF_max)
        at_DFF_max = 1;
    end
    % signal amplitude at peak activity
    desired = DFF_roi_medfilt(at_DFF_max);
    
    % 1st find time point where DFF drops just below upper limit of 
    % baseline noise before the peak
    n = 1;
    while DFF_roi_medfilt(at_DFF_max - n) > DFF_threshold_start
        n = n + 1;
    end
    
    % 2nd find time point where DFF rises above threshhold between baseline
    % crossing and DFF_peak
    m = 0;
    while DFF_roi_medfilt(at_DFF_max - n + m) < DFF_threshold_rise
        m = m+1;
    end
    % number of frames during rising phase of DFF signal
    n = n - m;
    
    % initialize variables defining:
    deltaT = []; % time difference of activity relative to swim onset
    x_int = 0;   % interpolated time point of activity onset
    y_int = 0;   % interpolated DFF value of activity onset 
    
    % a signal is further processed if its rising phase is less than 1.5
    % seconds long and if the peak activity rises above a certain threshold
    if ((n * frame_time) < 1.5) && (desired > DFF_threshold_peak)
        
        % Find x_intersection of DFF_roi_medfilt with DFF_threshold_rise
        % polyxpoly ( [x00 x01],[y00 y01] , [x10 x11],[y10 y11] )
        [x_int,y_int] = polyxpoly( ... 
            [(at_DFF_max-n-1) (at_DFF_max-n)] , ...
            [DFF_roi_medfilt(at_DFF_max-n-1) DFF_roi_medfilt(at_DFF_max-n)] , ...
            [(at_DFF_max-n-1) (at_DFF_max-n)] , ...
            [DFF_threshold_rise DFF_threshold_rise] ...
            );
        
        % x_int is more accurate as it interpolates the sample points,
        % where the threshold crossing occurs
        deltaT = x_int*frame_time - swim_time; % in seconds
        
        
        % % % uncomment the following line, to quantify for peak locations
        % deltaT = ( (at_DFF_max) - ((num_of_frames+1)/2))*frame_time;
        
    end
    
    if showfigures % here the plotting starts
        
        facecolor = [0 0 0];
        
        if ~isempty(deltaT)

            if (deltaT > 0.05) && (deltaT <= 0.35)
                % GOLD color for POST Ca2+ Transients
                facecolor = [0.8314 0.6667 0];
                
            elseif (deltaT > -1.2) && (deltaT <= -0.05)
                % RED color for PRE Ca2+ Transients
                facecolor = [0.7490 0.1059 0.1725];    
            end
            
        end
            
        figure(roi)
        hold on
        
        % DFF signal
        plot((1:num_of_frames).*frame_time , DFF_roi , ...
            'Color',[0.8 0.8 0.8] , 'LineWidth',1)
        
        % median filtered DFF signal
        plot((1:num_of_frames).*frame_time , DFF_roi_medfilt , ...
            'Color',facecolor , 'LineWidth',1.5)
        
        % BaseLine
        plot([1 num_of_frames]*frame_time, [DFF_baseline DFF_baseline], ...
            'Color',[0 0 0])
        
        % Threshold for Accepting a Ca2+ Transient Peak
        plot([1 num_of_frames]*frame_time, ...
                        [DFF_threshold_peak DFF_threshold_peak], ...
            'Color',[0 0 1])
        
        % Threshold for Measuring Ca2+ Transient Start
        plot([1 num_of_frames]*frame_time , ...
                        [DFF_threshold_rise DFF_threshold_rise] , ':' , ...
            'Color',[0 0 1])
        
        % Vertical Line for Swim Onset
        plot([swim_time swim_time] , [min(DFF_roi) max(DFF_roi)] , ...
            'Color',[0 0 0])
        
        % Circle for Ca2+ Transient Start
        plot(x_int*frame_time , y_int, 'o' ,'MarkerSize',5 , ...
            'Color',[1 0 0] , 'LineWidth',0.5)
        
        % Circle for Ca2+ Transient Peak
        plot((at_DFF_max)*frame_time , DFF_roi_medfilt(at_DFF_max) ,...
            'o' ,'MarkerSize',5 , ...
            'Color',[0 0 1] , 'LineWidth',0.5)
        
        
        title(['ROI # ',num2str(roi), ' , dt = ',num2str(deltaT)])
        
        axis tight
        
        hold off
        
    end % here the plotting ends
    
end
