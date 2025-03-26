namespace Microsoft.eServices.EDocument;

using Microsoft.Purchases.Payables;
using app.app;
using System.Environment;

codeunit 6120 "E-Doc. Account Payable Cue"
{
    var
        DefaultWorkDate: Date;
        RefreshFrequencyErr: Label 'Refresh intervals of less than 10 minutes are not supported.';

    procedure CalcSalesThisMonthAmount(CalledFromWebService: Boolean; UseCachedValue: Boolean) TotalAmount: Decimal
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        AccountPayableCue: Record "E-Doc. Account Payable Cue";
        [SecurityFiltering(SecurityFilter::Filtered)]
        VendLedgerEntryPurchase: Query "E-Doc. Vend. Ledg. Ent. Purch.";
    begin
        // if UseCachedValue then
        //     if AccountPayableCue.Get() then
        //         if not IsPassedCueData(AccountPayableCue) then
        //             exit(AccountPayableCue."Purchase This Month");

        VendLedgerEntryPurchase.SetFilter(Document_Type, '%1|%2', VendorLedgerEntry."Document Type"::Invoice, VendorLedgerEntry."Document Type"::"Credit Memo");
        if CalledFromWebService then
            VendLedgerEntryPurchase.SetRange(Posting_Date, CalcDate('<-CM>', Today()), Today())
        else
            VendLedgerEntryPurchase.SetRange(Posting_Date, CalcDate('<-CM>', GetDefaultWorkDate()), GetDefaultWorkDate());
        VendLedgerEntryPurchase.Open();
        if VendLedgerEntryPurchase.Read() then
            TotalAmount := VendLedgerEntryPurchase.Sum_Purchase_LCY;
    end;

    local procedure GetDefaultWorkDate(): Date
    var
        LogInManagement: Codeunit LogInManagement;
    begin
        if DefaultWorkDate = 0D then
            DefaultWorkDate := LogInManagement.GetDefaultWorkDate();
        exit(DefaultWorkDate);
    end;

    procedure IsCueDataStale(): Boolean
    var
        AccountPayableCue: Record "E-Doc. Account Payable Cue";
    begin
        if not AccountPayableCue.Get() then
            exit(false);

        exit(IsPassedCueData(AccountPayableCue));
    end;

    local procedure IsPassedCueData(AccountPayableCue: Record "E-Doc. Account Payable Cue"): Boolean
    begin
        if AccountPayableCue."Last Date/Time Modified" = 0DT then
            exit(true);

        exit(CurrentDateTime() - AccountPayableCue."Last Date/Time Modified" >= GetActivitiesCueRefreshInterval())
    end;

    local procedure GetActivitiesCueRefreshInterval() Interval: Duration
    var
        MinInterval: Duration;
    begin
        MinInterval := 10 * 60 * 1000; // 10 minutes
        Interval := 60 * 60 * 1000; // 1 hr
        if Interval < MinInterval then
            Error(RefreshFrequencyErr);
    end;
}
