function[coefs] = grabcoefs(tdate, type, id)

  %%% Specifications

  % 0 - off-run; 1 - on-run; 2 - TIPS; 3 - swaps;

% Set preferences with setdbprefs.
s.DataReturnFormat = 'numeric';
s.ErrorHandling = 'store';
s.NullNumberRead = 'NaN';
s.NullNumberWrite = 'NaN';
s.NullStringRead = 'null';
s.NullStringWrite = 'null';
s.JDBCDataSourceFile = '';
s.UseRegistryForSources = 'yes';
s.TempDirForRegistryOutput = 'C:\DOCUME~1\dchu\LOCALS~1\Temp';
s.DefaultRowPreFetch = '10000';
setdbprefs(s)

% Make connection to database.  Note that the password has been omitted.
% Using ODBC driver.
%conn = database('IONRATES1D_SQL','etrading','kuz5xa3A');
conn = database('FIProdDB','etrading','kuz5xa3A', 'net.sourceforge.jtds.jdbc.Driver', 'jdbc:jtds:sqlserver://iondb01:1433/FIProdDB');

% Read data from database.
e = exec(conn,strcat('SELECT DISTINCT beta0,beta1,beta2,beta3,tau1,tau2 FROM Coefficients WHERE tradeDate = ', '''', datestr(tdate, 'yyyymmdd'), '''', ' AND derivativeIndicator = ',num2str(type),' AND currency = ', '''',id, ''''));
e = fetch(e);
close(e)

% Assign data to output variable.
coefs = e.Data;

% Close database connection.
close(conn)
