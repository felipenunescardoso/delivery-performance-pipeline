USE master;
GO

IF DB_ID(N'Delivery_Performance_DW') IS NULL
BEGIN
    CREATE DATABASE [Delivery_Performance_DW];
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.sql_logins
    WHERE name = N'adm_pwbi'
)
BEGIN
    CREATE LOGIN [adm_pwbi]
    WITH PASSWORD = 'P0o9i*u7y6t5r4',
         CHECK_POLICY = OFF,
         CHECK_EXPIRATION = OFF;
END
GO

USE [Delivery_Performance_DW];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = N'adm_pwbi'
)
BEGIN
    CREATE USER [adm_pwbi] FOR LOGIN [adm_pwbi] WITH DEFAULT_SCHEMA=[dbo];
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members rm
    INNER JOIN sys.database_principals r
        ON r.principal_id = rm.role_principal_id
    INNER JOIN sys.database_principals m
        ON m.principal_id = rm.member_principal_id
    WHERE r.name = N'db_owner'
      AND m.name = N'adm_pwbi'
)
BEGIN
    ALTER ROLE [db_owner] ADD MEMBER [adm_pwbi];
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'dw')
BEGIN
    EXEC(N'CREATE SCHEMA [dw]');
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'etl')
BEGIN
    EXEC(N'CREATE SCHEMA [etl]');
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'ods')
BEGIN
    EXEC(N'CREATE SCHEMA [ods]');
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'rpt')
BEGIN
    EXEC(N'CREATE SCHEMA [rpt]');
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'stg')
BEGIN
    EXEC(N'CREATE SCHEMA [stg]');
END
GO

