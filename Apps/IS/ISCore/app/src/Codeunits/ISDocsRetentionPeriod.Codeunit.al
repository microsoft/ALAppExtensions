namespace Microsoft.Finance;
using Microsoft.Foundation.Period;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 14606 "IS Docs Retention Period" implements "Documents - Retention Period"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetDeletionBlockedAfterDate(): Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        exit(CalcDate('<-7Y-1D>', AccountingPeriod.GetFiscalYearStartDate(Today)));
    end;

    procedure GetDeletionBlockedBeforeDate(): Date
    begin
        exit(0D);
    end;

    procedure IsDocumentDeletionAllowedByLaw(PostingDate: Date): Boolean
    var
    begin
        if (PostingDate > GetDeletionBlockedAfterDate()) and (PostingDate < GetDeletionBlockedBeforeDate()) then
            exit(true);
        exit(false);
    end;

    procedure CheckDocumentDeletionAllowedByLaw(PostingDate: Date)
    var
        BlockedDeletionAfterDate: Date;
        BlockedDeletionBeforeDate: Date;
    begin
        BlockedDeletionAfterDate := GetDeletionBlockedAfterDate();
        BlockedDeletionBeforeDate := GetDeletionBlockedBeforeDate();
        if (PostingDate > BlockedDeletionAfterDate) or (PostingDate < BlockedDeletionBeforeDate) then
            Error(PostingDateWithinLegalPeriodErr, Format(BlockedDeletionAfterDate));
    end;

    var
        PostingDateWithinLegalPeriodErr: Label 'The posted document cannot be deleted. Deleting is only permitted for documents whose Posting Date is before %1.', Comment = '%1 = Posting Date.';
}