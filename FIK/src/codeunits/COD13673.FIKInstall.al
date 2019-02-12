// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13673 "FIK Install"
{
    Subtype = install;

    trigger OnInstallAppPerCompany()
    begin
        CompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Vendor: Record Vendor;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchaseHeader: Record "Purchase Header";
        GenJournalLine: Record "Gen. Journal Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        PurchInvHeader: Record "Purch. Inv. Header";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        PaymentMethod: Record "Payment Method";
        PaymentBuffer: Record "Payment Buffer";
        PaymentExportData: Record "Payment Export Data";
        BankStatementMatchingBuffer: Record "Bank Statement Matching Buffer";
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetFieldToNormal(Database::Vendor, Vendor.FieldNo(GiroAccNo));

        DataClassificationMgt.SetFieldToNormal(Database::"Vendor Ledger Entry", VendorLedgerEntry.FieldNo(GiroAccNo));

        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo(GiroAccNo));

        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo(GiroAccNo));

        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("FIK Import Format"));

        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Header", PurchInvHeader.FieldNo(GiroAccNo));

        DataClassificationMgt.SetFieldToNormal(Database::"Bank Acc. Reconciliation", BankAccReconciliation.FieldNo(FIKPaymentReconciliation));

        DataClassificationMgt.SetFieldToNormal(Database::"Bank Acc. Reconciliation Line", BankAccReconciliationLine.FieldNo(PaymentReference));

        DataClassificationMgt.SetFieldToNormal(Database::"Payment Method", PaymentMethod.FieldNo(PaymentTypeValidation));

        DataClassificationMgt.SetFieldToNormal(Database::"Payment Buffer", PaymentBuffer.FieldNo(GiroAccNo));

        DataClassificationMgt.SetFieldToNormal(Database::"Payment Export Data", PaymentExportData.FieldNo(RecipientGiroAccNo));

        DataClassificationMgt.SetFieldToNormal(Database::"Bank Statement Matching Buffer", BankStatementMatchingBuffer.FieldNo(MatchStatus));
        DataClassificationMgt.SetFieldToNormal(Database::"Bank Statement Matching Buffer", BankStatementMatchingBuffer.FieldNo(DescriptionBankStatment));
    end;

}