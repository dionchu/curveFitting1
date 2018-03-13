function[cusip] = grabcusip(tdate)

  % Set preferences with setdbprefs.
  s.DataReturnFormat = 'cellarray';
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
%conn = database('IONRATES1P_SQL','etrading','kuz5xa3A');
conn = database('fitdbdev','etrading','kuz5xa3A','com.sybase.jdbc3.jdbc.SybDriver','jdbc:sybase:Tds:jcionapp1d.jc.jefco.com:9110/fitdbdev');

if(tdate == today)

  % Read data from database.
      e = exec(conn,strcat('SELECT ALL cusip FROM current3pmClose WHERE tradeDate = ','''', datestr(tdate, 'yyyymmdd'),'''','AND couponInterest<>0'));
e = fetch(e);
close(e)

 else

   % Read data from database.
       e = exec(conn,strcat('SELECT ALL cusip FROM current3pmCloseTable WHERE tradeDate = ','''', datestr(tdate, 'yyyymmdd'),'''','AND instrumentType=','''','T',''''));
e = fetch(e);
close(e)

 end


% Assign data to output variable.
cusip = e.Data;
