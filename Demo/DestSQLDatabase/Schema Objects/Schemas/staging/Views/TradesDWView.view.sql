CREATE VIEW [staging].[TradesDWView]
as
 SELECT 
		 Symbols.Symbol			Symbol_SymbolValue
		,Symbols.FullName		Symbol_FullName
		,tr.Side				Side_SideValue
		,tr.TimeStamp			FACT_ExecutionTimeKey
		,tr.Price				FACT_Price
		,tr.Size				FACT_Size
		,0						FACT_ExchangeFee
		,0						FACT_BrokerFee
		,0						FACT_SECFee
		,0						FACT_MarginFee
		,Accounts.AccountName	IGNORE_Account_AccountName
		,DeskName				IGNORE_Desk_DeskName
		,TraderName				IGNORE_Trader_TraderName
		,tr.ExecutionId			IGNORE_ExecutionId
	FROM staging.Trades tr
	inner join staging.TradersToDesksMap tdm on tdm.ToDMapId = tr.TraderDeskMapId
	inner join staging.Desks on Desks.DeskId = tdm.DeskId
	inner join staging.Traders on traders.TraderId = tdm.TraderId
	inner join staging.Accounts on Accounts.AccountId = tr.CustomerId
	inner join staging.Symbols on Symbols.SymbolId=  tr.SymbolId

--select * from staging.Accounts
--select * from staging.Desks
--select * from staging.TradersToDesksMap tdm