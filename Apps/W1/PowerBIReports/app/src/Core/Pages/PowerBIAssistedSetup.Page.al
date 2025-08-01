namespace Microsoft.PowerBIReports;

using System.Environment;
using System.Environment.Configuration;
using System.DateTime;
using System.Security.User;
using System.Utilities;

#pragma warning disable AS0125
#pragma warning disable AS0030
page 36950 "PowerBI Assisted Setup"
#pragma warning restore AS0030
#pragma warning restore AS0125
{
    PageType = NavigatePage;
    Caption = 'Power BI Assisted Setup';
    SourceTable = "PowerBI Reports Setup";
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(BannerStandard)
            {
                Editable = false;
                Visible = TopBannerVisible and (CurrentStep <> Steps::Finish);
                field(MediaResourcesStandardLogo; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }

            group(BannerDone)
            {
                Editable = false;
                Visible = TopBannerVisible and (CurrentStep = Steps::Finish);
                field(MediaResourcesDoneLogo; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }

            group(Step1)
            {
                Visible = CurrentStep = Steps::Intro;
                group(Introduction)
                {
                    Caption = 'Welcome to the Assisted Setup for Power BI ';
                    InstructionalText = 'This will guide you through how to connect to Power BI and configure how your data will be displayed.';
                }
                group(LetsGo)
                {
                    Caption = 'Let''s Go';
                    InstructionalText = 'Choose Next to set up the connector';
                }
            }

            group(Step2)
            {
                Visible = CurrentStep = Steps::DateTableConfig;
                group(CalendarInstruction)
                {
                    Caption = 'Calendar Type Configuration';
                    InstructionalText = 'Defines which type of calendar the year boundaries are applied to during Date table generation in Power BI. Using Weekly, the first and last day of the year might not correspond to a first and last day of a month, respectively.';
                }

                field(CalendarType; CalendarType)
                {
                    ApplicationArea = All;
                    ShowCaption = false;

                    trigger OnValidate()
                    begin
                        OnUpdateCalendarSelection();
                        CurrPage.Update(true);
                    end;

                }

                group(StandardCalendar)
                {
                    Caption = 'Standard Calendar Configuration';
                    InstructionalText = 'A standard monthly calendar that begins on January 1 and ends on December 31';
                    Visible = StandardCalendarVisible;

                    field(FirstDayOfWeek; Rec."First Day Of Week")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the first day of a week and defines when a week starts in a weekly calendar. US calendars typically use 0 (Sunday), whereas European calendars use 1 (Monday)';
                        Editable = true;
                    }
                    field(IsoCountryHolidays; Rec."ISO Country Holidays")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies which country to use in order to set the holidays in the calendar as non-working days';
                        Editable = true;
                    }
                }
                group(FiscalCalendar)
                {
                    Caption = 'Fiscal Monthly Calendar Configuration';
                    InstructionalText = 'A fiscal monthly calendar where the year starts on the first day of a month that is not January';
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
                        ToolTip = 'Specifies the first day of a week. US calendars typically use start on Sunday, whereas European calendars start on Monday';
                        Editable = true;
                    }
                    field(IsoCountryHolidays_Fiscal; Rec."ISO Country Holidays")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies which country to use in order to set the holidays in the calendar as non-working days';
                        Editable = true;
                    }
                }
                group(WeekBasedCalendar)
                {
                    Caption = 'Fiscal Weekly Calendar Configuration';
                    InstructionalText = 'A fiscal weekly calendar that supports: 4-4-5, 4-5-4, or 5-4-4';
                    Visible = WeeklyCalendarVisible;
                    field(FCalendarFirstMonth_Weekly; Rec."First Month of Fiscal Calendar")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the starting period for the Fiscal Weekly calendar.';
                        Editable = true;
                    }
                    field(FirstDayOfWeek_Weekly; Rec."First Day Of Week")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the first day of a week and defines when a week starts in the Fiscal Weekly calendar. US calendars typically start on Sunday, whereas European calendars start on Monday';
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
                        ToolTip = 'Specifies the number of weeks per period in each quarter. Quarters which always count 13 weeks in the Fiscal Weekly calendar';
                        Editable = true;
                    }
                }
            }

            group(Step3)
            {
                Visible = CurrentStep = Steps::UTCOffset;
                group(UTCOffset)
                {
                    Caption = 'UTC Offset';
                    InstructionalText = 'Defines the UTC time zone in the Power BI date table.';
                    field(TimeZone; Rec.GetTimeZoneDisplayName())
                    {
                        ApplicationArea = All;
                        Caption = 'Time Zone';
                        ToolTip = 'Specifies the time zone for Power BI related dates.';
                        ShowMandatory = true;

                        trigger OnAssistEdit()
                        begin
                            TimeZoneSelection.LookupTimeZone(Rec."Time Zone");
                        end;
                    }
                }
                group(DateTableRange)
                {
                    Caption = 'Date Table Range';
                    InstructionalText = 'Defines the range of dates to be generated in the Power BI date table. Fields are set automatically based on Accounting Periods. If there are budgets that extend past the last date in the Accounting Periods table, you will need to manually set the Ending Date to accommodate the extended range.';
                    field(DateTblStart; Rec."Date Table Starting Date")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
                    field(DateTblEnd; Rec."Date Table Ending Date")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
                }
            }

            group(Step4)
            {
                Visible = CurrentStep = Steps::WorkingDays;
                Caption = 'Configure Working Days';
                InstructionalText = 'Defines the working days of the week';
                part(WorkingDaySubform; "Working Days Subform")
                {
                    ApplicationArea = All;
                }

            }
            group(Step5)
            {
                Visible = CurrentStep = Steps::Setting;
#if not CLEAN25
                group(Settings)
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This group is no longer used.';
                    ObsoleteTag = '25.0';
                }
