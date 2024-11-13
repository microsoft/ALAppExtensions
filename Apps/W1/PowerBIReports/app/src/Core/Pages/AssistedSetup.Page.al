namespace Microsoft.PowerBIReports;

using System.Environment;
using System.Environment.Configuration;
using System.DateTime;
using System.Security.User;
using System.Utilities;

page 36950 "Assisted Setup"
{
    PageType = NavigatePage;
    // IMPORTANT: do not change the caption - see slice 546954
    Caption = 'Assisted Setup', Comment = 'IMPORTANT: Use the same translation as in System App''s page "Assisted Setup" id: "Page 799089619 - Property 2879900210"';
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
                            field(ItmSlsRepDateFormula; Rec."Item Sales Date Formula")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the date formula for Item Sales report filter.';
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
                            field(ItmPchRepDateFormula; Rec."Item Purch. Date Formula")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the date formula for Item Purchases report filter.';
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
                            Caption = 'Job Ledger Entry Filters';
                            InstructionalText = 'Filters Job Ledger Entries';
                            field(JobLedgerStartDate; Rec."Job Ledger Entry Start Date")
                            {
                                Caption = 'Start Date';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the start date for Job Ledger Entries filter.';
                            }
                            field(JobLedgerEndDate; Rec."Job Ledger Entry End Date")
                            {
                                Caption = 'End Date';
                                ApplicationArea = All;
                                ToolTip = 'Specifies the end date for Job Ledger Entries Entries filter.';
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
                            Caption = 'Manufacturing Document and Entry Filters';
                            InstructionalText = 'Filters Manufacturing Data';
                            field(ManuRepLoadDateType; Rec."Manufacturing Load Date Type")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the date type for Manufacturing report filter.';
                            }
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
                            field(ManuRepDateFormula; Rec."Manufacturing Date Formula")
                            {
                                ApplicationArea = All;
                                ToolTip = 'Specifies the date formula for Manufacturing report filter.';
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
            }

            group(Step6)
            {
                Visible = CurrentStep = Steps::Finish;
                group(Complete)
                {
                    Caption = 'All Done!';
                    InstructionalText = 'You have finished the Assisted Setup for Power BI Connector. Copy your Power BI Connection string below for use in connecting your Power BI Reports. Choose Finish to complete the setup.';
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
                    GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Assisted Setup");
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
        ShowMoreTxt: Label 'Show More';
        ShowLessTxt: Label 'Show Less';

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        if NavApp.GetCurrentModuleInfo(AppInfo) then
            AssistedSetupComplete := GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"Assisted Setup");

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