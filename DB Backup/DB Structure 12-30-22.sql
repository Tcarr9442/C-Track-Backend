USE [Tracker]
GO
/****** Object:  User [express]    Script Date: 12/30/2022 4:24:27 PM ******/
CREATE USER [express] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [NodeExpress]    Script Date: 12/30/2022 4:24:27 PM ******/
CREATE USER [NodeExpress] FOR LOGIN [NodeExpress] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  Table [dbo].[assets]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[assets](
	[id] [varchar](50) NOT NULL,
	[status] [int] NOT NULL,
	[model_number] [varchar](50) NOT NULL,
	[return_reason] [text] NULL,
	[notes] [text] NULL,
	[watching] [text] NULL,
	[locked] [tinyint] NULL,
	[company] [varchar](50) NULL,
	[icc_id] [varchar](50) NULL,
	[mobile_number] [varchar](15) NULL,
	[hold_type] [varchar](50) NULL,
	[location] [varchar](15) NOT NULL,
	[is_decom] [tinyint] NULL,
 CONSTRAINT [PK_assets] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[in_house_assets]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[in_house_assets] as
select * from assets
where location = 'MDCentric'
GO
/****** Object:  Table [dbo].[jobs]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[jobs](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[job_code] [varchar](50) NOT NULL,
	[is_hourly] [tinyint] NOT NULL,
	[price] [decimal](13, 4) NOT NULL,
	[job_name] [varchar](255) NOT NULL,
	[status_only] [tinyint] NULL,
	[applies] [text] NULL,
	[requires_asset] [tinyint] NULL,
	[hourly_goal] [decimal](13, 4) NULL,
	[restricted_comments] [text] NULL,
	[prompt_count] [tinyint] NULL,
	[snipe_id] [int] NULL,
	[usage_rule_group] [varchar](15) NULL,
 CONSTRAINT [PK_job codes] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[usable_jobs]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[usable_jobs] as
select * from jobs
WHERE status_only IS NULL OR status_only = 0
GO
/****** Object:  View [dbo].[hourly_job_codes]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[hourly_job_codes] as
select * from jobs where is_hourly = 1
GO
/****** Object:  View [dbo].[ppd_job_codes]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[ppd_job_codes] as
select * from jobs where is_hourly = 0
GO
/****** Object:  Table [dbo].[rff]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rff](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[branch] [varchar](15) NOT NULL,
	[asset_id] [varchar](50) NOT NULL,
	[user] [varchar](50) NOT NULL,
	[added_by] [int] NOT NULL,
	[call_count] [int] NOT NULL,
	[added] [date] NOT NULL,
	[last_call] [datetime] NULL,
	[snooze_date] [date] NULL,
	[returned] [tinyint] NOT NULL,
	[lost_stolen] [tinyint] NOT NULL,
	[ticket] [varchar](15) NOT NULL,
	[last_caller] [int] NULL,
	[notes] [text] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[rff_to_call]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[rff_to_call]
AS
SELECT        id, branch, asset_id, [user], added_by, call_count, added, last_call, snooze_date, returned, lost_stolen, ticket, last_caller, notes
FROM            dbo.rff
WHERE        (returned = 0) AND (lost_stolen = 0) AND (snooze_date IS NULL) AND (added <= DATEADD(day, - 14, CONVERT(date, GETDATE()))) OR
                         (returned = 0) AND (lost_stolen = 0) AND (snooze_date IS NOT NULL) AND (snooze_date <= GETDATE())
GO
/****** Object:  View [dbo].[rff_stats]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[rff_stats] as
SELECT COUNT(*) AS [total],
    (
        SELECT COUNT(*) AS count
        FROM rff
        WHERE returned = 0
            AND lost_stolen = 0
    ) as [open],
    (
        SELECT COUNT(*) AS count
        FROM rff
        WHERE returned = 1
            OR lost_stolen = 1
    ) as [closed],
    (
        SELECT COUNT(*) AS count
        FROM rff
        WHERE returned = 0
            AND lost_stolen = 0
            AND (
                (
                    snooze_date IS NULL
                    AND added <= DATEADD(day, -14, convert(date, GETDATE()))
                )
                OR (
                    snooze_date IS NOT NULL
                    AND snooze_date <= DATEADD(day, -7, convert(date, GETDATE()))
                )
            )
    ) as [to_call],
    (
        SELECT COUNT(*) AS count
        FROM rff
        WHERE returned = 0
            and lost_stolen = 0
            AND snooze_date IS NOT NULL
    ) as [snoozed],
    (
        SELECT COUNT(*)
        FROM rff
        WHERE returned = 0
            AND lost_stolen = 1
    ) as [lost_stolen],
    (
        SELECT COUNT(DISTINCT branch)
        FROM rff
        WHERE returned = 0
            AND lost_stolen = 0
    ) as [branches],
    (
        SELECT COUNT(DISTINCT user)
        FROM rff
        WHERE returned = 0
            AND lost_stolen = 0
    ) as [users]
FROM rff
GO
/****** Object:  View [dbo].[rff_lost_stolen]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[rff_lost_stolen] as
SELECT * FROM rff WHERE lost_stolen = 1 AND returned = 0 order by last_call desc offset 0 rows

/** left off here **/
GO
/****** Object:  Table [dbo].[asset_tracking]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[asset_tracking](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[asset_id] [varchar](50) NULL,
	[job_code] [int] NOT NULL,
	[date] [date] NOT NULL,
	[notes] [text] NULL,
	[time] [time](7) NULL,
	[branch] [varchar](15) NULL,
 CONSTRAINT [PK_asset tracking] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[branches]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[branches](
	[id] [varchar](15) NOT NULL,
	[entity_number] [int] NULL,
	[is_closed] [tinyint] NOT NULL,
	[notes] [text] NULL,
	[phone] [varchar](15) NULL,
	[address] [varchar](255) NULL,
	[address2] [varchar](255) NULL,
	[city] [varchar](55) NULL,
	[state] [char](2) NULL,
 CONSTRAINT [PK_branch_code] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[common_parts]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[common_parts](
	[part_type] [varchar](50) NOT NULL,
	[manufacturer] [varchar](50) NULL,
 CONSTRAINT [PK_5] PRIMARY KEY CLUSTERED 
(
	[part_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[history]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[history](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[asset_id] [varchar](50) NULL,
	[old_status] [int] NULL,
	[new_status] [int] NULL,
	[user] [int] NOT NULL,
	[time] [datetime] NOT NULL,
	[ip_address] [varchar](255) NULL,
	[route] [varchar](255) NULL,
	[body] [text] NULL,
 CONSTRAINT [PK_history] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[hourly_tracking]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[hourly_tracking](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[job_code] [int] NOT NULL,
	[user_id] [int] NOT NULL,
	[start_time] [time](7) NOT NULL,
	[end_time] [time](7) NOT NULL,
	[notes] [text] NULL,
	[hours] [decimal](4, 2) NULL,
	[date] [date] NOT NULL,
	[in_progress] [tinyint] NULL,
 CONSTRAINT [PK_hourly tracking] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[inventory_history]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[inventory_history](
	[id] [int] IDENTITY(1000,7) NOT NULL,
	[user_id] [int] NOT NULL,
	[timestamp] [datetime] NOT NULL,
	[missing_assets] [text] NULL,
	[wrong_location_assets] [text] NULL,
	[up_to_date_assets] [text] NULL,
	[in_house_not_scanned] [text] NULL,
	[location_changes] [text] NULL,
 CONSTRAINT [PK_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[job_price_history]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[job_price_history](
	[job_id] [int] NOT NULL,
	[price] [decimal](13, 4) NOT NULL,
	[from] [date] NOT NULL,
	[to] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[models]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[models](
	[model_number] [varchar](50) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[category] [varchar](50) NOT NULL,
	[image] [text] NULL,
	[manufacturer] [varchar](50) NOT NULL,
	[parts_enabled] [tinyint] NOT NULL,
 CONSTRAINT [PK_models] PRIMARY KEY CLUSTERED 
(
	[model_number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[notifications]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[notifications](
	[id] [int] IDENTITY(10000,8) NOT NULL,
	[user_id] [int] NOT NULL,
	[read] [tinyint] NOT NULL,
	[archived] [tinyint] NOT NULL,
	[important] [tinyint] NOT NULL,
	[title] [varchar](255) NULL,
	[message] [text] NULL,
	[url] [text] NULL,
	[image] [text] NULL,
	[date] [datetime] NULL,
	[color] [varchar](11) NULL,
	[read_at] [datetime] NULL,
 CONSTRAINT [PK_Noti] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[part_list]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[part_list](
	[id] [int] IDENTITY(10000,3) NOT NULL,
	[part_type] [varchar](50) NOT NULL,
	[part_number] [varchar](50) NOT NULL,
	[image] [text] NULL,
	[minimum_stock] [int] NOT NULL,
	[models] [text] NOT NULL,
	[watchers] [text] NULL,
 CONSTRAINT [PK_9] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[parts]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[parts](
	[id] [int] IDENTITY(10000,3) NOT NULL,
	[part_id] [int] NOT NULL,
	[used_by] [int] NULL,
	[location] [varchar](50) NULL,
	[added_by] [int] NOT NULL,
	[added_on] [datetime] NOT NULL,
	[used_on] [datetime] NULL,
 CONSTRAINT [PK_27] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[user_permissions]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[user_permissions](
	[id] [int] NOT NULL,
	[view_jobcodes] [tinyint] NOT NULL,
	[edit_jobcodes] [tinyint] NOT NULL,
	[view_users] [tinyint] NOT NULL,
	[edit_users] [tinyint] NOT NULL,
	[use_importer] [tinyint] NOT NULL,
	[view_reports] [tinyint] NOT NULL,
	[view_models] [tinyint] NULL,
	[edit_models] [tinyint] NULL,
	[view_assets] [tinyint] NULL,
	[edit_assets] [tinyint] NULL,
	[use_hourly_tracker] [tinyint] NULL,
	[use_asset_tracker] [tinyint] NULL,
	[edit_others_worksheets] [tinyint] NULL,
	[view_particles] [tinyint] NOT NULL,
	[watch_assets] [tinyint] NULL,
	[use_repair_log] [tinyint] NOT NULL,
	[view_parts] [tinyint] NOT NULL,
	[edit_parts] [tinyint] NOT NULL,
	[view_part_types] [tinyint] NOT NULL,
	[edit_part_types] [tinyint] NOT NULL,
	[view_part_inventory] [tinyint] NOT NULL,
	[use_discrepancy_check] [tinyint] NOT NULL,
	[use_all_discrepancy_check] [tinyint] NOT NULL,
	[use_inventory_scan] [tinyint] NULL,
	[receive_historical_change_notifications] [tinyint] NULL,
	[view_branches] [tinyint] NOT NULL,
	[edit_branches] [tinyint] NOT NULL,
	[use_rff_tracking] [tinyint] NULL,
	[receive_early_checkin_notifications] [tinyint] NOT NULL,
	[receive_override_notifications] [tinyint] NOT NULL,
 CONSTRAINT [PK_108] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[users]    Script Date: 12/30/2022 4:24:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[users](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[is_admin] [tinyint] NOT NULL,
	[title] [varchar](50) NOT NULL,
	[name] [varchar](255) NOT NULL,
	[is_archived] [tinyint] NULL,
	[hrly_favorites] [text] NULL,
	[asset_favorites] [text] NULL,
	[oid] [varchar](50) NOT NULL,
	[tsheets_id] [varchar](11) NULL,
 CONSTRAINT [PK_users] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[assets] ADD  DEFAULT ((0)) FOR [locked]
GO
ALTER TABLE [dbo].[assets] ADD  DEFAULT ('CURO') FOR [company]
GO
ALTER TABLE [dbo].[assets] ADD  CONSTRAINT [df_location]  DEFAULT ('Unknown') FOR [location]
GO
ALTER TABLE [dbo].[branches] ADD  DEFAULT ((0)) FOR [is_closed]
GO
ALTER TABLE [dbo].[jobs] ADD  DEFAULT ((0)) FOR [status_only]
GO
ALTER TABLE [dbo].[jobs] ADD  DEFAULT ((1)) FOR [requires_asset]
GO
ALTER TABLE [dbo].[jobs] ADD  DEFAULT ((0)) FOR [prompt_count]
GO
ALTER TABLE [dbo].[models] ADD  DEFAULT ((0)) FOR [parts_enabled]
GO
ALTER TABLE [dbo].[notifications] ADD  DEFAULT ((0)) FOR [read]
GO
ALTER TABLE [dbo].[notifications] ADD  DEFAULT ((0)) FOR [archived]
GO
ALTER TABLE [dbo].[notifications] ADD  DEFAULT ((0)) FOR [important]
GO
ALTER TABLE [dbo].[notifications] ADD  DEFAULT (getdate()) FOR [date]
GO
ALTER TABLE [dbo].[notifications] ADD  DEFAULT (NULL) FOR [read_at]
GO
ALTER TABLE [dbo].[part_list] ADD  DEFAULT ((0)) FOR [minimum_stock]
GO
ALTER TABLE [dbo].[rff] ADD  DEFAULT ((0)) FOR [call_count]
GO
ALTER TABLE [dbo].[rff] ADD  DEFAULT (getdate()) FOR [added]
GO
ALTER TABLE [dbo].[rff] ADD  DEFAULT ((0)) FOR [returned]
GO
ALTER TABLE [dbo].[rff] ADD  DEFAULT ((0)) FOR [lost_stolen]
GO
ALTER TABLE [dbo].[user_permissions] ADD  CONSTRAINT [DF_user_permissions_view_jobcodes]  DEFAULT ((0)) FOR [view_jobcodes]
GO
ALTER TABLE [dbo].[user_permissions] ADD  CONSTRAINT [DF_user_permissions_edit_jobcodes]  DEFAULT ((0)) FOR [edit_jobcodes]
GO
ALTER TABLE [dbo].[user_permissions] ADD  CONSTRAINT [DF_user_permissions_view_users]  DEFAULT ((0)) FOR [view_users]
GO
ALTER TABLE [dbo].[user_permissions] ADD  CONSTRAINT [DF_user_permissions_edit_users]  DEFAULT ((0)) FOR [edit_users]
GO
ALTER TABLE [dbo].[user_permissions] ADD  CONSTRAINT [DF_user_permissions_use_importer]  DEFAULT ((0)) FOR [use_importer]
GO
ALTER TABLE [dbo].[user_permissions] ADD  CONSTRAINT [DF_user_permissions_view_reports]  DEFAULT ((0)) FOR [view_reports]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [view_models]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [edit_models]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [view_assets]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [edit_assets]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((1)) FOR [use_hourly_tracker]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((1)) FOR [use_asset_tracker]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [edit_others_worksheets]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [view_particles]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [watch_assets]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [use_repair_log]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [view_parts]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [edit_parts]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [view_part_types]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [edit_part_types]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [view_part_inventory]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((1)) FOR [use_discrepancy_check]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [use_all_discrepancy_check]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [use_inventory_scan]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [receive_historical_change_notifications]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [view_branches]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [edit_branches]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((1)) FOR [use_rff_tracking]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [receive_early_checkin_notifications]
GO
ALTER TABLE [dbo].[user_permissions] ADD  DEFAULT ((0)) FOR [receive_override_notifications]
GO
ALTER TABLE [dbo].[users] ADD  CONSTRAINT [DF_Users_is_admin]  DEFAULT ((0)) FOR [is_admin]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT ((0)) FOR [is_archived]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT ('0') FOR [oid]
GO
ALTER TABLE [dbo].[asset_tracking]  WITH CHECK ADD  CONSTRAINT [FK_asset_id] FOREIGN KEY([asset_id])
REFERENCES [dbo].[assets] ([id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[asset_tracking] CHECK CONSTRAINT [FK_asset_id]
GO
ALTER TABLE [dbo].[asset_tracking]  WITH CHECK ADD  CONSTRAINT [FK_job_code] FOREIGN KEY([job_code])
REFERENCES [dbo].[jobs] ([id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[asset_tracking] CHECK CONSTRAINT [FK_job_code]
GO
ALTER TABLE [dbo].[asset_tracking]  WITH CHECK ADD  CONSTRAINT [FK_user_id] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[asset_tracking] CHECK CONSTRAINT [FK_user_id]
GO
ALTER TABLE [dbo].[assets]  WITH CHECK ADD  CONSTRAINT [FK_branch_code] FOREIGN KEY([location])
REFERENCES [dbo].[branches] ([id])
GO
ALTER TABLE [dbo].[assets] CHECK CONSTRAINT [FK_branch_code]
GO
ALTER TABLE [dbo].[assets]  WITH CHECK ADD  CONSTRAINT [FK_model_number] FOREIGN KEY([model_number])
REFERENCES [dbo].[models] ([model_number])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[assets] CHECK CONSTRAINT [FK_model_number]
GO
ALTER TABLE [dbo].[assets]  WITH CHECK ADD  CONSTRAINT [FK_status] FOREIGN KEY([status])
REFERENCES [dbo].[jobs] ([id])
GO
ALTER TABLE [dbo].[assets] CHECK CONSTRAINT [FK_status]
GO
ALTER TABLE [dbo].[history]  WITH CHECK ADD  CONSTRAINT [FK_h_asset_id] FOREIGN KEY([asset_id])
REFERENCES [dbo].[assets] ([id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[history] CHECK CONSTRAINT [FK_h_asset_id]
GO
ALTER TABLE [dbo].[history]  WITH CHECK ADD  CONSTRAINT [FK_h_new_status] FOREIGN KEY([new_status])
REFERENCES [dbo].[jobs] ([id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[history] CHECK CONSTRAINT [FK_h_new_status]
GO
ALTER TABLE [dbo].[history]  WITH CHECK ADD  CONSTRAINT [FK_h_old_status] FOREIGN KEY([old_status])
REFERENCES [dbo].[jobs] ([id])
GO
ALTER TABLE [dbo].[history] CHECK CONSTRAINT [FK_h_old_status]
GO
ALTER TABLE [dbo].[history]  WITH CHECK ADD  CONSTRAINT [FK_h_user_id] FOREIGN KEY([user])
REFERENCES [dbo].[users] ([id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[history] CHECK CONSTRAINT [FK_h_user_id]
GO
ALTER TABLE [dbo].[hourly_tracking]  WITH CHECK ADD  CONSTRAINT [FK_hrly_job_code] FOREIGN KEY([job_code])
REFERENCES [dbo].[jobs] ([id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[hourly_tracking] CHECK CONSTRAINT [FK_hrly_job_code]
GO
ALTER TABLE [dbo].[hourly_tracking]  WITH CHECK ADD  CONSTRAINT [FK_hrly_user_id] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[hourly_tracking] CHECK CONSTRAINT [FK_hrly_user_id]
GO
ALTER TABLE [dbo].[inventory_history]  WITH CHECK ADD  CONSTRAINT [FK_inventory_history_user_id] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[inventory_history] CHECK CONSTRAINT [FK_inventory_history_user_id]
GO
ALTER TABLE [dbo].[job_price_history]  WITH CHECK ADD  CONSTRAINT [job_history_fk] FOREIGN KEY([job_id])
REFERENCES [dbo].[jobs] ([id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[job_price_history] CHECK CONSTRAINT [job_history_fk]
GO
ALTER TABLE [dbo].[notifications]  WITH CHECK ADD  CONSTRAINT [FK_user_noti] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[notifications] CHECK CONSTRAINT [FK_user_noti]
GO
ALTER TABLE [dbo].[part_list]  WITH CHECK ADD FOREIGN KEY([part_type])
REFERENCES [dbo].[common_parts] ([part_type])
GO
ALTER TABLE [dbo].[parts]  WITH CHECK ADD  CONSTRAINT [FK_parts_partnum] FOREIGN KEY([part_id])
REFERENCES [dbo].[part_list] ([id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[parts] CHECK CONSTRAINT [FK_parts_partnum]
GO
ALTER TABLE [dbo].[parts]  WITH CHECK ADD  CONSTRAINT [FK_pl_added_by] FOREIGN KEY([added_by])
REFERENCES [dbo].[users] ([id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[parts] CHECK CONSTRAINT [FK_pl_added_by]
GO
ALTER TABLE [dbo].[parts]  WITH CHECK ADD  CONSTRAINT [FK_pl_asset_id] FOREIGN KEY([location])
REFERENCES [dbo].[assets] ([id])
GO
ALTER TABLE [dbo].[parts] CHECK CONSTRAINT [FK_pl_asset_id]
GO
ALTER TABLE [dbo].[parts]  WITH CHECK ADD  CONSTRAINT [FK_pl_used_by] FOREIGN KEY([used_by])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[parts] CHECK CONSTRAINT [FK_pl_used_by]
GO
ALTER TABLE [dbo].[rff]  WITH CHECK ADD FOREIGN KEY([added_by])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[rff]  WITH CHECK ADD FOREIGN KEY([asset_id])
REFERENCES [dbo].[assets] ([id])
GO
ALTER TABLE [dbo].[rff]  WITH CHECK ADD FOREIGN KEY([branch])
REFERENCES [dbo].[branches] ([id])
GO
ALTER TABLE [dbo].[rff]  WITH CHECK ADD FOREIGN KEY([last_caller])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[user_permissions]  WITH CHECK ADD  CONSTRAINT [FK_u_id] FOREIGN KEY([id])
REFERENCES [dbo].[users] ([id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[user_permissions] CHECK CONSTRAINT [FK_u_id]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "rff"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 320
               Right = 692
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 4515
         Or = 5175
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'rff_to_call'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'rff_to_call'
GO