#endif
                group(FinanceReportSetup)
                {
                    Caption = 'Finance';
                    InstructionalText = 'Configure the Power BI Finance App.';
                    field("Finance Report Name"; Rec."Finance Report Name")
                    {
                        Caption = 'Power BI Finance Report';
                        ToolTip = 'Specifies the Power BI Finance Report.';
                        ApplicationArea = All;
                        Editable = false;

                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Finance Report ID", Rec."Finance Report Name");
                        end;
                    }
                    group(FinanceShowMoreGroup)
                    {
                        ShowCaption = false;
                        Visible = not FinanceTabVisible;
                        field(FinanceShowMore; ShowMoreTxt)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                FinanceTabVisible := not FinanceTabVisible;
                            end;
                        }
                    }
                    group(FinanceFastTab)
                    {
                        ShowCaption = false;
                        Visible = FinanceTabVisible;

                        group(IncomeStatementFilters)
                        {
                            Caption = 'Income Statement & G/L Budget Entry Filters';
                            InstructionalText = 'Filters Income Statement Entries and G/L Budget Entries';
                            field("Finance Start Date"; Rec."Finance Start Date")
                            {
                                Caption = 'Start Date';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the start date for Income Statement and G/L Budget Entries filter.';
                            }
                            field("Finance End Date"; Rec."Finance End Date")
                            {
                                Caption = 'End Date';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the end date for Income Statement and G/L Budget Entries filter.';
                            }
                        }
                        group(CustomerLedgerFilters)
                        {
                            Caption = 'Customer Ledger Entry Filters';

                            field("Cust. Ledger Entry Start Date"; Rec."Cust. Ledger Entry Start Date")
                            {
                                Caption = 'Start Date';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the start date for the Customer Ledger Entries filter.';
                            }
                            field("Cust. Ledger Entry End Date"; Rec."Cust. Ledger Entry End Date")
                            {
                                Caption = 'End Date';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the end date for the Customer Ledger Entries filter.';
                            }
                        }
                        group(VendorLedgerFilters)
                        {
                            Caption = 'Vendor Ledger Entry Filters';

                            field(VLERepStartDate; Rec."Vend. Ledger Entry Start Date")
                            {
                                Caption = 'Start Date';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the start date for the Vendor Ledger Entries filter.';
                            }
                            field("Vend. Ledger Entry End Date"; Rec."Vend. Ledger Entry End Date")
                            {
                                Caption = 'End Date';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the end date for the Vendor Ledger Entries filter.';
                            }
                        }
                        field(FinanceShowLess; ShowLessTxt)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                FinanceTabVisible := not FinanceTabVisible;
                            end;
                        }
                    }

                }

                group(ItemSalesReportSetup)
                {
                    Caption = 'Sales';
                    InstructionalText = 'Configure the Power BI Sales App.';
                    field("Sales Report Name"; Rec."Sales Report Name")
                    {
                        Caption = 'Power BI Sales Report';
                        ToolTip = 'Specifies the Power BI Sales Report.';
                        ApplicationArea = All;
                        Editable = false;
                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Sales Report ID", Rec."Sales Report Name");
                        end;
                    }
                    group(SalesShowMoreGroup)
                    {
                        ShowCaption = false;
                        Visible = not SalesTabVisible;
                        field(SalesShowMore; ShowMoreTxt)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                SalesTabVisible := not SalesTabVisible;
                            end;
                        }
                    }
                    group(SalesFastTab)
                    {
                        ShowCaption = false;
                        Visible = SalesTabVisible;
                        group(SalesDataFiltering)
                        {
                            ShowCaption = false;
                            InstructionalText = 'Configure the volume of data that is sent to your Power BI semantic models (optional).';
                            field(ItmSlsRepLoadDateType; Rec."Item Sales Load Date Type")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the date type for Item Sales report filter.';
                            }
                            group(ItmSlsRepLoadStartEndDateFilters)
                            {
                                ShowCaption = false;
                                Visible = Rec."Item Sales Load Date Type" = Rec."Item Sales Load Date Type"::"Start/End Date";

                                field(ItmSlsRepStartDate; Rec."Item Sales Start Date")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the start date for Item Sales report filter.';
                                }
                                field(ItmSlsRepEndDate; Rec."Item Sales End Date")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the end date for Item Sales report filter.';
                                }
                            }
                            group(ItmSlsRepRelativeDateFilter)
                            {
                                ShowCaption = false;
                                Visible = Rec."Item Purch. Load Date Type" = Rec."Item Purch. Load Date Type"::"Relative Date";

                                field(ItmSlsRepDateFormula; Rec."Item Sales Date Formula")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the date formula for Item Sales report filter.';
                                }
                            }
                        }
                        field(SalesShowLess; ShowLessTxt)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                SalesTabVisible := not SalesTabVisible;
                            end;
                        }
                    }
                }

                group(ItemPurchReportSetup)
                {
                    Caption = 'Purchases';
                    InstructionalText = 'Configure the Power BI Purchases App.';
                    field("Purchases Report Name"; Rec."Purchases Report Name")
                    {
                        Caption = 'Power BI Purchases Report';
                        ToolTip = 'Specifies the Power BI Purchases Report.';
                        ApplicationArea = All;
                        Editable = false;
                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Purchases Report ID", Rec."Purchases Report Name");
                        end;
                    }
                    group(PurchShowMoreGroup)
                    {
                        ShowCaption = false;
                        Visible = not PurchasesTabVisible;
                        field(PurchShowMore; ShowMoreTxt)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                PurchasesTabVisible := not PurchasesTabVisible;
                            end;
                        }
                    }
                    group(PurchFastTab)
                    {
                        ShowCaption = false;
                        Visible = PurchasesTabVisible;
                        group(PurchDataFiltering)
                        {
                            ShowCaption = false;
                            InstructionalText = 'Configure the volume of data that is sent to your Power BI semantic models (optional).';
                            field(ItmPchRepLoadDateType; Rec."Item Purch. Load Date Type")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the date type for Item Purchases report filter.';
                            }
                            group(ItmPchRepStartEndDateFilters)
                            {
                                ShowCaption = false;
                                Visible = Rec."Item Purch. Load Date Type" = Rec."Item Purch. Load Date Type"::"Start/End Date";

                                field(ItmPchRepStartDate; Rec."Item Purch. Start Date")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the start date for Item Purchases report filter.';
                                }
                                field(ItmPchRepEndDate; Rec."Item Purch. End Date")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the end date for Item Purchases report filter.';
                                }
                            }
                            group(ItmPchRepRelativeDateFilter)
                            {
                                ShowCaption = false;
                                Visible = Rec."Item Purch. Load Date Type" = Rec."Item Purch. Load Date Type"::"Relative Date";

                                field(ItmPchRepDateFormula; Rec."Item Purch. Date Formula")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the date formula for Item Purchases report filter.';
                                }
                            }
                        }
                        field(PurchShowLess; ShowLessTxt)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                PurchasesTabVisible := not PurchasesTabVisible;
                            end;
                        }
                    }
                }

                group(InventoryReportSetup)
                {
                    Caption = 'Inventory';
                    InstructionalText = 'Configure the Power BI Inventory App.';
                    field("Inventory Report Name"; Rec."Inventory Report Name")
                    {
                        Caption = 'Power BI Inventory Report';
                        ToolTip = 'Specifies the Power BI Inventory Report.';
                        ApplicationArea = All;
                        Editable = false;
                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Inventory Report ID", Rec."Inventory Report Name");
                        end;
                    }
                    field("Inventory Val. Report Name"; Rec."Inventory Val. Report Name")
                    {
                        Caption = 'Power BI Inventory Valuation Name';
                        ToolTip = 'Specifies the Power BI Inventory Valuation Report.';
                        ApplicationArea = All;
                        Editable = false;
                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Inventory Val. Report ID", Rec."Inventory Val. Report Name");
                        end;
                    }
                }

                group(JobsReportSetup)
                {
                    Caption = 'Projects';
                    InstructionalText = 'Configure the Power BI Projects App.';
                    field("Projects Report Name"; Rec."Projects Report Name")
                    {
                        Caption = 'Power BI Projects Report';
                        ToolTip = 'Specifies the Power BI Projects Report.';
                        ApplicationArea = All;
                        Editable = false;
                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Projects Report Id", Rec."Projects Report Name");
                        end;
                    }
                    group(ProjectsShowMoreGroup)
                    {
                        ShowCaption = false;
                        Visible = not ProjectTabVisible;
                        field(ProjectsShowMore; ShowMoreTxt)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                ProjectTabVisible := not ProjectTabVisible;
                            end;
                        }
                    }
                    group(ProjectsFastTab)
                    {
                        ShowCaption = false;
                        Visible = ProjectTabVisible;
                        group(JobLedgerFilters)
                        {
                            Caption = 'Project Ledger Entry Filters';
                            InstructionalText = 'Filters Project Ledger Entries';
                            field(JobLedgerStartDate; Rec."Job Ledger Entry Start Date")
                            {
                                Caption = 'Start Date';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the start date for Project Ledger Entries filter.';
                            }
                            field(JobLedgerEndDate; Rec."Job Ledger Entry End Date")
                            {
                                Caption = 'End Date';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the end date for Project Ledger Entries Entries filter.';
                            }
                        }
                        field(ProjectsShowLess; ShowLessTxt)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                ProjectTabVisible := not ProjectTabVisible;
                            end;
                        }
                    }
                }

                group(ManufacturingReportSetup)
                {
                    Caption = 'Manufacturing';
                    InstructionalText = 'Configure the Power BI Manufacturing App.';
                    field("Manufacturing Report Name"; Rec."Manufacturing Report Name")
                    {
                        Caption = 'Power BI Manufacturing Report';
                        ToolTip = 'Specifies the Power BI Manufacturing Report.';
                        ApplicationArea = All;
                        Editable = false;
                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Manufacturing Report ID", Rec."Manufacturing Report Name");
                        end;
                    }
                    group(ManuShowMoreGroup)
                    {
                        ShowCaption = false;
                        Visible = not ManufacturingTabVisible;
                        field(ManuShowMore; ShowMoreTxt)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                ManufacturingTabVisible := not ManufacturingTabVisible;
                            end;
                        }
                    }
                    group(ManuFastTab)
                    {
                        ShowCaption = false;
                        Visible = ManufacturingTabVisible;
                        group(ManufacturingRecordFilters)
                        {
                            ShowCaption = false;
                            InstructionalText = 'Configure the volume of data that is sent to your Power BI semantic models (optional).';

                            field(ManuRepLoadDateType; Rec."Manufacturing Load Date Type")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the date type for Manufacturing report filter.';
                            }
                            group(ManuRepStartEndDateFilters)
                            {
                                ShowCaption = false;
                                Visible = Rec."Manufacturing Load Date Type" = Rec."Manufacturing Load Date Type"::"Start/End Date";

                                field(ManuRepStartDate; Rec."Manufacturing Start Date")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the start date for Manufacturing report filter.';
                                }
                                field(ManuRepEndDate; Rec."Manufacturing End Date")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the end date for Manufacturing report filter.';
                                }
                            }

                            group(ManuRepRelativeDateFilter)
                            {
                                ShowCaption = false;
                                Visible = Rec."Manufacturing Load Date Type" = Rec."Manufacturing Load Date Type"::"Relative Date";

                                field(ManuRepDateFormula; Rec."Manufacturing Date Formula")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the date formula for Manufacturing report filter.';
                                }
                            }
                        }
                        field(ManuShowLess; ShowLessTxt)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                ManufacturingTabVisible := not ManufacturingTabVisible;
                            end;
                        }
                    }
                }
                group(SustainabilityReportSetup)
                {
                    Caption = 'Sustainability';
                    InstructionalText = 'Configure the Power BI Sustainability App.';

                    field("Sustainability Report Name"; Format(Rec."Sustainability Report Name"))
                    {
                        ApplicationArea = All;
                        Caption = 'Power BI Sustainability Report';
                        ToolTip = 'Specifies the Power BI Sustainability Report.';

                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Sustainability Report ID", Rec."Sustainability Report Name");
                        end;
                    }
                    group(SustShowMoreGroup)
                    {
                        ShowCaption = false;
                        Visible = not SustainabilityTabVisible;
                        field(SustShowMore; ShowMoreTxt)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                SustainabilityTabVisible := not SustainabilityTabVisible;
                            end;
                        }
                    }
                    group(SustFastTab)
                    {
                        ShowCaption = false;
                        Visible = SustainabilityTabVisible;
                        group(SustDataFiltering)
                        {
                            ShowCaption = false;
                            InstructionalText = 'Configure the volume of data that is sent to your Power BI semantic models (optional).';

                            field("Sustainability Load Date Type"; Rec."Sustainability Load Date Type")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the date type for Sustainability report filter.';
                            }
                            group(SustRepStartEndDateFilters)
                            {
                                ShowCaption = false;
                                Visible = Rec."Sustainability Load Date Type" = Rec."Sustainability Load Date Type"::"Start/End Date";

                                field("Sustainability Start Date"; Rec."Sustainability Start Date")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the start date for Sustainability report filter.';
                                }
                                field("Sustainability End Date"; Rec."Sustainability End Date")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the end date for Sustainability report filter.';
                                }
                            }
                            group(SustRepRelativeDateFilter)
                            {
                                ShowCaption = false;
                                Visible = Rec."Sustainability Load Date Type" = Rec."Sustainability Load Date Type"::"Relative Date";

                                field("Sustainability Date Formula"; Rec."Sustainability Date Formula")
                                {
                                    ApplicationArea = All;
                                    ToolTip = 'Specifies the date formula for Sustainability report filter.';
                                }
                            }
                        }
                        field(SustShowLess; ShowLessTxt)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;

                            trigger OnDrillDown()
                            begin
                                SustainabilityTabVisible := not SustainabilityTabVisible;
                            end;
                        }
                    }
                }
                group(SubscriptionBillingReportSetup)
                {
                    Caption = 'Subscription Billing';
                    InstructionalText = 'Configure the Power BI Subscription Billing App.';
                    field("Subscription Billing Report Name"; Rec."Subs. Billing Report Name")
                    {
                        Caption = 'Power BI Subscription Billing Report';
                        ToolTip = 'Specifies the Power BI Subscription Billing Report.';
                        ApplicationArea = All;
                        Editable = false;
                        trigger OnAssistEdit()
                        begin
                            SetupHelper.EnsureUserAcceptedPowerBITerms();
                            SetupHelper.LookupPowerBIReport(Rec."Subscription Billing Report ID", Rec."Subs. Billing Report Name");
                        end;
                    }
                }

            }

            group(Step6)
            {
                Visible = CurrentStep = Steps::Finish;
                group(Complete)
                {
                    Caption = 'All Done!';
                    InstructionalText = 'You have finished the Assisted Setup for Power BI Connector. Copy your Power BI Connection Details below for use when setting up your Power BI Reports. Choose Finish to complete the setup.';
                }
                group(ConnectionDetails)
                {
                    Caption = 'Connection Details';
                    field(Environment; Text.UpperCase(EnvironmentInformation.GetEnvironmentName()))
                    {
                        ApplicationArea = All;
                        Caption = 'Environment';
                        ToolTip = 'Specifies the environment used to connect Business Central to a Power BI semantic model.';
                        Editable = false;
                        MultiLine = false;
                        Style = Favorable;
                    }
                    field(Company; CompanyName)
                    {
                        ApplicationArea = All;
                        Caption = 'Company Name';
                        ToolTip = 'Specifies the company used to connect Business Central to a Power BI semantic model.';
                        Editable = false;
                        MultiLine = false;
                        Style = Favorable;
                    }
                    field(ViewDeveloperDoc; ViewDeveloperDocLbl)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        ToolTip = 'Click here to view the Power BI documentation.';

                        trigger OnDrillDown()
                        begin
                            Hyperlink(DevDocUrlTxt);
                        end;
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Back)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                ToolTip = 'Return to the previous step';

                trigger OnAction()
                begin
                    TakeStep(-1);
                end;
            }
            action(Next)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextEnabled;
                Visible = not FinishEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Continue to the next step';

                trigger OnAction()
                begin
                    TakeStep(1);
                end;
            }
            action(Finish)
            {
                Caption = 'Finish';
                Enabled = FinishEnabled;
                Visible = FinishEnabled;
                Image = Approve;
                InFooterBar = true;
                ApplicationArea = All;
                ToolTip = 'Complete the setup';

                trigger OnAction();
                begin
                    GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"PowerBI Assisted Setup");
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        GuidedExperience: Codeunit "Guided Experience";
        TimeZoneSelection: Codeunit "Time Zone Selection";
        EnvironmentInformation: Codeunit "Environment Information";
        SetupHelper: Codeunit "Setup Helper";
        Steps: Option Intro,DateTableConfig,UTCOffset,WorkingDays,Setting,Finish;
        PrevStep: Option;
        CurrentStep: Option;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        FinishEnabled: Boolean;
        TopBannerVisible: Boolean;
        TestEmailAddress: Text;
        ConfigCompleteEnabled: Boolean;
        AppInfo: ModuleInfo;
        AssistedSetupComplete: Boolean;
        ViewDeveloperDocLbl: Label 'Power BI Documentation';
        DevDocUrlTxt: Label 'https://learn.microsoft.com/en-au/dynamics365/business-central/admin-powerbi#get-ready-to-use-power-bi', Locked = true;
        CalendarType: Option ,Fiscal,Standard,Weekly;
        StandardCalendarVisible: Boolean;
        FiscalCalendarVisible: Boolean;
        WeeklyCalendarVisible: Boolean;
        FinanceTabVisible: Boolean;
        SalesTabVisible: Boolean;
        PurchasesTabVisible: Boolean;
        ProjectTabVisible: Boolean;
        ManufacturingTabVisible: Boolean;
        SustainabilityTabVisible: Boolean;
        ShowMoreTxt: Label 'Show More';
        ShowLessTxt: Label 'Show Less';
        AdminPermissionRequiredErr: Label 'Setting up Power BI requires the ''%1'' permission set (or equivalent) that your account doesn''t have. Ask your administrator to assign the permission set to you.', Comment = '%1 = permission set name';
        PermisionSetNameTok: Label 'Power BI Core Admin', Locked = true;

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        if not PowerBIReportsSetup.WritePermission() then
            Error(AdminPermissionRequiredErr, PermisionSetNameTok);
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        if NavApp.GetCurrentModuleInfo(AppInfo) then
            AssistedSetupComplete := GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"PowerBI Assisted Setup");

        if UserSetup.Get(UserId()) then
            TestEmailAddress := UserSetup."E-Mail";

        case Rec."Calendar Range" of
            Rec."Calendar Range"::Calendar:
                CalendarType := CalendarType::Standard;
            Rec."Calendar Range"::FiscalGregorian:
                CalendarType := CalendarType::Fiscal;
            Rec."Calendar Range"::FiscalWeekly:
                CalendarType := CalendarType::Weekly;
        end;

        LoadTopBanners();
        TakeStep(0);
    end;

    local procedure TakeStep(Step: Integer)
    begin
        case CurrentStep of
            Steps::UTCOffset:
                Rec.TestField("Time Zone");
        end;

        PrevStep := CurrentStep;
        CurrentStep := CurrentStep + Step;
        NextEnabled := false;
        BackEnabled := true;
        FinishEnabled := false;

        case CurrentStep of
            Steps::Intro:
                begin
                    BackEnabled := false;
                    NextEnabled := true;
                end;
            Steps::DateTableConfig:
                if CalendarType > 0 then
                    NextEnabled := true;
            Steps::UTCOffset:

                NextEnabled := true;
            Steps::WorkingDays:

                NextEnabled := true;
            Steps::Setting:

                NextEnabled := true;
            Steps::Finish:
                begin
                    FinishEnabled := true;
                    ConfigCompleteEnabled := AssistedSetupComplete;
                    NextEnabled := ConfigCompleteEnabled;
                end;
        end;
    end;

    local procedure LoadTopBanners()
    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    local procedure OnUpdateCalendarSelection()
    begin
        case CalendarType of
            CalendarType::Standard:
                begin
                    StandardCalendarVisible := true;
                    FiscalCalendarVisible := false;
                    WeeklyCalendarVisible := false;
                    Rec."Calendar Range" := Rec."Calendar Range"::Calendar;
                    TakeStep(0);
                end;
            CalendarType::Fiscal:
                begin
                    FiscalCalendarVisible := true;
                    StandardCalendarVisible := false;
                    WeeklyCalendarVisible := false;
                    Rec."Calendar Range" := Rec."Calendar Range"::FiscalGregorian;
                    TakeStep(0);
                end;
            CalendarType::Weekly:
                begin
                    WeeklyCalendarVisible := true;
                    FiscalCalendarVisible := false;
                    StandardCalendarVisible := false;
                    Rec."Calendar Range" := Rec."Calendar Range"::FiscalWeekly;
                    TakeStep(0);
                end;
        end;
    end;
}