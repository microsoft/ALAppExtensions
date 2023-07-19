page 2624 "Stat. Account Balance Lines"
{
    Caption = 'Lines';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = ListPart;
    SaveValues = true;
    SourceTable = "Stat. Acc. Balance Buffer";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Period Start"; Rec."Period Start")
                {
                    ApplicationArea = All;
                    Caption = 'Period Start';
                    Editable = false;
                    ToolTip = 'Specifies the start date of the period defined on the line for the statistical account balance.';
                }
                field("Period Name"; Rec."Period Name")
                {
                    ApplicationArea = All;
                    Caption = 'Period Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the period shown in the line.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    AutoFormatType = 1;
                    BlankNumbers = BlankZero;
                    Caption = 'Amount';
                    DrillDown = true;
                    Editable = false;
                    ToolTip = 'Specifies the amount for the period on the line.';

                    trigger OnDrillDown()
                    begin
                        BalanceDrillDown();
                    end;
                }
                field(NetChange; Rec."Net Change")
                {
                    ApplicationArea = All;
                    AutoFormatType = 1;
                    BlankZero = true;
                    Caption = 'Net Change';
                    DrillDown = true;
                    Editable = false;
                    ToolTip = 'Specifies changes in the actual general ledger amount.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        BalanceDrillDown();
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        if DateRec.Get(Rec."Period Type", Rec."Period Start") then;
        CalcLine();
    end;

    trigger OnFindRecord(Which: Text) FoundDate: Boolean
    var
        VariantRec: Variant;
    begin
        VariantRec := Rec;
#pragma warning disable AA0139        
        FoundDate := PeriodFormLinesMgt.FindDate(VariantRec, DateRec, Which, PeriodType.AsInteger());
#pragma warning restore AA0139        

        Rec := VariantRec;
    end;

    trigger OnNextRecord(Steps: Integer) ResultSteps: Integer
    var
        VariantRec: Variant;
    begin
        VariantRec := Rec;
        ResultSteps := PeriodFormLinesMgt.NextDate(VariantRec, DateRec, Steps, PeriodType.AsInteger());
        Rec := VariantRec;
    end;

    var
        AccountingPeriod: Record "Accounting Period";
        DateRec: Record Date;
        PeriodFormLinesMgt: Codeunit "Period Form Lines Mgt.";
        PeriodType: Enum "Analysis Period Type";
        AmountType: Enum "Analysis Amount Type";

    protected var
        StatisticalAccount: Record "Statistical Account";
        ClosingEntryFilter: Option Include,Exclude;

    internal procedure SetLines(var NewStatisticalAccount: Record "Statistical Account"; NewPeriodType: Enum "Analysis Period Type"; NewAmountType: Enum "Analysis Amount Type"; NewClosingEntryFilter: Option Include,Exclude)
    begin
        StatisticalAccount.Copy(NewStatisticalAccount);
        Rec.DeleteAll();
        PeriodType := NewPeriodType;
        AmountType := NewAmountType;
        ClosingEntryFilter := NewClosingEntryFilter;
        CurrPage.Update(false);
    end;

    local procedure BalanceDrillDown()
    var
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if IsHandled then
            exit;

        SetDateFilter();
        StatisticalLedgerEntry.Reset();
        StatisticalLedgerEntry.SetCurrentKey("Statistical Account No.", "Posting Date");
        StatisticalLedgerEntry.SetRange("Statistical Account No.", StatisticalAccount."No.");

        StatisticalLedgerEntry.SetFilter("Posting Date", StatisticalAccount.GetFilter("Date Filter"));
        StatisticalLedgerEntry.SetFilter("Global Dimension 1 Code", StatisticalAccount.GetFilter("Global Dimension 1 Filter"));
        StatisticalLedgerEntry.SetFilter("Global Dimension 2 Code", StatisticalAccount.GetFilter("Global Dimension 2 Filter"));
        PAGE.Run(Page::"Statistical Ledger Entry List", StatisticalLedgerEntry);
    end;

    local procedure SetDateFilter()
    begin
        if AmountType = AmountType::"Net Change" then
            StatisticalAccount.SetRange("Date Filter", Rec."Period Start", Rec."Period End")
        else
            StatisticalAccount.SetRange("Date Filter", 0D, Rec."Period End");
        if ClosingEntryFilter = ClosingEntryFilter::Exclude then begin
            AccountingPeriod.SetCurrentKey("New Fiscal Year");
            AccountingPeriod.SetRange("New Fiscal Year", true);
            if StatisticalAccount.GetRangeMin("Date Filter") = 0D then
                AccountingPeriod.SetRange("Starting Date", 0D, StatisticalAccount.GetRangeMax("Date Filter"))
            else
                AccountingPeriod.SetRange(
                  "Starting Date",
                  StatisticalAccount.GetRangeMin("Date Filter") + 1,
                  StatisticalAccount.GetRangeMax("Date Filter"));
            if AccountingPeriod.Find('-') then
                repeat
                    StatisticalAccount.SetFilter(
                      "Date Filter", StatisticalAccount.GetFilter("Date Filter") + '&<>%1',
                      ClosingDate(AccountingPeriod."Starting Date" - 1));
                until AccountingPeriod.Next() = 0;
        end else
            StatisticalAccount.SetRange(
              "Date Filter",
              StatisticalAccount.GetRangeMin("Date Filter"),
              ClosingDate(StatisticalAccount.GetRangeMax("Date Filter")));
    end;

    local procedure CalcLine()
    begin
        SetDateFilter();
        case AmountType of
            AmountType::"Net Change":
                begin
                    StatisticalAccount.CalcFields("Net Change");
                    Rec.Amount := StatisticalAccount."Net Change";
                end;
            AmountType::"Balance at Date":
                begin
                    StatisticalAccount.CalcFields(Balance);
                    Rec.Amount := StatisticalAccount.Balance;
                end;
        end;
    end;

    trigger OnOpenPage()
    begin
        Rec.Reset();
    end;
}
