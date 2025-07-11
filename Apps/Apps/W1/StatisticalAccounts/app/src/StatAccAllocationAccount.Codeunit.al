namespace Microsoft.Finance.Analysis.StatisticalAccount;

using Microsoft.Finance.AllocationAccount;

codeunit 2632 "Stat. Acc. Allocation Account"
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"Alloc. Account Distribution", 'OnLookupBreakdownAccountNumber', '', false, false)]
    local procedure HandleLookupBreakdownAccountNumber(var AllocAccountDistribution: Record "Alloc. Account Distribution"; var Handled: Boolean)
    var
        StatisticalAccount: Record "Statistical Account";
        StatisticalAccountList: Page "Statistical Account List";
    begin
        if Handled then
            exit;

        if AllocAccountDistribution."Breakdown Account Type" <> AllocAccountDistribution."Breakdown Account Type"::"Statistical Account" then
            exit;

        Handled := true;

        StatisticalAccountList.LookupMode(true);
        if StatisticalAccountList.RunModal() = ACTION::LookupOK then begin
            StatisticalAccountList.GetRecord(StatisticalAccount);
            AllocAccountDistribution.Validate("Breakdown Account Number", StatisticalAccount."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Alloc. Account Distribution", 'OnLookupBreakdownAccountName', '', false, false)]
    local procedure HandleLookupBreakdownAccountName(var AllocAccountDistribution: Record "Alloc. Account Distribution"; var AccountName: Text[2048]; var Handled: Boolean)
    var
        StatisticalAccount: Record "Statistical Account";
    begin
        if Handled then
            exit;

        if AllocAccountDistribution."Breakdown Account Type" <> AllocAccountDistribution."Breakdown Account Type"::"Statistical Account" then
            exit;

        Handled := true;

        if StatisticalAccount.Get(AllocAccountDistribution."Breakdown Account Number") then;
        AccountName := StatisticalAccount.Name;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Variable Allocation Mgt.", 'OnGetAccountBalance', '', false, false)]
    local procedure HandleGetAccountBalance(var AllocAccountDistribution: Record "Alloc. Account Distribution"; StartDate: Date; EndDate: Date; var AccountBalance: Decimal; var ShareDistributions: Dictionary of [Guid, Decimal]; var TotalBalance: Decimal; var Handled: Boolean)
    var
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
    begin
        if Handled then
            exit;

        if AllocAccountDistribution."Breakdown Account Type" <> AllocAccountDistribution."Breakdown Account Type"::"Statistical Account" then
            exit;

        Handled := true;
        StatisticalLedgerEntry.SetRange("Posting Date", StartDate, EndDate);
        StatisticalLedgerEntry.SetRange("Statistical Account No.", AllocAccountDistribution."Breakdown Account Number");
        if AllocAccountDistribution."Dimension 1 Filter" <> '' then
            StatisticalLedgerEntry.SetRange("Global Dimension 1 Code", AllocAccountDistribution."Dimension 1 Filter");

        if AllocAccountDistribution."Dimension 2 Filter" <> '' then
            StatisticalLedgerEntry.SetRange("Global Dimension 2 Code", AllocAccountDistribution."Dimension 2 Filter");

        if AllocAccountDistribution."Dimension 3 Filter" <> '' then
            StatisticalLedgerEntry.SetRange("Shortcut Dimension 3 Code", AllocAccountDistribution."Dimension 3 Filter");

        if AllocAccountDistribution."Dimension 4 Filter" <> '' then
            StatisticalLedgerEntry.SetRange("Shortcut Dimension 4 Code", AllocAccountDistribution."Dimension 4 Filter");

        if AllocAccountDistribution."Dimension 5 Filter" <> '' then
            StatisticalLedgerEntry.SetRange("Shortcut Dimension 5 Code", AllocAccountDistribution."Dimension 5 Filter");

        if AllocAccountDistribution."Dimension 6 Filter" <> '' then
            StatisticalLedgerEntry.SetRange("Shortcut Dimension 6 Code", AllocAccountDistribution."Dimension 6 Filter");

        if AllocAccountDistribution."Dimension 7 Filter" <> '' then
            StatisticalLedgerEntry.SetRange("Shortcut Dimension 7 Code", AllocAccountDistribution."Dimension 7 Filter");

        if AllocAccountDistribution."Dimension 8 Filter" <> '' then
            StatisticalLedgerEntry.SetRange("Shortcut Dimension 8 Code", AllocAccountDistribution."Dimension 8 Filter");

        StatisticalLedgerEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        StatisticalLedgerEntry.CalcSums(Amount);
        AccountBalance := StatisticalLedgerEntry.Amount;
    end;
}