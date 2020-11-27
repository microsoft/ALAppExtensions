report 11712 "General Ledger CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/GeneralLedger.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'General Ledger';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = sorting("No.") WHERE("Account Type" = FILTER(Posting));
            RequestFilterFields = "No.", "Date Filter";
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(STRSUBSTNO___1__2__gtcPeriod_gtePeriodText_; StrSubstNo(PeriodLbl, PeriodText))
            {
            }
            column(gteTableFilter; TableFilter)
            {
            }
            column(gcoAccountFilter; AccountFilter)
            {
            }
            column(gdeStartDebit; StartDebit)
            {
            }
            column(gdeStartCredit; StartCredit)
            {
            }
            column(STRSUBSTNO_gtcStartBalance__FORMAT_gdaStartDate__; StrSubstNo(StartBalanceLbl, Format(StartDate)))
            {
            }
            column(gdeStartDebit___gdeStartCredit; StartDebit - StartCredit)
            {
            }
            column(gteGLAccDescr; GLAccDescr)
            {
            }
            column(General_LedgerCaption; General_LedgerCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(gcoAccountFilterCaption; AccountFilterCaptionLbl)
            {
            }
            column(G_L_Entry__Posting_Date_Caption; "G/L Entry".FieldCaption("Posting Date"))
            {
            }
            column(G_L_Entry__Document_No__Caption; "G/L Entry".FieldCaption("Document No."))
            {
            }
            column(G_L_Entry_DescriptionCaption; "G/L Entry".FieldCaption(Description))
            {
            }
            column(G_L_Entry__Debit_Amount_Caption; "G/L Entry".FieldCaption("Debit Amount"))
            {
            }
            column(G_L_Entry__Credit_Amount_Caption; "G/L Entry".FieldCaption("Credit Amount"))
            {
            }
            column(BalanceCaption; BalanceCaptionLbl)
            {
            }
            column(G_L_Account_No_; "No.")
            {
            }
            column(gboPrint; Print)
            {
            }
            column(gboSums; Sums)
            {
            }
            column(gboEntries; Entries)
            {
            }
            dataitem("Accounting Period"; "Accounting Period")
            {
                DataItemTableView = sorting("Starting Date");
                column(Accounting_Period_Starting_Date; "Starting Date")
                {
                }
                column(gdaStartDate; StartDate)
                {
                }
                column(gdaEndDate; EndDate)
                {
                }
                dataitem(GlAccount2; "G/L Account")
                {
                    DataItemTableView = sorting("No.") WHERE("Account Type" = CONST(Posting));
                    column(GlAccount2_No_; "No.")
                    {
                    }
                    dataitem("G/L Entry"; "G/L Entry")
                    {
                        DataItemLink = "G/L Account No." = field("No.");
                        DataItemTableView = sorting("G/L Account No.", "Posting Date");
                        column(G_L_Entry__G_L_Account_No__; "G/L Account No.")
                        {
                        }
                        column(G_L_Entry__Posting_Date_; Format("Posting Date", 0, DateFormatTxt))
                        {
                        }
                        column(G_L_Entry__Document_No__; "Document No.")
                        {
                        }
                        column(G_L_Entry_Description; Description)
                        {
                        }
                        column(G_L_Entry__Debit_Amount_; "Debit Amount")
                        {
                        }
                        column(G_L_Entry__Credit_Amount_; "Credit Amount")
                        {
                        }
                        column(G_L_Entry_Amount; Amount)
                        {
                        }
                        column(G_L_Entry_Entry_No_; "Entry No.")
                        {
                        }
                        trigger OnAfterGetRecord()
                        begin
                            if Sums then begin
                                NetChangePerDebit += "Debit Amount";
                                NetChangePerCredit += "Credit Amount";
                                EndPerDebit += "Debit Amount";
                                EndPerCredit += "Credit Amount";
                            end;
                        end;

                        trigger OnPreDataItem()
                        begin
                            SetRange("Posting Date", StartPeriod, EndPeriod);
                            SetFilter("Global Dimension 1 Code", "G/L Account".GetFilter("Global Dimension 1 Filter"));
                            SetFilter("Global Dimension 2 Code", "G/L Account".GetFilter("Global Dimension 2 Filter"));
                            SetFilter("Business Unit Code", "G/L Account".GetFilter("Business Unit Filter"));
                            SetRange("Entry No.", 1, LastEntryNo);
                        end;
                    }
                    trigger OnPreDataItem()
                    begin
                        if Level = 0 then
                            SetRange("No.", AccountFilter)
                        else
                            SetFilter("No.", StrSubstNo(TwoPlaceholdersTok, AccountFilter, '*'));
                    end;
                }
                dataitem(TotalPer; "Integer")
                {
                    DataItemTableView = sorting(Number) WHERE(Number = CONST(1));
                    column(STRSUBSTNO_gtcNetChange_gdaStartPeriod_gdaEndPeriod_; StrSubstNo(NetChangeLbl, StartPeriod, EndPeriod))
                    {
                    }
                    column(gdeNetChangePerDebit; NetChangePerDebit)
                    {
                    }
                    column(gdeNetChangePerCredit; NetChangePerCredit)
                    {
                    }
                    column(gdeNetChangePerDebit___gdeNetChangePerCredit; NetChangePerDebit - NetChangePerCredit)
                    {
                    }
                    column(gteGLAccDescr_Control1100162001; GLAccDescr)
                    {
                    }
                    column(STRSUBSTNO_gtcEndBalance_gdaEndPeriod_; StrSubstNo(EndBalanceLbl, EndPeriod))
                    {
                    }
                    column(gdeEndPerDebit; EndPerDebit)
                    {
                    }
                    column(gdeEndPerCredit; EndPerCredit)
                    {
                    }
                    column(gdeEndPerDebit___gdeEndPerCredit; EndPerDebit - EndPerCredit)
                    {
                    }
                    column(TotalPer_Number; Number)
                    {
                    }
                }
                trigger OnAfterGetRecord()
                begin
                    if Sums then begin
                        StartPeriod := AccPer."Starting Date";
                        if StartPeriod < StartDate then
                            StartPeriod := StartDate;
                        AccPer.Get("Starting Date");
                        if AccPer.Next() <> 0 then begin
                            EndPeriod := CalcDate('<-1D>', AccPer."Starting Date");
                            if EndPeriod > EndDate then
                                EndPeriod := EndDate;
                        end else
                            EndPeriod := EndDate;
                    end else begin
                        FindLast();
                        StartPeriod := StartDate;
                        EndPeriod := EndDate;
                    end;
                    NetChangePerDebit := 0;
                    NetChangePerCredit := 0;
                end;

                trigger OnPreDataItem()
                begin
                    if AccPer.Get(StartDate) then
                        SetRange("Starting Date", StartDate, EndDate)
                    else begin
                        AccPer.SetFilter("Starting Date", '..%1', StartDate);
                        if AccPer.FindLast() then
                            SetRange("Starting Date", AccPer."Starting Date", EndDate)
                        else
                            SetRange("Starting Date", StartDate, EndDate);
                    end;
                    AccPer.Reset();
                    EndPerDebit := StartDebit;
                    EndPerCredit := StartCredit;
                end;
            }
            dataitem(TotalAcc; "Integer")
            {
                DataItemTableView = sorting(Number) WHERE(Number = CONST(1));
                column(gdeEndDebit; EndDebit)
                {
                }
                column(gdeEndCredit; EndCredit)
                {
                }
                column(STRSUBSTNO_gtcEndBalance_gdaEndDate_; StrSubstNo(EndBalanceLbl, EndDate))
                {
                }
                column(gdeEndDebit___gdeEndCredit; EndDebit - EndCredit)
                {
                }
                column(gteGLAccDescr_Control1100162002; GLAccDescr)
                {
                }
                column(STRSUBSTNO_gtcNetChange_gdaStartDate_gdaEndDate_; StrSubstNo(NetChangeLbl, StartDate, EndDate))
                {
                }
                column(gdeNetChangeDebit; NetChangeDebit)
                {
                }
                column(gdeNetChangeCredit; NetChangeCredit)
                {
                }
                column(gdeNetChangeDebit___gdeNetChangeCredit; NetChangeDebit - NetChangeCredit)
                {
                }
                column(TotalAcc_Number; Number)
                {
                }
            }
            trigger OnAfterGetRecord()
            begin
                Print := true;
                if Level = 0 then begin
                    StartDebit := 0;
                    StartCredit := 0;
                    NetChangeDebit := 0;
                    NetChangeCredit := 0;
                    EndDebit := 0;
                    EndCredit := 0;
                    AccountFilter := "No.";
                    GLAccDescr := Name;
                    // Start Balance
                    // Income GLAccount Current Year
                    if IncomeInFY and ("G/L Account"."Income/Balance" = "G/L Account"."Income/Balance"::"Income Statement") then begin
                        SetFilter("Date Filter", '%1..%2', AccountingPeriodMgt.FindFiscalYear(StartDate), ClosingDate(StartDate - 1));
                        CalcFields("Net Change");
                        if "Net Change" > 0 then begin
                            StartDebit := "Net Change";
                            EndDebit := "Net Change";
                        end else begin
                            StartCredit := Abs("Net Change");
                            EndCredit := Abs("Net Change");
                        end;
                    end else begin
                        SetFilter("Date Filter", '..%1', ClosingDate(StartDate - 1));
                        CalcFields("Balance at Date");
                        if "Balance at Date" > 0 then begin
                            StartDebit := "Balance at Date";
                            EndDebit := "Balance at Date";
                        end else begin
                            StartCredit := Abs("Balance at Date");
                            EndCredit := Abs("Balance at Date");
                        end;
                    end;
                    // End Balance
                    SetFilter("Date Filter", '%1..%2', StartDate, EndDate);
                    CalcFields("Debit Amount", "Credit Amount");
                    NetChangeDebit := "Debit Amount";
                    NetChangeCredit := "Credit Amount";
                    EndDebit += "Debit Amount";
                    EndCredit += "Credit Amount";
                end else
                    if CopyStr("No.", 1, Level) = AccountFilter then
                        Print := false
                    else begin
                        AccountFilter := CopyStr(CopyStr("No.", 1, Level), 1, MaxStrLen(AccountFilter));
                        GLAccount.SetFilter("No.", StrSubstNo(TwoPlaceholdersTok, AccountFilter, '*'));
                        GLAccount.SetFilter("Account Type", '<>%1', GLAccount."Account Type"::Posting);
                        if GLAccount.FindFirst() then
                            GLAccDescr := GLAccount.Name
                        else
                            GLAccDescr := StrSubstNo(TwoPlaceholdersTok, AccountFilter, '*');
                        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
                        if GLAccount.FindSet() then begin
                            StartDebit := 0;
                            StartCredit := 0;
                            NetChangeDebit := 0;
                            NetChangeCredit := 0;
                            EndDebit := 0;
                            EndCredit := 0;
                            repeat
                                // Start Balance
                                // Income GLAccount Current Year;
                                if IncomeInFY and ("G/L Account"."Income/Balance" = "G/L Account"."Income/Balance"::"Income Statement") then begin
                                    GLAccount.SetFilter("Date Filter", '%1..%2', AccountingPeriodMgt.FindFiscalYear(StartDate),
                                      ClosingDate(StartDate - 1));
                                    GLAccount.CalcFields("Net Change");
                                    if GLAccount."Net Change" > 0 then begin
                                        StartDebit += GLAccount."Net Change";
                                        EndDebit += GLAccount."Net Change";
                                    end else begin
                                        StartCredit += Abs(GLAccount."Net Change");
                                        EndCredit += Abs(GLAccount."Net Change");
                                    end;
                                end else begin
                                    GLAccount.SetFilter("Date Filter", '..%1', ClosingDate(StartDate - 1));
                                    GLAccount.CalcFields("Balance at Date");
                                    if GLAccount."Balance at Date" > 0 then begin
                                        StartDebit += GLAccount."Balance at Date";
                                        EndDebit += GLAccount."Balance at Date";
                                    end else begin
                                        StartCredit += Abs(GLAccount."Balance at Date");
                                        EndCredit += Abs(GLAccount."Balance at Date");
                                    end;
                                end;
                                // End Balance
                                GLAccount.SetFilter("Date Filter", '%1..%2', StartDate, EndDate);
                                GLAccount.CalcFields("Debit Amount", "Credit Amount");
                                NetChangeDebit += GLAccount."Debit Amount";
                                NetChangeCredit += GLAccount."Credit Amount";
                                EndDebit += GLAccount."Debit Amount";
                                EndCredit += GLAccount."Credit Amount";
                            until GLAccount.Next() = 0;
                        end;
                    end;
                if (StartDebit = 0) and (StartCredit = 0) and (EndDebit = 0) and (EndCredit = 0) then
                    Print := false;

                if not Print then
                    CurrReport.Skip();
            end;

            trigger OnPreDataItem()
            var
                GLEntry: Record "G/L Entry";
            begin
                PeriodText := Format(StartDate) + '..' + Format(EndDate);
                LastEntryNo := GLEntry.GetLastEntryNo();
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(LevelField; Level)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Level';
                        ToolTip = 'Specifies the level on G/L account number';
                    }
                    field(SumsField; Sums)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sums per Period';
                        ToolTip = 'Specifies if the sums will be per period';
                    }
                    field(EntriesField; Entries)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print entries';
                        ToolTip = 'Specifies to indicate that detailed documents will print.';
                    }
                    field(IncomeInFYField; IncomeInFY)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Income Only In Current Year';
                        MultiLine = true;
                        ToolTip = 'Specifies if the income only has to be printed only in current year.';
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        TableFilter := "G/L Account".GetFilters;
        StartDate := "G/L Account".GetRangeMin("Date Filter");
        EndDate := "G/L Account".GetRangeMax("Date Filter");
    end;

    var
        AccPer: Record "Accounting Period";
        GLAccount: Record "G/L Account";
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
        AccountFilter: Code[20];
        TableFilter: Text;
        PeriodText: Text[30];
        GLAccDescr: Text[100];
        StartDebit: Decimal;
        StartCredit: Decimal;
        NetChangeDebit: Decimal;
        NetChangeCredit: Decimal;
        EndDebit: Decimal;
        EndCredit: Decimal;
        NetChangePerDebit: Decimal;
        NetChangePerCredit: Decimal;
        EndPerDebit: Decimal;
        EndPerCredit: Decimal;
        StartPeriod: Date;
        EndPeriod: Date;
        StartDate: Date;
        EndDate: Date;
        Level: Integer;
        LastEntryNo: Integer;
        Print: Boolean;
        Sums: Boolean;
        Entries: Boolean;
        IncomeInFY: Boolean;
        PeriodLbl: Label 'Period: %1', Comment = '%1 = PeriodText';
        StartBalanceLbl: Label 'Starting balance to %1', Comment = '%1 = Date of Start';
        EndBalanceLbl: Label 'Final balance to %1', Comment = '%1 = Date of End';
        NetChangeLbl: Label 'Net Change period %1..%2', Comment = '%1 = Date of Start; %2 = Date of eEd';
        General_LedgerCaptionLbl: Label 'General Ledger';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        AccountFilterCaptionLbl: Label 'Account No.';
        BalanceCaptionLbl: Label 'Balance';
        DateFormatTxt: Label '<Closing><Day,2>.<Month,2>.<Year4>', Comment = '<Closing><Day,2>.<Month,2>.<Year4>';
        TwoPlaceholdersTok: Label '%1%2', Locked = true;
}