/****** Object:  Table [dw].[DimClient]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dw].[DimClient]', N'U') IS NULL
BEGIN
CREATE TABLE [dw].[DimClient](
	[ClientKey] [int] IDENTITY(1,1) NOT NULL,
	[idClient] [varchar](50) NOT NULL,
	[clientName] [varchar](200) NULL,
	[businessType] [varchar](100) NULL,
	[workDaysCalculation] [bit] NULL,
	[calculationRule] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[ClientKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

/****** Object:  Table [dw].[DimDate]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dw].[DimDate]', N'U') IS NULL
BEGIN
CREATE TABLE [dw].[DimDate](
	[DateKey] [int] NOT NULL,
	[FullDate] [date] NOT NULL,
	[DayNumber] [tinyint] NOT NULL,
	[MonthNumber] [tinyint] NOT NULL,
	[MonthName] [varchar](20) NOT NULL,
	[QuarterNumber] [tinyint] NOT NULL,
	[YearNumber] [smallint] NOT NULL,
	[WeekDayNumber] [tinyint] NOT NULL,
	[WeekDayName] [varchar](20) NOT NULL,
	[IsWeekend] [bit] NOT NULL,
	[IsBusinessDay_MonFri] [bit] NOT NULL,
	[IsBusinessDay_MonSat] [bit] NOT NULL,
	[IsBusinessDay_MonSun] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

/****** Object:  Table [dw].[DimRegion]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dw].[DimRegion]', N'U') IS NULL
BEGIN
CREATE TABLE [dw].[DimRegion](
	[RegionKey] [int] IDENTITY(1,1) NOT NULL,
	[consigneeProvince] [varchar](100) NULL,
	[consigneeCity] [varchar](150) NULL,
	[state] [varchar](100) NULL,
	[uf] [char](2) NULL,
	[cityType] [varchar](50) NULL,
	[region] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[RegionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

/****** Object:  Table [dw].[FactDeliveryPerformance]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dw].[FactDeliveryPerformance]', N'U') IS NULL
BEGIN
CREATE TABLE [dw].[FactDeliveryPerformance](
	[FactId] [bigint] IDENTITY(1,1) NOT NULL,
	[idOrder] [varchar](50) NOT NULL,
	[ClientKey] [int] NOT NULL,
	[RegionKey] [int] NOT NULL,
	[ReceiveDateKey] [int] NOT NULL,
	[DeliveredDateKey] [int] NOT NULL,
	[zipCode] [int] NULL,
	[sla] [int] NULL,
	[deliveryDays] [int] NULL,
	[delayDays] [int] NULL,
	[delayed] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[FactId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

/****** Object:  Table [ods].[client]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[ods].[client]', N'U') IS NULL
BEGIN
CREATE TABLE [ods].[client](
	[clientCode] [varchar](50) NOT NULL,
	[name] [varchar](200) NULL,
	[businessType] [varchar](100) NULL,
	[workDaysCalculation] [bit] NULL,
	[calculationRule] [varchar](30) NULL
) ON [PRIMARY]
END
GO

/****** Object:  Table [ods].[client_sla]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[ods].[client_sla]', N'U') IS NULL
BEGIN
CREATE TABLE [ods].[client_sla](
	[idClient] [varchar](50) NOT NULL,
	[zipIni] [int] NOT NULL,
	[zipEnd] [int] NOT NULL,
	[consigneeProvince] [varchar](100) NOT NULL,
	[city] [varchar](150) NULL,
	[cityType] [varchar](50) NULL,
	[sla] [int] NOT NULL
) ON [PRIMARY]
END
GO

/****** Object:  Table [ods].[orders]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[ods].[orders]', N'U') IS NULL
BEGIN
CREATE TABLE [ods].[orders](
	[idOrder] [varchar](50) NOT NULL,
	[idClient] [varchar](50) NOT NULL,
	[consignorProvince] [varchar](100) NULL,
	[consigneeProvince] [varchar](100) NULL,
	[consigneeZipCode] [int] NULL,
	[receiveDate] [datetime2](7) NULL,
	[deliveredTime] [datetime2](7) NULL
) ON [PRIMARY]
END
GO

/****** Object:  Table [ods].[region]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[ods].[region]', N'U') IS NULL
BEGIN
CREATE TABLE [ods].[region](
	[consigneeCity] [varchar](150) NOT NULL,
	[consigneeProvince] [varchar](100) NOT NULL,
	[uf] [char](2) NULL,
	[cityType] [varchar](50) NULL,
	[region] [varchar](50) NULL,
	[state] [varchar](50) NULL
) ON [PRIMARY]
END
GO

/****** Object:  Table [stg].[client]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[stg].[client]', N'U') IS NULL
BEGIN
CREATE TABLE [stg].[client](
	[clientCode] [varchar](50) NOT NULL,
	[name] [varchar](200) NULL,
	[businessType] [varchar](100) NULL,
	[workDaysCalculation] [bit] NULL,
	[calculationRule] [varchar](30) NULL
) ON [PRIMARY]
END
GO

/****** Object:  Table [stg].[client_raw]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[stg].[client_raw]', N'U') IS NULL
BEGIN
CREATE TABLE [stg].[client_raw](
	[clientCode] [varchar](50) NOT NULL,
	[name] [varchar](200) NULL,
	[businessType] [varchar](100) NULL,
	[workDaysCalculation] [varchar](5) NULL,
	[calculationRule] [varchar](30) NULL,
 CONSTRAINT [PK_client_raw] PRIMARY KEY CLUSTERED 
(
	[clientCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

/****** Object:  Table [stg].[client_sla_raw]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[stg].[client_sla_raw]', N'U') IS NULL
BEGIN
CREATE TABLE [stg].[client_sla_raw](
	[idClient] [varchar](50) NOT NULL,
	[zipIni] [int] NOT NULL,
	[zipEnd] [int] NOT NULL,
	[consigneeProvince] [varchar](100) NOT NULL,
	[city] [varchar](150) NULL,
	[cityType] [varchar](50) NULL,
	[sla] [int] NOT NULL,
 CONSTRAINT [PK_client_sla_raw] PRIMARY KEY CLUSTERED 
(
	[idClient] ASC,
	[zipIni] ASC,
	[zipEnd] ASC,
	[consigneeProvince] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

/****** Object:  Table [stg].[orders_raw]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[stg].[orders_raw]', N'U') IS NULL
BEGIN
CREATE TABLE [stg].[orders_raw](
	[idOrder] [varchar](50) NOT NULL,
	[idClient] [varchar](50) NOT NULL,
	[consignorProvince] [varchar](100) NULL,
	[consigneeProvince] [varchar](100) NULL,
	[consigneeZipCode] [varchar](20) NULL,
	[receiveDate] [datetime2](7) NULL,
	[deliveredTime] [datetime2](7) NULL,
 CONSTRAINT [PK_orders_raw] PRIMARY KEY CLUSTERED 
(
	[idOrder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

/****** Object:  Table [stg].[region_raw]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[stg].[region_raw]', N'U') IS NULL
BEGIN
CREATE TABLE [stg].[region_raw](
	[consigneeCity] [varchar](150) NOT NULL,
	[consigneeProvince] [varchar](100) NOT NULL,
	[uf] [char](2) NULL,
	[cityType] [varchar](50) NULL,
	[region] [varchar](50) NULL,
	[state] [varchar](50) NULL,
 CONSTRAINT [PK_region_raw] PRIMARY KEY CLUSTERED 
(
	[consigneeCity] ASC,
	[consigneeProvince] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

/****** Object:  Table [stg].[tmp_client_raw]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[stg].[tmp_client_raw]', N'U') IS NULL
BEGIN
CREATE TABLE [stg].[tmp_client_raw](
	[clientCode] [bigint] NULL,
	[name] [varchar](max) NULL,
	[businessType] [varchar](max) NULL,
	[workDaysCalculation] [varchar](max) NULL,
	[calculationRule] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

/****** Object:  Table [stg].[tmp_client_sla_raw]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[stg].[tmp_client_sla_raw]', N'U') IS NULL
BEGIN
CREATE TABLE [stg].[tmp_client_sla_raw](
	[idClient] [bigint] NULL,
	[zipIni] [bigint] NULL,
	[zipEnd] [bigint] NULL,
	[consigneeProvince] [varchar](max) NULL,
	[city] [varchar](max) NULL,
	[cityType] [varchar](max) NULL,
	[sla] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

/****** Object:  Table [stg].[tmp_orders_raw]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[stg].[tmp_orders_raw]', N'U') IS NULL
BEGIN
CREATE TABLE [stg].[tmp_orders_raw](
	[idOrder] [varchar](max) NULL,
	[idClient] [varchar](max) NULL,
	[consignorProvince] [varchar](max) NULL,
	[consigneeProvince] [varchar](max) NULL,
	[consigneeZipCode] [varchar](max) NULL,
	[receiveDate] [datetime] NULL,
	[deliveredTime] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

/****** Object:  Table [stg].[tmp_region_raw]    Script Date: 05/07/2026 13:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[stg].[tmp_region_raw]', N'U') IS NULL
BEGIN
CREATE TABLE [stg].[tmp_region_raw](
	[consigneeCity] [varchar](max) NULL,
	[consigneeProvince] [varchar](max) NULL,
	[uf] [varchar](max) NULL,
	[cityType] [varchar](max) NULL,
	[region] [varchar](max) NULL,
	[state] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

/****** Object:  StoredProcedure [dbo].[sp_LoadODS]    Script Date: 05/07/2026 13:53:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_LoadODS]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE ods.orders;
        TRUNCATE TABLE ods.client;
        TRUNCATE TABLE ods.client_sla;
        TRUNCATE TABLE ods.region;

        INSERT INTO ods.orders
        (
            idOrder,
            idClient,
            consignorProvince,
            consigneeProvince,
            consigneeZipCode,
            receiveDate,
            deliveredTime
        )
        SELECT
            LTRIM(RTRIM(idOrder)),
            LTRIM(RTRIM(idClient)),
            NULLIF(UPPER(LTRIM(RTRIM(consignorProvince))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(consigneeProvince))), ''),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(consigneeZipCode)), '')),
            receiveDate,
            deliveredTime
        FROM stg.orders_raw
        WHERE idOrder IS NOT NULL
          AND idClient IS NOT NULL;

        INSERT INTO ods.client
        (
            clientCode,
            name,
            businessType,
            workDaysCalculation,
            calculationRule
        )
        SELECT
            LTRIM(RTRIM(clientCode)),
            NULLIF(UPPER(LTRIM(RTRIM(name))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(businessType))), ''),
            workDaysCalculation,
            NULLIF(UPPER(LTRIM(RTRIM(calculationRule))), '')
        FROM stg.client_raw
        WHERE clientCode IS NOT NULL;

        INSERT INTO ods.client_sla
        (
            idClient,
            zipIni,
            zipEnd,
            consigneeProvince,
            city,
            cityType,
            sla
        )
        SELECT
            LTRIM(RTRIM(idClient)),
            zipIni,
            zipEnd,
            NULLIF(UPPER(LTRIM(RTRIM(consigneeProvince))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(city))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(cityType))), ''),
            sla
        FROM stg.client_sla_raw
        WHERE idClient IS NOT NULL;

        INSERT INTO ods.region
        (
            consigneeCity,
            consigneeProvince,
            uf,
            cityType,
            region,
            [state]
        )
        SELECT
            NULLIF(UPPER(LTRIM(RTRIM(consigneeCity))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(consigneeProvince))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(uf))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(cityType))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(region))), ''),
            NULLIF(UPPER(LTRIM(RTRIM([state]))), '')
        FROM stg.region_raw
        WHERE consigneeCity IS NOT NULL
          AND consigneeProvince IS NOT NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

/****** Object:  StoredProcedure [etl].[sp_FullLoadGold]    Script Date: 05/07/2026 13:53:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [etl].[sp_FullLoadGold]
AS
BEGIN
    SET NOCOUNT ON;

    EXEC etl.sp_LoadDimClient;
    EXEC etl.sp_LoadDimRegion;
    EXEC etl.sp_LoadDimDate;
    EXEC etl.sp_LoadFactDeliveryPerformance;
END;
GO

/****** Object:  StoredProcedure [etl].[sp_LoadDimClient]    Script Date: 05/07/2026 13:53:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [etl].[sp_LoadDimClient]
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dw.DimClient;

    INSERT INTO dw.DimClient
    (
        idClient,
        clientName,
        businessType,
        workDaysCalculation,
        calculationRule
    )
    SELECT DISTINCT
        clientCode,
        name,
        businessType,
        workDaysCalculation,
        calculationRule
    FROM ods.client
    WHERE clientCode IS NOT NULL;
END;
GO

/****** Object:  StoredProcedure [etl].[sp_LoadDimDate]    Script Date: 05/07/2026 13:53:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [etl].[sp_LoadDimDate]
    @StartDate DATE = '2026-01-01',
    @EndDate   DATE = '2026-12-31'
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dw.DimDate;

    ;WITH Dates AS
    (
        SELECT @StartDate AS FullDate

        UNION ALL

        SELECT DATEADD(DAY, 1, FullDate)
        FROM Dates
        WHERE FullDate < @EndDate
    )
    INSERT INTO dw.DimDate
    (
        DateKey,
        FullDate,
        DayNumber,
        MonthNumber,
        MonthName,
        QuarterNumber,
        YearNumber,
        WeekDayNumber,
        WeekDayName,
        IsWeekend,
        IsBusinessDay_MonFri,
        IsBusinessDay_MonSat,
        IsBusinessDay_MonSun
    )
    SELECT
        CONVERT(INT, FORMAT(FullDate, 'yyyyMMdd')) AS DateKey,
        FullDate,
        DAY(FullDate),
        MONTH(FullDate),
        DATENAME(MONTH, FullDate),
        DATEPART(QUARTER, FullDate),
        YEAR(FullDate),
        DATEPART(WEEKDAY, FullDate),
        DATENAME(WEEKDAY, FullDate),

        CASE 
            WHEN DATENAME(WEEKDAY, FullDate) IN ('Saturday', 'Sunday') THEN 1 
            ELSE 0 
        END AS IsWeekend,

        CASE 
            WHEN DATENAME(WEEKDAY, FullDate) NOT IN ('Saturday', 'Sunday') THEN 1 
            ELSE 0 
        END AS IsBusinessDay_MonFri,

        CASE 
            WHEN DATENAME(WEEKDAY, FullDate) <> 'Sunday' THEN 1 
            ELSE 0 
        END AS IsBusinessDay_MonSat,

        1 AS IsBusinessDay_MonSun
    FROM Dates
    OPTION (MAXRECURSION 0);
END;
GO

/****** Object:  StoredProcedure [etl].[sp_LoadDimRegion]    Script Date: 05/07/2026 13:53:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [etl].[sp_LoadDimRegion]
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dw.DimRegion;

    INSERT INTO dw.DimRegion
    (
        consigneeProvince,
        consigneeCity,
        [state],
        uf,
        cityType,
        region
    )
    SELECT DISTINCT
        consigneeProvince,
        consigneeCity,
        [state],
        uf,
        cityType,
        region
    FROM ods.region
    WHERE consigneeProvince IS NOT NULL
      AND consigneeCity IS NOT NULL;
END;
GO

/****** Object:  StoredProcedure [etl].[sp_LoadFactDeliveryPerformance]    Script Date: 05/07/2026 13:53:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [etl].[sp_LoadFactDeliveryPerformance]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE dw.FactDeliveryPerformance;

        INSERT INTO dw.FactDeliveryPerformance
        (
            idOrder,
            ClientKey,
            RegionKey,
            ReceiveDateKey,
            DeliveredDateKey,
            zipCode,
            sla,
            deliveryDays,
            delayDays,
            delayed
        )
        SELECT
            o.idOrder,

            dc.ClientKey,

            dr.RegionKey,

            CONVERT(INT, FORMAT(CAST(o.receiveDate AS DATE), 'yyyyMMdd')) AS ReceiveDateKey,

            CONVERT(INT, FORMAT(CAST(o.deliveredTime AS DATE), 'yyyyMMdd')) AS DeliveredDateKey,

            o.consigneeZipCode,

            cs.sla,

            DATEDIFF(DAY, o.receiveDate, o.deliveredTime) AS deliveryDays,

            CASE
                WHEN DATEDIFF(DAY, o.receiveDate, o.deliveredTime) - cs.sla > 0
                    THEN DATEDIFF(DAY, o.receiveDate, o.deliveredTime) - cs.sla
                ELSE 0
            END AS delayDays,

            CASE
                WHEN DATEDIFF(DAY, o.receiveDate, o.deliveredTime) > cs.sla
                    THEN 1
                ELSE 0
            END AS delayed

        FROM ods.orders o

        INNER JOIN dw.DimClient dc
            ON dc.idClient = o.idClient

        INNER JOIN ods.client_sla cs
            ON cs.idClient = o.idClient
           AND cs.consigneeProvince = o.consigneeProvince
           AND o.consigneeZipCode BETWEEN cs.zipIni AND cs.zipEnd

        INNER JOIN dw.DimRegion dr
            ON dr.consigneeProvince = cs.consigneeProvince
           AND dr.consigneeCity = cs.city

        INNER JOIN dw.DimDate rd
            ON rd.DateKey = CONVERT(INT, FORMAT(CAST(o.receiveDate AS DATE), 'yyyyMMdd'))

        INNER JOIN dw.DimDate dd
            ON dd.DateKey = CONVERT(INT, FORMAT(CAST(o.deliveredTime AS DATE), 'yyyyMMdd'))

        WHERE o.receiveDate IS NOT NULL
          AND o.deliveredTime IS NOT NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

/****** Object:  StoredProcedure [etl].[sp_LoadODS]    Script Date: 05/07/2026 13:53:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [etl].[sp_LoadODS]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        TRUNCATE TABLE ods.orders;
        TRUNCATE TABLE ods.client;
        TRUNCATE TABLE ods.client_sla;
        TRUNCATE TABLE ods.region;

        INSERT INTO ods.orders
        (
            idOrder,
            idClient,
            consignorProvince,
            consigneeProvince,
            consigneeZipCode,
            receiveDate,
            deliveredTime
        )
        SELECT
            LTRIM(RTRIM(idOrder)),
            LTRIM(RTRIM(idClient)),
            NULLIF(UPPER(LTRIM(RTRIM(consignorProvince))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(consigneeProvince))), ''),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(consigneeZipCode)), '')),
            receiveDate,
            deliveredTime
        FROM stg.orders_raw
        WHERE idOrder IS NOT NULL
          AND idClient IS NOT NULL;

        INSERT INTO ods.client
        (
            clientCode,
            name,
            businessType,
            workDaysCalculation,
            calculationRule
        )
        SELECT
            LTRIM(RTRIM(clientCode)),
            NULLIF(UPPER(LTRIM(RTRIM(name))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(businessType))), ''),
            CASE
				WHEN UPPER(workDaysCalculation) = 'Y' THEN 1
				WHEN UPPER(workDaysCalculation) = 'N' THEN 0
				ELSE NULL
			END as workDaysCalculation,
            NULLIF(UPPER(LTRIM(RTRIM(calculationRule))), '')
        FROM stg.client_raw
        WHERE clientCode IS NOT NULL;

        INSERT INTO ods.client_sla
        (
            idClient,
            zipIni,
            zipEnd,
            consigneeProvince,
            city,
            cityType,
            sla
        )
        SELECT
            LTRIM(RTRIM(idClient)),
            zipIni,
            zipEnd,
            NULLIF(UPPER(LTRIM(RTRIM(consigneeProvince))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(city))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(cityType))), ''),
            sla
        FROM stg.client_sla_raw
        WHERE idClient IS NOT NULL;

        INSERT INTO ods.region
        (
            consigneeCity,
            consigneeProvince,
            uf,
            cityType,
            region,
            [state]
        )
        SELECT
            NULLIF(UPPER(LTRIM(RTRIM(consigneeCity))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(consigneeProvince))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(uf))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(cityType))), ''),
            NULLIF(UPPER(LTRIM(RTRIM(region))), ''),
            NULLIF(UPPER(LTRIM(RTRIM([state]))), '')
        FROM stg.region_raw
        WHERE consigneeCity IS NOT NULL
          AND consigneeProvince IS NOT NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

/****** Object:  StoredProcedure [etl].[sp_TruncateStage]    Script Date: 05/07/2026 13:53:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [etl].[sp_TruncateStage]
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE stg.orders_raw;
    TRUNCATE TABLE stg.client_raw;
    TRUNCATE TABLE stg.client_sla_raw;
    TRUNCATE TABLE stg.region_raw;
END;
GO

