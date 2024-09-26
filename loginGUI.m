function loginGUI
    % Create a figure for the login GUI
    fig = uifigure('Name', 'Elderly Fall Detection System - Login', 'Position', [500, 500, 400, 300]);

    % Username label and field
    uilabel(fig, 'Position', [100, 220, 200, 30], 'Text', 'Username:');
    usernameField = uieditfield(fig, 'text', 'Position', [100, 190, 200, 30]);

    % Password label and field
    uilabel(fig, 'Position', [100, 160, 200, 30], 'Text', 'Password:');
    passwordField = uieditfield(fig, 'text', 'Position', [100, 130, 200, 30]);

    % Login button
    loginButton = uibutton(fig, 'Position', [150, 80, 100, 30], 'Text', 'Login', ...
        'ButtonPushedFcn', @(btn, event) loginCallback(usernameField.Value, passwordField.Value));

    function loginCallback(username, password)
        % Validate credentials against the database
        conn = getDatabaseConnection();
        if isempty(conn)
            uialert(fig, 'Failed to connect to the database.', 'Connection Error');
            return;
        end
        
        query = sprintf("SELECT id, role FROM Users WHERE username='%s' AND password='%s'", ...
            username, password);
        data = fetch(conn, query);

        if isempty(data)
            uialert(fig, 'Invalid credentials', 'Login Failed');
        else
            userId = data.id;
            userRole = data.role;

            % Close login GUI
            close(fig);

            % Open appropriate interface based on role
            if strcmp(userRole, 'patient')
                patientGUI(userId);
            elseif strcmp(userRole, 'doctor')
                doctorGUI(userId);
            end
        end
    end
end
