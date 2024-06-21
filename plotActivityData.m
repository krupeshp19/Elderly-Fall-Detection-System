function plotActivityData(t, accelData, gyroData, activityLog)
    % Define colors for each activity and falls
    activityColors = containers.Map({'STANDING', 'WALKING UPSTAIRS', 'WALKING', 'WALKING DOWNSTAIRS', 'JOGGING', 'SITTING', 'LAYING', 'forward Fall', 'backward Fall'}, ...
                                    {'b', 'g', 'r', 'c', 'm', 'y', 'k', 'magenta', 'cyan'});

    % Create a figure for accelerometer data
    figure('Name', 'Accelerometer Data');
    axesLabels = {'X-axis', 'Y-axis', 'Z-axis'};
    
    for axis = 1:3
        subplot(3, 1, axis);
        hold on;
        title(['Accelerometer Data - ', axesLabels{axis}]);
        xlabel('Time (s)');
        ylabel('Acceleration (g)');
        
        for i = 1:length(activityLog)
            activity = activityLog(i);
            color = activityColors(activity.Label);
            plot(t(activity.Start:activity.End) / 50, accelData(axis, activity.Start:activity.End), 'Color', color, 'DisplayName', activity.Label);
        end
        
        if axis == 1
            legend('show');
        end
        
        hold off;
    end

    % Create a figure for gyroscope data
    figure('Name', 'Gyroscope Data');
    
    for axis = 1:3
        subplot(3, 1, axis);
        hold on;
        title(['Gyroscope Data - ', axesLabels{axis}]);
        xlabel('Time (s)');
        ylabel('Angular Velocity (deg/s)');
        
        for i = 1:length(activityLog)
            activity = activityLog(i);
            color = activityColors(activity.Label);
            plot(t(activity.Start:activity.End) / 50, gyroData(axis, activity.Start:activity.End), 'Color', color, 'DisplayName', activity.Label);
        end
        
        if axis == 1
            legend('show');
        end
        
        hold off;
    end
end
