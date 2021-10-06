codeunit 31278 "Release Compens. Document CZC"
{
    TableNo = "Compensation Header CZC";

    trigger OnRun()
    begin
        CompensationHeaderCZC.Copy(Rec);
        Code();
        Rec := CompensationHeaderCZC;
    end;

    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        CompensationsSetupCZC: Record "Compensations Setup CZC";
        MustBeLessOrEqualErr: Label '%1 must be less or equal to %2.', Comment = '%1 = Compensation Balance (LCY) FieldCaption, %2 = Max. Rounding Amount FieldCaption';
#if not CLEAN19
        UseChangedLedgerEntryQst: Label '%1 %2 %3 is already used. Do you want to use it for Compensation?', Comment = '%1 = Customer/Vendor LE TableCaption, %2 = Entry No. FieldCption, %3 = Entry No.';
#endif
        CurrencyFactorErr: Label 'All lines with currency %1 must have the same currency factor.', Comment = '%1 = Currency Code';
        ApprovalProcessReleaseErr: Label 'This document can only be released when the approval process is complete.';
        ApprovalProcessReopenErr: Label 'The approval process must be cancelled or completed to reopen this document.';

    local procedure Code()
    begin
        if CompensationHeaderCZC.Status = CompensationHeaderCZC.Status::Released then
            exit;

        OnBeforeReleaseCompensationCZC(CompensationHeaderCZC);
        CompensationHeaderCZC.CheckCompensationReleaseRestrictions();
        CheckCompensationBalance(CompensationHeaderCZC);
        CheckCompensationLines(CompensationHeaderCZC);

        CompensationHeaderCZC.TestField(CompensationHeaderCZC."Company No.");
        CompensationHeaderCZC.TestField(CompensationHeaderCZC."Posting Date");
        CompensationHeaderCZC.Status := CompensationHeaderCZC.Status::Released;
        CompensationHeaderCZC.Modify();

        OnAfterReleaseCompensationCZC(CompensationHeaderCZC);
    end;

    procedure Reopen(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        OnBeforeReopenCompensationCZC(CompensationHeaderCZC);

        if CompensationHeaderCZC.Status = CompensationHeaderCZC.Status::Open then
            exit;
        CompensationHeaderCZC.Status := CompensationHeaderCZC.Status::Open;
        CompensationHeaderCZC.Modify(true);

        OnAfterReopenCompensationCZC(CompensationHeaderCZC);
    end;

    procedure PerformManualRelease(var CompensationHeaderCZC: Record "Compensation Header CZC")
    var
        CompensationApprovMgtCZC: Codeunit "Compensation Approv. Mgt. CZC";
    begin
        if CompensationApprovMgtCZC.IsCompensationApprovalsWorkflowEnabled(CompensationHeaderCZC) and
           (CompensationHeaderCZC.Status = CompensationHeaderCZC.Status::Open)
        then
            Error(ApprovalProcessReleaseErr);

        Codeunit.Run(Codeunit::"Release Compens. Document CZC", CompensationHeaderCZC);
    end;

    procedure PerformManualReopen(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        if CompensationHeaderCZC.Status = CompensationHeaderCZC.Status::"Pending Approval" then
            Error(ApprovalProcessReopenErr);

        Reopen(CompensationHeaderCZC);
    end;

    local procedure CheckCompensationBalance(CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        CompensationsSetupCZC.Get();
        CompensationHeaderCZC.CalcFields(CompensationHeaderCZC."Compensation Balance (LCY)");
        if Abs(CompensationHeaderCZC."Compensation Balance (LCY)") > CompensationsSetupCZC."Max. Rounding Amount" then
            Error(MustBeLessOrEqualErr, CompensationHeaderCZC.FieldCaption(CompensationHeaderCZC."Compensation Balance (LCY)"), CompensationsSetupCZC.FieldCaption("Max. Rounding Amount"));
    end;

    local procedure CheckCompensationLines(CompensationHeaderCZC: Record "Compensation Header CZC")
    var
        CompensationLineCZC: Record "Compensation Line CZC";
        CurrencyCompensationLineCZC: Record "Compensation Line CZC";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CurrencyFactor: Decimal;
    begin
        CompensationLineCZC.SetRange(CompensationLineCZC."Compensation No.", CompensationHeaderCZC."No.");
        if CompensationLineCZC.FindSet() then
            repeat
                CompensationLineCZC.CheckPostingDate();
                case CompensationLineCZC."Source Type" of
                    CompensationLineCZC."Source Type"::Customer:
                        if CompensationLineCZC."Source Entry No." <> 0 then begin
                            CustLedgerEntry.Get(CompensationLineCZC."Source Entry No.");
                            CustLedgerEntry.TestField(Prepayment, false);
#if not CLEAN19
#pragma warning disable AL0432
                            CustLedgerEntry.TestField("Prepayment Type", CustLedgerEntry."Prepayment Type"::" ");
                            CustLedgerEntry.CalcFields("Amount on Payment Order (LCY)");
                            if CustLedgerEntry."Amount on Payment Order (LCY)" <> 0 then
                                if not Confirm(UseChangedLedgerEntryQst, false,
                                     CustLedgerEntry.TableCaption, CustLedgerEntry.FieldCaption("Entry No."), CustLedgerEntry."Entry No.")
                                then
                                    CustLedgerEntry.TestField("Amount on Payment Order (LCY)", 0);
#pragma warning restore AL0432
#endif
                        end;
                    CompensationLineCZC."Source Type"::Vendor:
                        if CompensationLineCZC."Source Entry No." <> 0 then begin
                            VendorLedgerEntry.Get(CompensationLineCZC."Source Entry No.");
                            VendorLedgerEntry.TestField(Prepayment, false);
#if not CLEAN19
#pragma warning disable AL0432
                            VendorLedgerEntry.TestField("Prepayment Type", VendorLedgerEntry."Prepayment Type"::" ");
                            VendorLedgerEntry.CalcFields("Amount on Payment Order (LCY)");
                            if VendorLedgerEntry."Amount on Payment Order (LCY)" <> 0 then
                                if not Confirm(UseChangedLedgerEntryQst, false,
                                     VendorLedgerEntry.TableCaption, VendorLedgerEntry.FieldCaption("Entry No."), VendorLedgerEntry."Entry No.")
                                then
                                    VendorLedgerEntry.TestField("Amount on Payment Order (LCY)", 0);
#pragma warning restore AL0432
#endif
                        end;
                end;
            until CompensationLineCZC.Next() = 0;

        CompensationLineCZC.SetFilter(CompensationLineCZC."Currency Code", '<>%1', '');
        if CompensationLineCZC.FindSet() then
            repeat
                CurrencyCompensationLineCZC.SetRange("Compensation No.", CompensationHeaderCZC."No.");
                CurrencyCompensationLineCZC.SetRange("Currency Code", CompensationLineCZC."Currency Code");
                CurrencyCompensationLineCZC.FindSet();
                CurrencyFactor := CurrencyCompensationLineCZC."Currency Factor";
                while CurrencyCompensationLineCZC.Next() <> 0 do
                    if CurrencyCompensationLineCZC."Currency Factor" <> CurrencyFactor then
                        Error(CurrencyFactorErr, CurrencyCompensationLineCZC."Currency Code");
            until CompensationLineCZC.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleaseCompensationCZC(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReleaseCompensationCZC(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReopenCompensationCZC(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReopenCompensationCZC(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
    end;
}
