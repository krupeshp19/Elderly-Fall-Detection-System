function conn = getDatabaseConnection()
    % This function initializes a persistent database connection.
    persistent dbConnection

    if isempty(dbConnection) || ~isopen(dbConnection)
        try
            % Establish the connection if it does not exist or is closed
            dbConnection = database('MySQL', 'root', 'Admin@123');
            if isopen(dbConnection)
                disp('Database connection established successfully.');
            else
                error('Failed to connect to the database.');
            end
        catch ME
            disp(['Error connecting to database: ', ME.message]);
            dbConnection = [];
        end
    end

    % Return the database connection
    conn = dbConnection;
end
