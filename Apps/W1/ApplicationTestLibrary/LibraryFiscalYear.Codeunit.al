/// <summary>
/// Provides utility functions for creating, managing, and closing fiscal years in test scenarios.
/// </summary>
codeunit 131302 "Library - Fiscal Year"
{

    trigger OnRun()
    begin
    end;

    procedure CloseFiscalYear()
    var
        AccountingPeriod: Record "Accounting Period";
        Counter: Integer;
    begin
        // Close All opened Fiscal Years.
        AccountingPeriod.SetRange("New Fiscal Year", true);
        AccountingPeriod.SetRange(Closed, false);
        for Counter := 1 to AccountingPeriod.Count - 1 do begin
            CODEUNIT.Run(CODEUNIT::"Fiscal Year-Close", AccountingPeriod);
            if Counter < AccountingPeriod.Count then
                AccountingPeriod.Next();
        end;
        Commit();  // Required because Modal Page Pops Up.
    end;

    procedure CloseAccountingPeriod()
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        AccountingPeriod.SetRange(Closed, false);
        AccountingPeriod.ModifyAll(Closed, true);
    end;

    procedure CreateFiscalYear()
    var
        Date: Record Date;
        CreateFiscalYear: Report "Create Fiscal Year";
        PeriodLength: DateFormula;
    begin
        // Find a Date to create a new Fiscal Year if no Fiscal Year exists in Demo Data.
        Date.SetRange("Period Type", Date."Period Type"::Year);
        Date.SetRange("Period No.", Date2DMY(WorkDate(), 3));
        Date.FindFirst();

        // Create a new Fiscal Year With Number of Periods = 12, Period Length = 1M.
        Clear(CreateFiscalYear);
        Evaluate(PeriodLength, '<1M>');
        CreateFiscalYear.InitializeRequest(12, PeriodLength, Date."Period Start");
        CreateFiscalYear.UseRequestPage(false);
        CreateFiscalYear.HideConfirmationDialog(true);
        CreateFiscalYear.Run();
    end;

    procedure CheckPostingDate(PostingDate: Date)
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        // Check if Posting Date is outside the Accounting Period then Create New Fiscal Year and close it.
        AccountingPeriod.FindLast();
        if PostingDate > AccountingPeriod."Starting Date" then begin
            CreateFiscalYear();
            CloseFiscalYear();
        end;
    end;

    procedure GetFirstPostingDate(Closed: Boolean): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        AccountingPeriod.SetRange(Closed, Closed);
        AccountingPeriod.FindFirst();
        exit(AccountingPeriod."Starting Date");
    end;

    procedure GetLastPostingDate(Closed: Boolean): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        AccountingPeriod.SetRange(Closed, Closed);
        AccountingPeriod.FindLast();
        exit(AccountingPeriod."Starting Date");
    end;

    procedure GetStatisticsPeriod(): Text
    begin
        exit('<Year><Month,2>');
    end;

    procedure GetAccountingPeriodDate(PostingDate: Date): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        AccountingPeriod.SetRange("Starting Date", 0D, PostingDate);
        AccountingPeriod.FindLast();
        exit(AccountingPeriod."Starting Date");
    end;

    [Scope('OnPrem')]
    procedure GetPastNewYearDate(NumberOfPastYears: Integer): Date
    begin
        exit(CalcDate(StrSubstNo('<-%1Y-CY>', NumberOfPastYears), WorkDate()));
    end;

    [Scope('OnPrem')]
    procedure UpdateAllowGAccDeletionBeforeDateOnGLSetup(NewDate: Date)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Allow G/L Acc. Deletion Before" := NewDate;
        GeneralLedgerSetup.Modify();
    end;

    procedure IdentifyOpenAccountingPeriod(): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        Clear(AccountingPeriod);
        CloseAccountingPeriod();
        AccountingPeriod.Init();
        AccountingPeriod.Validate("Starting Date", CalcDate('<+1M>', GetLastPostingDate(true)));
        AccountingPeriod.Insert(true);
        exit(AccountingPeriod."Starting Date");
    end;

    procedure GetInitialPostingDate(): Date
    begin
        exit(GetFirstPostingDate(true));
    end;

    procedure FindAccountingPeriodStartEndDate(var StartDate: Date; var EndDate: Date; NumberOfPeriods: Integer)
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        AccountingPeriod.FindSet();
        StartDate := AccountingPeriod."Starting Date";
        AccountingPeriod.Next(NumberOfPeriods);
        EndDate := AccountingPeriod."Starting Date" - 1;
    end;

    procedure AccountingPeriodsExists(): Boolean
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        exit(not AccountingPeriod.IsEmpty);
    end;

    procedure CreateClosedAccountingPeriods()
    var
        AccountingPeriod: Record "Accounting Period";
        GLEntry: Record "G/L Entry";
        CreateFiscalYear: Report "Create Fiscal Year";
        Period: DateFormula;
        i, j : integer;
    begin
        AccountingPeriod.DeleteAll();
        Evaluate(Period, '<1M>');

        GLEntry.SetCurrentKey("Posting Date");
        GLEntry.SetAscending("Posting Date", true);
        if GLEntry.FindFirst() then;
        j := ((Date2DMY(Today(), 3) - Date2DMY(GLEntry."Posting Date", 3))) + 3;
        if j < 10 then
            j := 10;

        for i := j downto 0 do begin
            CreateFiscalYear.UseRequestPage(false);
            CreateFiscalYear.InitializeRequest(12, Period, DMY2Date(1, 1, Date2DMY(Today, 3) + 3 - i));
            CreateFiscalYear.HideConfirmationDialog(true);
            CreateFiscalYear.Run();
            clear(CreateFiscalYear);

            AccountingPeriod.ModifyAll(Closed, true);
            AccountingPeriod.ModifyAll("Date Locked", true);
        end;
    end;
}

