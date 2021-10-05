USE [EquipmentAnalyssis]
GO

Create View MiningReport with Schemabinding as
WITH RESULT AS
(

	Select round(sum(H.[Load Count]),2) as [Number of Loads], round(sum(H.Tonnes),2) as [Total Tonnes], H.[EQUIPID],
	 CAST(D.[Date] AS DATE) As Date
	from [dbo].[Fact_Hauling] H
	inner join [dbo].[dim_Date] D	on H.[Created Date_datekey] = D.DateId
	group by [Date], H.[EQUIPID]
)
,

AvgTonnesperLoad
  AS
(
    select EquipID,D.Date ,  (sum(Tonnes)/sum([Load Count])) as TonnesperLoad  from dbo.Fact_Hauling H
	inner join [dbo].[dim_Date] D	on H.[Created Date_datekey] = D.DateId
	group by D.Date, EQUIPID 
),

TotalOreTonnes AS
(
	Select [EQUIPID],D.Date ,round(sum([Tonnes]),2) as "Total Ore Tonnes" from [dbo].[Fact_Hauling] H
	inner join [dbo].[dim_Date] D	on H.[Created Date_datekey] = D.DateId
	where [Ore / Waste] = 'Ore' 
	group by D.Date, [EQUIPID]
),   

TotalOreLoad AS
(
	Select [EQUIPID],D.Date ,round(sum([Load Count]),2) as "Total Ore Loads" from [dbo].[Fact_Hauling] H
	inner join [dbo].[dim_Date] D	on H.[Created Date_datekey] = D.DateId
	where [Ore / Waste] = 'Ore' 
	group by D.Date, [EQUIPID]
),

TotalWasteLoad AS
(
	Select D.Date, [EQUIPID], round(sum([Load Count]),2) as [Total Waste Loads] from [dbo].[Fact_Hauling] H
	inner join [dbo].[dim_Date] D	on H.[Created Date_datekey] = D.DateId
	where [Ore / Waste] = 'Waste'
	group by D.Date, [EQUIPID]
)
,

TotalWasteTonnes AS
(
	Select D.Date, [EQUIPID], round(sum([Tonnes]),2) as [Total Waste Tonnes] from [dbo].[Fact_Hauling] H
	inner join [dbo].[dim_Date] D	on H.[Created Date_datekey] = D.DateId
	where [Ore / Waste] = 'Waste'
	group by D.Date, [EQUIPID]
)

Select  R.Date as [Haul Date],  E.[Equipment], E.[Equipment Type], E.Description, R.[Total Tonnes],   O.[Total Ore Tonnes], W.[Total Waste Tonnes],
	(
	  select  AVG(TonnesperLoad) from AvgTonnesperLoad a   Where  a.EQUIPID =R.EQUIPID and R.Date=a.Date  group by a.Date,a.EQUIPID
	 )  as AveragePerLoad , R.[Number of Loads], ol.[Total Ore Loads], wl.[Total Waste Loads]
	from Result R
	INNER JOIN TotalOreTonnes O	ON R.EQUIPID = O. EQUIPID  and R.Date=O.Date
	INNER JOIN  TotalWasteTonnes W 	ON R. EQUIPID = W.EQUIPID and R.Date=W.Date
	INNER JOIN [dbo].[Dim_Equipment] E ON E.[EQUIPID] = R.EQUIPID
	INNER JOIN TotalOreLoad  ol on ol.EQUIPID=R.EQUIPID and ol.Date=r.Date
	INNER JOIN TotalWasteLoad wl on wl.EQUIPID=R.EQUIPID and wl.Date=r.Date