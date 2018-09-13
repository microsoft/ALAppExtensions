page 69597 "RUL Vendor G/L Turnover"
{
    // version RUL

    Caption = 'Vendor G/L Turnover';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SaveValues = true;
    SourceTable = Vendor;
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(PeriodType; PeriodType)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'View by';
                    OptionCaption = 'Day,Week,Month,Quarter,Year,Accounting Period';
                    ToolTip = 'Day';

                    trigger OnValidate()
                    begin
                        FindPeriod('');
                        CurrPage.Update;
                    end;
                }
            }
            repeater(Control5)
            {
                Editable = false;
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Vendor Posting Group"; "Vendor Posting Group")
                {
                    Visible = false;
                }
                field("G/L Starting Balance"; "RUL G/L Starting Balance")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Caption = 'Starting Balance';
                    ToolTip = 'Specifies the general ledger starting balance associated with the vendor.';
                }
                field("G/L Debit Amount"; "RUL G/L Debit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    BlankNumbers = BlankZero;
                    Caption = 'Debit Amount (LCY)';
                    ToolTip = 'Specifies the general ledger debit amount associated with the vendor.';
                }
                field("G/L Credit Amount"; "RUL G/L Credit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    BlankNumbers = BlankZero;
                    Caption = 'Credit Amount (LCY)';
                    ToolTip = 'Specifies the general ledger credit amount associated with the vendor.';
                }
                field("G/L Balance to Date"; "RUL G/L Balance to Date")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Caption = 'Ending Balance';
                    ToolTip = 'Specifies the general ledger balance to date associated with the vendor.';
                }
                field("G/L Net Change"; "RUL G/L Net Change")
                {
                    BlankZero = true;
                    Caption = 'Net Change (LCY)';
                    ToolTip = 'Specifies the general ledger net change associated with the vendor.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Vendor")
            {
                Caption = '&Vendor';
                Image = Vendor;
                action(Card)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Card';
                    Image = EditLines;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    begin
                        Vendor.Copy(Rec);
                        PAGE.Run(PAGE::"Vendor Card", Vendor);
                    end;
                }
            }
        }
        area(processing)
        {
            action("Previous Period")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Previous Period';
                Image = PreviousRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Previous Period';

                trigger OnAction()
                begin
                    FindPeriod('<=');
                end;
            }
            action("Next Period")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next Period';
                Image = NextRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Next Period';

                trigger OnAction()
                begin
                    FindPeriod('>=');
                end;
            }
        }
        area(reporting)
        {
        }
    }

    trigger OnOpenPage()
    begin
        DateFilter := GetFilter("Date Filter");
        if DateFilter = '' then begin
            if PeriodType = PeriodType::"Accounting Period" then
                FindPeriodUser('')
            else
                FindPeriod('');
        end else
            SetRange("RUL G/L Starting Date Filter", GetRangeMin("Date Filter") - 1);
    end;

    var
        Vend: Record Vendor;
        UserPeriods: Record "User Setup";
        Vendor: Record Vendor;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        DateFilter: Text;

    local procedure FindPeriod(SearchText: Code[10])
    var
        Calendar: Record Date;
        PeriodFormManagement: Codeunit PeriodFormManagement;
    begin
        if GetFilter("Date Filter") <> '' then begin
            Calendar.SetFilter("Period Start", GetFilter("Date Filter"));
            if not PeriodFormManagement.FindDate('+', Calendar, PeriodType) then
                PeriodFormManagement.FindDate('+', Calendar, PeriodType::Day);
            Calendar.SetRange("Period Start");
        end;
        PeriodFormManagement.FindDate(SearchText, Calendar, PeriodType);
        SetRange("Date Filter", Calendar."Period Start", Calendar."Period End");
        if GetRangeMin("Date Filter") = GetRangeMax("Date Filter") then
            SetRange("Date Filter", GetRangeMin("Date Filter"));
        SetRange("RUL G/L Starting Date Filter", GetRangeMin("Date Filter") - 1);
    end;

    local procedure FindPeriodUser(SearchText: Code[10])
    var
        Calendar: Record Date;
        PeriodFormManagement: Codeunit PeriodFormManagement;
    begin
        if UserPeriods.Get(UserId) then begin
            SetRange("Date Filter", UserPeriods."Allow Posting From", UserPeriods."Allow Posting To");
            if GetRangeMin("Date Filter") = GetRangeMax("Date Filter") then
                SetRange("Date Filter", GetRangeMin("Date Filter"));
        end else begin
            if GetFilter("Date Filter") <> '' then begin
                Calendar.SetFilter("Period Start", GetFilter("Date Filter"));
                if not PeriodFormManagement.FindDate('+', Calendar, PeriodType) then
                    PeriodFormManagement.FindDate('+', Calendar, PeriodType::Day);
                Calendar.SetRange("Period Start");
            end;
            PeriodFormManagement.FindDate(SearchText, Calendar, PeriodType);
            SetRange("Date Filter", Calendar."Period Start", Calendar."Period End");
            if GetRangeMin("Date Filter") = GetRangeMax("Date Filter") then
                SetRange("Date Filter", GetRangeMin("Date Filter"));
        end;
    end;
}

