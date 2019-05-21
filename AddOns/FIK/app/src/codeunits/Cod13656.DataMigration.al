// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13656 "FIK Data Migration"
{
    trigger OnRun();
    begin
        // Check
        if not CheckUpgradeConditions() then
            exit;

        // Move
        Upgrade();
    end;

    local procedure CheckUpgradeConditions(): Boolean;
    var
        EnvironmentInfo: Codeunit 457;
    begin
        // Check if SAAS
        if EnvironmentInfo.IsSaaS() then
            exit(false);

        // Check if extension was uplifted
        exit(not IsExtensionUplifted());
    end;

    local procedure IsExtensionUplifted(): Boolean;
    var
        FIKUplift: Record FIKUplift;
    begin
        if not FIKUplift.Get() then begin
            FIKUplift.Init();
            FIKUplift.IsUpgraded := True;
            FIKUplift.Insert();
            exit(false);
        end;

        if not FIKUplift.IsUpgraded then begin
            FIKUplift.IsUpgraded := true;
            FIKUplift.Modify();
            exit(false);
        end;
        exit(true);
    end;

    local procedure Upgrade();
    begin
        MigrateVendorFields();
        MigrateVendorLedgerEntryFields();
        MigratePurchaseHeaderFields();
        MigrateCompanyInformationFields();
        MigrateGeneralJournalLineFields();
        MigratePurchaseInvoiceHeaderFields();
        MigrateBankAccReconcilationFields();
        MigrateBankAccRecLineFields();
        MigratePaymentMethodFields();
        MigratePaymentExportDataFields();
    end;

    local procedure MigrateVendorFields();
    var
        Vendor: Record Vendor;
        AllObj: Record AllObj;
        UPGVendor: recordref;
    begin
        ;
        if AllObj.GET(AllObj."Object Type"::Table, 104038) then begin
            UPGVendor.Open(104038);
            If UPGVendor.FindSet() then
                repeat
                    if Vendor.Get(UPGVendor.Field(1)) then begin
                        Vendor.Validate(GiroAccNo, UPGVendor.Field(13650).Value());
                        vendor.Modify(true);
                    end;
                until UPGVendor.Next() = 0;
        end;

    end;

    local procedure MigrateVendorLedgerEntryFields();
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        AllObj: Record AllObj;
        UpgVendorLedgerEntry: RecordRef;
    begin
        if AllObj.GET(AllObj."Object Type"::Table, 104039) then begin
            UpgVendorLedgerEntry.Open(104039);
            If UpgVendorLedgerEntry.FindSet() then
                repeat
                    if VendorLedgerEntry.Get(UpgVendorLedgerEntry.Field(1)) then begin
                        VendorLedgerEntry.Validate(GiroAccNo, UpgVendorLedgerEntry.Field(13650).Value());
                        VendorLedgerEntry.Modify(true);
                    end;
                until UpgVendorLedgerEntry.Next() = 0;
        end;
    end;

    local procedure MigratePurchaseHeaderFields();
    var
        PurchaseHeader: Record "Purchase Header";
        AllObj: Record AllObj;
        UPGPurchaseHeader: RecordRef;
    begin
        if AllObj.GET(AllObj."Object Type"::Table, 104040) then begin
            UPGPurchaseHeader.Open(104040);
            If UPGPurchaseHeader.FindSet() then
                repeat
                    if PurchaseHeader.Get(UPGPurchaseHeader.Field(1), UPGPurchaseHeader.Field(3)) then begin
                        PurchaseHeader.Validate(GiroAccNo, UPGPurchaseHeader.Field(13650).Value());
                        PurchaseHeader.Modify(true);
                    end;
                until UPGPurchaseHeader.Next() = 0;
        end;
    end;

    local procedure MigrateCompanyInformationFields();
    var
        CompanyInformation: Record "Company Information";
        AllObj: Record AllObj;
        UPGCompanyInformaiton: RecordRef;
    begin
        if AllObj.GET(AllObj."Object Type"::Table, 104079) then begin
            UPGCompanyInformaiton.Open(104079);
            if UPGCompanyInformaiton.FindSet() then
                repeat
                    if CompanyInformation.Get(UPGCompanyInformaiton.Field(1)) then begin
                        CompanyInformation.Validate(BankCreditorNo, UPGCompanyInformaiton.Field(13600).Value());
                        CompanyInformation.Modify(true);
                    end;
                until UPGCompanyInformaiton.Next() = 0;
        end;
    end;

    local procedure MigrateGeneralJournalLineFields();
    var
        GeneralJournalLine: Record "Gen. Journal Line";
        AllObj: Record AllObj;
        UPGGeneralJournalLine: RecordRef;
    begin
        if AllObj.GET(AllObj."Object Type"::Table, 104042) then begin
            UPGGeneralJournalLine.Open(104042);
            If UPGGeneralJournalLine.FindSet() then
                repeat
                    if GeneralJournalLine.Get(UPGGeneralJournalLine.Field(1), UPGGeneralJournalLine.Field(51), UPGGeneralJournalLine.Field(2)) then begin
                        GeneralJournalLine.Validate(GiroAccNo, UPGGeneralJournalLine.Field(13650).Value());
                        GeneralJournalLine.Modify(true);
                    end;
                until UPGGeneralJournalLine.Next() = 0;
        end;
    end;

    local procedure MigratePurchaseInvoiceHeaderFields();
    var
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        AllObj: Record AllObj;
        UPGPurchaseInvoiceHeader: RecordRef;
    begin
        if AllObj.GET(AllObj."Object Type"::Table, 104096) then begin
            UPGPurchaseInvoiceHeader.Open(104096);
            If UPGPurchaseInvoiceHeader.FindSet() then
                repeat
                    if PurchaseInvoiceHeader.Get(UPGPurchaseInvoiceHeader.Field(3)) then begin
                        PurchaseInvoiceHeader.Validate(GiroAccNo, UPGPurchaseInvoiceHeader.Field(13650).Value());
                        PurchaseInvoiceHeader.Modify(true);
                    end;
                until UPGPurchaseInvoiceHeader.Next() = 0;
        end;
    end;

    local procedure MigrateBankAccReconcilationFields();
    var
        BankAccReconcilation: Record "Bank Acc. Reconciliation";
        AllObj: Record AllObj;
        UPGBankAccReconcilation: RecordRef;
    begin
        if AllObj.GET(AllObj."Object Type"::Table, 104043) then begin
            UPGBankAccReconcilation.Open(104043);
            If UPGBankAccReconcilation.FindSet() then
                repeat
                    if BankAccReconcilation.Get(UPGBankAccReconcilation.Field(20), UPGBankAccReconcilation.Field(1), UPGBankAccReconcilation.Field(2)) then begin
                        BankAccReconcilation.Validate(FIKPaymentReconciliation, UPGBankAccReconcilation.Field(13600).Value());
                        BankAccReconcilation.Modify(true);
                    end;
                until UPGBankAccReconcilation.Next() = 0;
        end;
    end;

    local procedure MigrateBankAccRecLineFields();
    var
        BankAccRecLine: Record "Bank Acc. Reconciliation Line";
        AllObj: Record AllObj;
        UPGBankAccRecLine: RecordRef;
    begin
        if AllObj.GET(AllObj."Object Type"::Table, 104044) then begin
            UPGBankAccRecLine.Open(104044);
            If UPGBankAccRecLine.FindSet() then
                repeat
                    if BankAccRecLine.Get(UPGBankAccRecLine.Field(20), UPGBankAccRecLine.Field(1), UPGBankAccRecLine.Field(2), UPGBankAccRecLine.Field(3)) then begin
                        BankAccRecLine.Validate(PaymentReference, UPGBankAccRecLine.Field(13600).Value());
                        BankAccRecLine.Modify(true);
                    end;
                until UPGBankAccRecLine.Next() = 0;
        end;
    end;

    local procedure MigratePaymentMethodFields();
    var
        PaymentMethod: Record "Payment Method";
        AllObj: Record AllObj;
        UPGPaymentMethod: RecordRef;
    begin
        if AllObj.GET(AllObj."Object Type"::Table, 104045) then begin
            UPGPaymentMethod.Open(104045);
            If UPGPaymentMethod.FindSet() then
                repeat
                    if PaymentMethod.Get(UPGPaymentMethod.Field(1)) then begin
                        PaymentMethod.Validate(PaymentTypeValidation, UPGPaymentMethod.Field(13601).Value());
                        PaymentMethod.Modify(true);
                    end;
                until UPGPaymentMethod.Next() = 0;
        end;
    end;

    local procedure MigratePaymentExportDataFields();
    var
        PaymentExportData: Record "Payment Export Data";
        AllObj: Record AllObj;
        UPGPaymentExportData: RecordRef;
    begin
        if AllObj.GET(AllObj."Object Type"::Table, 104047) then begin
            UPGPaymentExportData.Open(104047);
            If UPGPaymentExportData.FindSet() then
                repeat
                    if PaymentExportData.Get(UPGPaymentExportData.Field(1)) then begin
                        PaymentExportData.Validate(RecipientGiroAccNo, UPGPaymentExportData.Field(13650).Value());
                        PaymentExportData.Modify(true);
                    end;

                until UPGPaymentExportData.Next() = 0;
        end;
    end;
}