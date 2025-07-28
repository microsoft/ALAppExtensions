namespace Microsoft.PowerBIReports;

using System.Environment;
using System.DateTime;
using Microsoft.Finance.PowerBIReports;

page 36951 "PowerBI Reports Setup"
{
    Caption = 'Power BI Connector Setup';
    SourceTable = "PowerBI Reports Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(ConnectionDetails)
            {
                Caption = 'Connection Details';

                group(EnvironmentDetails)
                {
                    ShowCaption = false;
                    field(Environment; Text.UpperCase(EnvironmentInformation.GetEnvironmentName()))
                    {
                        ApplicationArea = All;
                        Caption = 'Environment name';
                        ToolTip = 'Specifies the name for the environment  used to connect Business Central to a Power BI semantic model.';
                        Editable = false;
                        MultiLine = false;
                        Style = Favorable;
                    }
                    field(Company; CompanyName)
                    {
                        ApplicationArea = All;
                        Caption = 'Company Name';
                        ToolTip = 'Specifies the name of the company used to connect Business Central to a Power BI semantic model. Note:  this parameter is case sensitive. )';
                        Editable = false;
                        MultiLine = false;
                        Style = Favorable;
                    }
                }

                field(ViewDeveloperDoc; ViewDeveloperDocLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Click here to view the developer documentation.';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(DevDocUrlTxt);
                    end;
                }
            }

            group(DateSetup)
            {
                Caption = 'Date Table Configuration';
                group(CalendarDetails)
                {
                    ShowCaption = false;

                    field("Calendar Range"; Rec."Calendar Range")
                    {
                        ApplicationArea = All;
                        Caption = 'Calendar Type';
                        ToolTip = 'Specifies which type of calendar the year boundaries are applied to during Date table generation in Power BI. Using Weekly, the first and last day of the year might not correspond to a first and last day of a month, respectively.';

                        trigger OnValidate()
                        begin
                            OnUpdateCalendarSelection();
                            CurrPage.Update(true);
                        end;
                    }
                    group(StandardCalendar)
                    {
                        Caption = 'Standard Calendar Configuration';
                        Visible = StandardCalendarVisible;

                        field(FirstDayOfWeek; Rec."First Day Of Week")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the first day of a week and defines when a week starts in a weekly calendar. US calendars typically use 0 (Sunday), whereas European calendars use 1 (Monday).';
                            Editable = true;
                        }
                        field(IsoCountryHolidays; Rec."ISO Country Holidays")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies which country to use in order to set the holidays in the calendar as non-working days. A standard monthly calendar that begins on January 1 and ends on December 31';
                            Editable = true;
                        }
                    }
                    group(FiscalCalendar)
                    {
                        Caption = 'Fiscal Monthly Calendar Configuration';
                        Visible = FiscalCalendarVisible;
                        field(FCalendarFirstMonth; Rec."First Month of Fiscal Calendar")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the first month of the Fiscal calendar. If set to 1, the fiscal monthly calendar is identical to the standard calendar.';
                            Editable = true;
                        }
                        field(FirstDayOfWeek_Fiscal; Rec."First Day Of Week")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the first day of a week. US calendars typically use start on Sunday, whereas European calendars start on Monday.';
                            Editable = true;
                        }
                        field(IsoCountryHolidays_Fiscal; Rec."ISO Country Holidays")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies which country to use in order to set the holidays in the calendar as non-working days. A fiscal monthly calendar where the year starts on the first day of a month that is not January.';
                            Editable = true;
                        }
                    }
                    group(WeekBasedCalendar)
                    {
                        Caption = 'Fiscal Weekly Calendar Configuration';
                        Visible = WeeklyCalendarVisible;
                        field(FCalendarFirstMonth_Weekly; Rec."First Month of Fiscal Calendar")
                        {
                            Caption = 'First Month of Fiscal Weekly Calendar';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the starting period for the Fiscal Weekly calendar.';
                            Editable = true;
                        }
                        field(FirstDayOfWeek_Weekly; Rec."First Day Of Week")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the first day of a week and defines when a week starts in the Fiscal Weekly calendar. US calendars typically start on Sunday, whereas European calendars start on Monday.';
                            Editable = true;
                        }
                        field(IsoCountryHolidays_Weekly; Rec."ISO Country Holidays")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies which country to use in order to set the holidays in the calendar as non-working days';
                            Editable = true;
                        }
                        field(WeeklyType; Rec."Weekly Type")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the end of the year definition for the Fiscal Weekly calendar. Last: Last weekday of the month at Fiscal year end. Nearest: Last weekday nearest the end of month.';
                            Editable = true;
                        }
                        field(QuarterWeekType; Rec."Quarter Week Type")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the number of weeks per period in each quarter. Quarters which always count 13 weeks in the Fiscal Weekly calendar. A fiscal weekly calendar that supports: 4-4-5, 4-5-4, or 5-4-4.';
                            Editable = true;
                        }
                    }
                }
                group(UTCOffset)
                {
                    Caption = 'UTC Offset';
                    field(TimeZone; Rec.GetTimeZoneDisplayName())
                    {
                        ApplicationArea = All;
                        Caption = 'Time Zone';
                        ToolTip = 'Specifies the time zone for Power BI related dates.';

                        trigger OnAssistEdit()
                        begin
                            TimeZoneSelection.LookupTimeZone(Rec."Time Zone");
                        end;
                    }
                }
                group(StartEndDate)
                {
                    Caption = 'Date Table Range';
                    field("Date Table Starting Date"; Rec."Date Table Starting Date")
                    {
                        Caption = 'Starting Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the starting date reference for the Power BI Date table.';
                        Editable = true;
                    }
                    field("Date Table Ending Date"; Rec."Date Table Ending Date")
                    {
                        Caption = 'Ending Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the ending date reference for the Power BI Date table.';
                        Editable = true;
                    }
                }
            }

            group(FinanceReport)
            {
                Caption = 'Finance Report';
                group(FinanceGeneral)
                {
                    ShowCaption = false;
                    field("Finance Report Name"; Format(Rec."Finance Report Name"))
                    {
                        ApplicationArea = All;
                        Caption = 'Power BI Finance App';
                        ToolTip = 'Specifies where you have installed the Power BI Finance App.';

                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Finance Report ID", Rec."Finance Report Name");
                        end;
                    }
                }
                group(IncomeStatementFilters)
                {
                    Caption = 'Income Statement & G/L Account Filters';
                    field("Finance Start Date"; Rec."Finance Start Date")
                    {
                        Caption = 'Start Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the start date for the Income Statement and G/L Accounts filter (if you want to restrict the amount of data that is loaded to the semantic model in Power BI).';
                    }
                    field("Finance End Date"; Rec."Finance End Date")
                    {
                        Caption = 'End Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the end date for the Income Statement and G/L Accounts filter (if you want to restrict the amount of data that is loaded to the semantic model in Power BI).';
                    }
                }
                group(CustomerLedgerFilters)
                {
                    Caption = 'Customer Ledger Entry Filters';

                    field("Cust. Ledger Entry Start Date"; Rec."Cust. Ledger Entry Start Date")
                    {
                        Caption = 'Start Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the start date for the Customer Ledger Entries filter (if you want to restrict the amount of data that is loaded to the semantic model in Power BI).';
                    }
                    field("Cust. Ledger Entry End Date"; Rec."Cust. Ledger Entry End Date")
                    {
                        Caption = 'End Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the end date for the Customer Ledger Entries filter (if you want to restrict the amount of data that is loaded to the semantic model in Power BI).';
                    }
                }
                group(VendorLedgerFilters)
                {
                    Caption = 'Vendor Ledger Entry Filters';

                    field("Vend. Ledger Entry Start Date"; Rec."Vend. Ledger Entry Start Date")
                    {
                        Caption = 'Start Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the start date for the Vendor Ledger Entries filter (if you want to restrict the amount of data that is loaded to the semantic model in Power BI).';
                    }
                    field("Vend. Ledger Entry End Date"; Rec."Vend. Ledger Entry End Date")
                    {
                        Caption = 'End Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the end date for the Vendor Ledger Entries filter (if you want to restrict the amount of data that is loaded to the semantic model in Power BI).';
                    }
                }
            }

            group(ItemSalesReport)
            {
                Caption = 'Sales Report';
                group(SalesGeneral)
                {
                    ShowCaption = false;
                    field("Sales Report Name"; Format(Rec."Sales Report Name"))
                    {
                        ApplicationArea = All;
                        Caption = 'Power BI Sales App';
                        ToolTip = 'Specifies where you have installed the Power BI Sales App.';

                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Sales Report ID", Rec."Sales Report Name");
                        end;
                    }
                }
                field("Item Sales Load Date Type"; Rec."Item Sales Load Date Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date filtering type for Item Sales report filter (if you want to restrict the amount of data that is loaded to the semantic model in Power BI). Choose Start/End Date to define an interval for which to load data. Chose Relative Date to load data based on a date formula, e.g. last 6 months.';
                }
                field("Item Sales Start Date"; Rec."Item Sales Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the start date for Item Sales report filter. Set this if you have specified Start/End Date as the Load Date Type.';
                }
                field("Item Sales End Date"; Rec."Item Sales End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the end date for Item Sales report filter. Set this if you have specified Start/End Date as the Load Date Type.';
                }
                field("Item Sales Date Formula"; Rec."Item Sales Date Formula")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date formula for Item Sales report filter. Set this if you have specified Relative Date as the Load Date Type.';
                }
            }

            group(ItemPurchasesReport)
            {
                Caption = 'Purchases Report';
                group(PurchasesGeneral)
                {
                    ShowCaption = false;
                    field("Purchases Report Name"; Format(Rec."Purchases Report Name"))
                    {
                        ApplicationArea = All;
                        Caption = 'Power BI Purchases App';
                        ToolTip = 'Specifies where you have installed the Power BI Purchases App.';
                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Purchases Report ID", Rec."Purchases Report Name");
                        end;
                    }
                }
                field("Item Purch. Load Date Type"; Rec."Item Purch. Load Date Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date type for Item Purchases report filter (if you want to restrict the amount of data that is loaded to the semantic model in Power BI). Choose Start/End Date to define an interval for which to load data. Chose Relative Date to load data based on a date formula, e.g. last 6 months.';
                }
                field("Item Purch. Start Date"; Rec."Item Purch. Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the start date for Item Purchases report filter. Set this if you have specified Start/End Date as the Load Date Type.';
                }
                field("Item Purch. End Date"; Rec."Item Purch. End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the end date for Item Purchases report filter. Set this if you have specified Start/End Date as the Load Date Type.';
                }
                field("Item Purch. Date Formula"; Rec."Item Purch. Date Formula")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date formula for Item Purchases report filter. Set this if you have specified Relative Date as the Load Date Type.';
                }
            }

            group(InventoryReport)
            {
                Caption = 'Inventory Report';
                group(InventoryGeneral)
                {
                    ShowCaption = false;
                    field("Inventory Report Name"; Format(Rec."Inventory Report Name"))
                    {
                        ApplicationArea = All;
                        Caption = 'Power BI Inventory App';
                        ToolTip = 'Specifies where you have installed the Power BI Inventory App.';

                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Inventory Report ID", Rec."Inventory Report Name");
                        end;
                    }
                    field("Inventory Val. Report Name"; Format(Rec."Inventory Val. Report Name"))
                    {
                        ApplicationArea = All;
                        Caption = 'Power BI Inventory Valuation App';
                        ToolTip = 'Specifies where you have installed the Power BI Inventory Valuation App.';

                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Inventory Val. Report ID", Rec."Inventory Val. Report Name");
                        end;
                    }
                }
            }

            group(JobsReport)
            {
                Caption = 'Projects Report';
                group(ProjectsGeneral)
                {
                    ShowCaption = false;
                    field("Projects Report Name"; Format(Rec."Projects Report Name"))
                    {
                        ApplicationArea = All;
                        Caption = 'Power BI Projects App';
                        ToolTip = 'Specifies where you have installed the Power BI Projects App.';

                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Projects Report ID", Rec."Projects Report Name");
                        end;
                    }
                }
                group(ProjectsLedgerEntryFilters)
                {
                    Caption = 'Projects Ledger Entry Filters';
                    field("Job Ledger Entry Start Date"; Rec."Job Ledger Entry Start Date")
                    {
                        Caption = 'Start Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the start date for Projects Ledger Entries filter (if you want to restrict the amount of data that is loaded to the semantic model in Power BI).';
                    }
                    field("Job Ledger Entry End Date"; Rec."Job Ledger Entry End Date")
                    {
                        Caption = 'End Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the end date for Projects Ledger Entries filter (if you want to restrict the amount of data that is loaded to the semantic model in Power BI).';
                    }
                }
            }

            group(ManufacturingReport)
            {
                Caption = 'Manufacturing Report';
                group(ManufacturingGeneral)
                {
                    ShowCaption = false;
                    field("Manufacturing Report Name"; Format(Rec."Manufacturing Report Name"))
                    {
                        ApplicationArea = All;
                        Caption = 'Power BI Manufacturing App';
                        ToolTip = 'Specifies where you have installed the Power BI Manufacturing App.';

                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Manufacturing Report ID", Rec."Manufacturing Report Name");
                        end;
                    }
                }
                field("Manufacturing Load Date Type"; Rec."Manufacturing Load Date Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date type for Manufacturing report filter (if you want to restrict the amount of data that is loaded to the semantic model in Power BI). Choose Start/End Date to define an interval for which to load data. Chose Relative Date to load data based on a date formula, e.g. last 6 months.';
                }
                field("Manufacturing Start Date"; Rec."Manufacturing Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the start date for Manufacturing report filter. Set this if you have specified Start/End Date as the Load Date Type.';
                }
                field("Manufacturing End Date"; Rec."Manufacturing End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the end date for Manufacturing report filter. Set this if you have specified Start/End Date as the Load Date Type.';
                }
                field("Manufacturing Date Formula"; Rec."Manufacturing Date Formula")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date formula for Manufacturing report filter. Set this if you have specified Relative Date as the Load Date Type.';
                }
            }
            group(SustainabilityReport)
            {
                Caption = 'Sustainability Report';
                group(SustainabilityGeneral)
                {
                    ShowCaption = false;
                    field("Sustainability Report Name"; Format(Rec."Sustainability Report Name"))
                    {
                        ApplicationArea = All;
                        Caption = 'Power BI Sustainability App';
                        ToolTip = 'Specifies where you have installed the Power BI Sustainability App.';

                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Sustainability Report ID", Rec."Sustainability Report Name");
                        end;
                    }
                }
                field("Sustainability Load Date Type"; Rec."Sustainability Load Date Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date filtering type for Sustainability report filter (if you want to restrict the amount of data that is loaded to the semantic model in Power BI). Choose Start/End Date to define an interval for which to load data. Chose Relative Date to load data based on a date formula, e.g. last 6 months.';
                }
                field("Sustainability Start Date"; Rec."Sustainability Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the start date for Sustainability report filter. Set this if you have specified Start/End Date as the Load Date Type.';
                }
                field("Sustainability End Date"; Rec."Sustainability End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the end date for Sustainability report filter. Set this if you have specified Start/End Date as the Load Date Type.';
                }
                field("Sustainability Date Formula"; Rec."Sustainability Date Formula")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date formula for Sustainability report filter. Set this if you have specified Relative Date as the Load Date Type.';
                }
            }
            group(SubscriptionBillingReport)
            {
                Caption = 'Subscription Billing Report';
                group(SubscriptionBillingGeneral)
                {
                    ShowCaption = false;
                    field("Subscription Billing Report Name"; Format(Rec."Subs. Billing Report Name"))
                    {
                        ApplicationArea = All;
                        Caption = 'Power BI Subscription Billing App';
                        ToolTip = 'Specifies where you have installed the Power BI Subscription Billing App.';

                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Subscription Billing Report ID", Rec."Subs. Billing Report Name");
                        end;
                    }
                }
            }


            group(Dimensions)
            {
                Caption = 'Dimensions';

                field(LastDimensionSetEntryDateTime; Rec."Last Dim. Set Entry Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the last Dimension Set Entry was inserted or modified in the database. To improve performance, the "Update Power BI Dimension Set Entries" job queue entry will retrieve and insert Dimension Set Entry records from this point onwards.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(InsertJobQueue)
            {
                ApplicationArea = All;
                Caption = 'Schedule Power BI Dimension Refresh';
                ToolTip = 'Create a job queue entry that will refresh Power BI Dimension Set Entries in the background. This is required for dimensions to be displayed in Power BI Reports.';
                Image = Setup;

                trigger OnAction()
                var
                    JobQueueCreatedMsg: Label 'Job Queue Entry created successfully. You can view or edit this entry on the Job Queue Entries page.';
                begin
                    Initialization.RestoreDimensionSetEntryCollectionJobQueueEntry();
                    Message(JobQueueCreatedMsg);
                end;
            }
            action(SetupWorkingDays)
            {
                ApplicationArea = All;
                Caption = 'Working Days';
                ToolTip = 'Specifies the working days of the week.';
                Image = Calendar;
                RunObject = page "Working Days Setup";
            }
            action(AccountCategories)
            {
                ApplicationArea = All;
                Caption = 'Power BI Account Categories';
                ToolTip = 'Set up your G/L account categories in the Power BI Finance reports.';
                RunObject = page "Account Categories";
                Image = MapAccounts;
            }
            action(CloseIncomeStatementSourceCodes)
            {
                ApplicationArea = All;
                Caption = 'Close Income Statement Source Codes';
                ToolTip = 'Setup your close income statement source codes in the Power BI Finance reports.';
                Image = CodesList;
                RunObject = page "PBI Close Income Stmt. SC.";
            }
        }

        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(InsertJobQueue_Promoted; InsertJobQueue)
                {
                }
                actionref(SetupWorkingDays_Promoted; SetupWorkingDays)
                {
                }
                actionref(AccountCategories_Promoted; AccountCategories)
                {
                }
                actionref(CloseIncomeStatementSourceCodes_Promoted; CloseIncomeStatementSourceCodes)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        PowerBIInitialization: Codeunit Initialization;
    begin
        if not Rec.FindFirst() then
            PowerBIInitialization.SetupDefaultsForPowerBIReportsIfNotInitialized();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        OnUpdateCalendarSelection();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if Rec."Item Sales Load Date Type" = Rec."Item Sales Load Date Type"::"Relative Date" then
            Rec.TestField("Item Sales Date Formula");
    end;

    local procedure OnUpdateCalendarSelection()
    begin
        case Rec."Calendar Range" of
            Rec."Calendar Range"::Calendar:
                begin
                    StandardCalendarVisible := true;
                    FiscalCalendarVisible := false;
                    WeeklyCalendarVisible := false;
                end;
            Rec."Calendar Range"::FiscalGregorian:
                begin
                    FiscalCalendarVisible := true;
                    StandardCalendarVisible := false;
                    WeeklyCalendarVisible := false;
                end;
            Rec."Calendar Range"::FiscalWeekly:
                begin
                    WeeklyCalendarVisible := true;
                    FiscalCalendarVisible := false;
                    StandardCalendarVisible := false;
                end;
        end;
    end;

    var
        EnvironmentInformation: Codeunit "Environment Information";
        Initialization: Codeunit Initialization;
        TimeZoneSelection: Codeunit "Time Zone Selection";
        SetupHelper: Codeunit "Setup Helper";
        ViewDeveloperDocLbl: Label 'Install Power BI apps for Business Central (documentation)';
        DevDocUrlTxt: Label 'https://learn.microsoft.com/dynamics365/business-central/across-powerbi-install-business-central-apps', Locked = true;
        StandardCalendarVisible: Boolean;
        FiscalCalendarVisible: Boolean;
        WeeklyCalendarVisible: Boolean;
}