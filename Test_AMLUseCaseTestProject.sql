SELECT CustName, Segment, MONTH (TxDate) Month, TxType
  , avg(TxValue) as AvgTxValue
  , Count(TxValue) as TotTxVol
  , Sum(TxValue) as SumTxValue
  , Min(TxValue) as MinTxValue
  , Max(TxValue) as MaxTxValue
  , STDDev(TxValue) as StdDevTxValue
FROM [amlusecasetestproject:AMLUseCaseTestProjectDataSet.CustomerTransactions]
GROUP BY 1,2,3,4
order by 1,2,3,4
LIMIT 1000
