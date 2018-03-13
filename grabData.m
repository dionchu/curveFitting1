function[data] = grabdata(tdate)

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
      e = exec(conn,strcat('SELECT ALL askPrice,bidPrice,midPrice,onTheRunFlag,issueDate,firstCouponDate,maturityDate,couponInterest,currYld,prevYld,wiFlag FROM current3pmClose WHERE tradeDate = ','''', datestr(tdate, 'yyyymmdd'),'''','AND couponInterest<>0'));
%   e = exec(conn,strcat('SELECT ALL askPrice,bidPrice,midPrice,onTheRunFlag,issueDate,firstCouponDate,maturityDate,couponInterest,currYld,prevYld,wiFlag FROM current3pmCloseTable WHERE tradeDate = ','''', datestr(tdate, 'yyyymmdd'),'''','AND instrumentType<>TII AND instrumentType<>S'));

%e = exec(conn,strcat('SELECT ALL askPrice,bidPrice,midPrice,onTheRunFlag,issueDate,firstCouponDate,maturityDate,couponInterest,currYld,prevYld,wiFlag FROM current3pmCloseTable WHERE tradeDate = ','''', datestr(tdate, 'yyyymmdd'),'''','AND couponInterest<>0'));


e = fetch(e);
close(e)

 else

   % Read data from database.
       %e = exec(conn,strcat('SELECT ALL askPrice,bidPrice,midPrice,onTheRunFlag,issueDate,firstCouponDate,maturityDate,couponInterest,bidYield,askYield,wiFlag FROM ALL3pmClose WHERE tradeDate = ','''', datestr(tdate, 'yyyymmdd'),'''','AND couponInterest <>0'));
e = exec(conn,strcat('SELECT ALL askPrice,bidPrice,midPrice,onTheRunFlag,issueDate,firstCouponDate,maturityDate,couponInterest,currYld,prevYld,wiFlag FROM current3pmCloseTable WHERE tradeDate = ','''', datestr(tdate, 'yyyymmdd'),'''','AND instrumentType=','''','T',''''));
e = fetch(e);
close(e)

end


% Assign data to output variable.
data = e.Data;

% Close database connection.
close(conn)
  [rows,~] = size(data);
datemtrx = ones(rows,3)*0;


for i=1:rows
	datemtrx(i,1) = m2xdate(datenum(data{i,5}, 'yyyy-mm-dd'));
if(strcmp(data{i,6},'null')==0)
  datemtrx(i,2) = m2xdate(datenum(data{i,6}, 'yyyy-mm-dd'));
    end
    datemtrx(i,3) = m2xdate(datenum(data{i,7}, 'yyyy-mm-dd'));
end

dataI = data(:,1:4);
dataII = data(:,8:end);

data = [cell2mat(dataI), datemtrx, cell2mat(dataII)];
