#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using Microsoft.Foundation.Navigate;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.Environment.Configuration;
using System.Upgrade;

codeunit 10831 "Feature - PaymentMgt FR" implements "Feature Data Update"
{
    Access = Internal;
    Permissions = TableData "Feature Data Update Status" = rm;
    InherentEntitlements = X;
    InherentPermissions = X;
    ObsoleteReason = 'Feature Payment Management will be enabled by default in version 28.0.';
    ObsoleteState = Pending;
    ObsoleteTag = '28.0';

    var
        TempDocumentEntry: Record "Document Entry" temporary;
        DescriptionTxt: Label 'Existing records in GB BaseApp fields will be copied to Payment App fields';

    procedure IsDataUpdateRequired(): Boolean;
    begin
        CountRecords();
        if TempDocumentEntry.IsEmpty() then begin
            SetUpgradeTag(false);
            exit(false);
        end;
        exit(true);
    end;

    procedure ReviewData();
    var
        DataUpgradeOverview: Page "Data Upgrade Overview";
    begin
        Commit();
        Clear(DataUpgradeOverview);
        DataUpgradeOverview.Set(TempDocumentEntry);
        DataUpgradeOverview.RunModal();
    end;

    procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        UpdateFeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        UpdateFeatureDataUpdateStatus.SetRange("Feature Key", FeatureDataUpdateStatus."Feature Key");
        UpdateFeatureDataUpdateStatus.SetFilter("Company Name", '<>%1', FeatureDataUpdateStatus."Company Name");
        UpdateFeatureDataUpdateStatus.ModifyAll("Feature Status", FeatureDataUpdateStatus."Feature Status");

        SetUpgradeTag(true);
    end;

    procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    var
        FeatureDataUpdateMgt: Codeunit "Feature Data Update Mgt.";
        StartDateTime: DateTime;
        EndDateTime: DateTime;
    begin
        StartDateTime := CurrentDateTime;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, 'Upgrade Payment', StartDateTime);
        UpgradePayment();
        EndDateTime := CurrentDateTime;
        FeatureDataUpdateMgt.LogTask(FeatureDataUpdateStatus, 'Upgrade Payment', EndDateTime);
    end;

    procedure GetTaskDescription() TaskDescription: Text;
    begin
        TaskDescription := DescriptionTxt;
    end;

    local procedure CountRecords()
    var
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        TempDocumentEntry.Reset();
        TempDocumentEntry.DeleteAll();

        InsertDocumentEntry(Database::"Bank Account", BankAccount.TableCaption, BankAccount.Count());
        InsertDocumentEntry(Database::"Vendor Bank Account", VendorBankAccount.TableCaption, VendorBankAccount.Count());
        InsertDocumentEntry(Database::"Customer Bank Account", CustomerBankAccount.TableCaption, CustomerBankAccount.Count());
    end;

    local procedure InsertDocumentEntry(TableID: Integer; TableName: Text; RecordCount: Integer)
    begin
        if RecordCount = 0 then
            exit;

        TempDocumentEntry.Init();
        TempDocumentEntry."Entry No." += 1;
        TempDocumentEntry."Table ID" := TableID;
        TempDocumentEntry."Table Name" := CopyStr(TableName, 1, MaxStrLen(TempDocumentEntry."Table Name"));
        TempDocumentEntry."No. of Records" := RecordCount;
        TempDocumentEntry.Insert();
    end;

    local procedure UpgradeBankAccountBuffer()
    var
        BankAccountBufferFR: Record "Bank Account Buffer FR";
        BankAccountBuffer: Record "Bank Account Buffer";
    begin
        if BankAccountBuffer.FindSet() then
            repeat
                BankAccountBufferFR.TransferFields(BankAccountBuffer);
                BankAccountBufferFR.Insert();
            until BankAccountBuffer.Next() = 0;
    end;

    local procedure UpgradePaymentClass()
    var
        PaymentClassFR: Record "Payment Class FR";
        PaymentClass: Record "Payment Class";
    begin
        if PaymentClass.FindSet() then
            repeat
                PaymentClassFR.TransferFields(PaymentClass);
                PaymentClassFR.Insert();
            until PaymentClass.Next() = 0;
    end;

    local procedure UpgradePaymentHeader()
    var
        PaymentHeaderFR: Record "Payment Header FR";
        PaymentHeader: Record "Payment Header";
    begin
        if PaymentHeader.FindSet() then
            repeat
                PaymentHeaderFR.TransferFields(PaymentHeader);
                PaymentHeaderFR.Insert();
            until PaymentHeader.Next() = 0;
    end;

    local procedure UpgradePaymentLine()
    var
        PaymentLineFR: Record "Payment Line FR";
        PaymentLine: Record "Payment Line";
    begin
        if PaymentLine.FindSet() then
            repeat
                PaymentLineFR.TransferFields(PaymentLine);
                PaymentLineFR.Insert();
            until PaymentLine.Next() = 0;
    end;

    local procedure UpgradePaymentHeaderArchive()
    var
        PaymentHeaderArchiveFR: Record "Payment Header Archive FR";
        PaymentHeaderArchive: Record "Payment Header Archive";
    begin
        if PaymentHeaderArchive.FindSet() then
            repeat
                PaymentHeaderArchiveFR.TransferFields(PaymentHeaderArchive);
                PaymentHeaderArchiveFR.Insert();
            until PaymentHeaderArchive.Next() = 0;
    end;

    local procedure UpgradePaymentLineArchive()
    var
        PaymentLineArchiveFR: Record "Payment Line Archive FR";
        PaymentLineArchive: Record "Payment Line Archive";
    begin
        if PaymentLineArchive.FindSet() then
            repeat
                PaymentLineArchiveFR.TransferFields(PaymentLineArchive);
                PaymentLineArchiveFR.Insert();
            until PaymentLineArchive.Next() = 0;
    end;

    local procedure UpgradePaymentPostBuffer()
    var
        PaymentPostBufferFR: Record "Payment Post. Buffer FR";
        PaymentPostBuffer: Record "Payment Post. Buffer";
    begin
        if PaymentPostBuffer.FindSet() then
            repeat
                PaymentPostBufferFR.TransferFields(PaymentPostBuffer);
                PaymentPostBufferFR.Insert();
            until PaymentPostBuffer.Next() = 0;
    end;

    local procedure UpgradePaymentStatus()
    var
        PaymentStatusFR: Record "Payment Status FR";
        PaymentStatus: Record "Payment Status";
    begin
        if PaymentStatus.FindSet() then
            repeat
                PaymentStatusFR.TransferFields(PaymentStatus);
                PaymentStatusFR.Insert();
            until PaymentStatus.Next() = 0;
    end;

    local procedure UpgradePaymentStep()
    var
        PaymentStepFR: Record "Payment Step FR";
        PaymentStep: Record "Payment Step";
    begin
        if PaymentStep.FindSet() then
            repeat
                PaymentStepFR.TransferFields(PaymentStep);
                PaymentStepFR.Insert();
            until PaymentStep.Next() = 0;
    end;

    local procedure UpgradePaymentStepLedger()
    var
        PaymentStepLedgerFR: Record "Payment Step Ledger FR";
        PaymentStepLedger: Record "Payment Step Ledger";
    begin
        if PaymentStepLedger.FindSet() then
            repeat
                PaymentStepLedgerFR.TransferFields(PaymentStepLedger);
                PaymentStepLedgerFR.Insert();
            until PaymentStepLedger.Next() = 0;
    end;

    local procedure UpgradePaymentAddress()
    var
        PaymentAddressFR: Record "Payment Address FR";
        PaymentAddress: Record "Payment Address";
    begin
        if PaymentAddress.FindSet() then
            repeat
                PaymentAddressFR.TransferFields(PaymentAddress);
                PaymentAddressFR.Insert();
            until PaymentAddress.Next() = 0;
    end;

    local procedure UpgradePayment()
    var
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        UpgradeBankAccountBuffer();
        UpgradePaymentClass();
        UpgradePaymentHeader();
        UpgradePaymentHeaderArchive();
        UpgradePaymentLine();
        UpgradePaymentLineArchive();
        UpgradePaymentPostBuffer();
        UpgradePaymentStatus();
        UpgradePaymentStep();
        UpgradePaymentStepLedger();
        UpgradePaymentAddress();

        if BankAccount.FindSet() then
            repeat
#pragma warning disable AL0432
                BankAccount."Agency Code FR" := BankAccount."Agency Code";
                BankAccount."RIB Key FR" := BankAccount."RIB Key";
                BankAccount."RIB Checked FR" := BankAccount."RIB Checked";
#pragma warning restore AL0432
                BankAccount.Modify();
            until BankAccount.Next() = 0;

        if VendorBankAccount.FindSet() then
            repeat
#pragma warning disable AL0432
                VendorBankAccount."Agency Code FR" := VendorBankAccount."Agency Code";
                VendorBankAccount."RIB Key FR" := VendorBankAccount."RIB Key";
                VendorBankAccount."RIB Checked FR" := VendorBankAccount."RIB Checked";
#pragma warning restore AL0432
                VendorBankAccount.Modify();
            until VendorBankAccount.Next() = 0;

        if CustomerBankAccount.FindSet() then
            repeat
#pragma warning disable AL0432
                CustomerBankAccount."Agency Code FR" := CustomerBankAccount."Agency Code";
                CustomerBankAccount."RIB Key FR" := CustomerBankAccount."RIB Key";
                CustomerBankAccount."RIB Checked FR" := CustomerBankAccount."RIB Checked";
#pragma warning restore AL0432
                CustomerBankAccount.Modify();
            until CustomerBankAccount.Next() = 0;
    end;

    local procedure SetUpgradeTag(DataUpgradeExecuted: Boolean)
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagPayment: Codeunit "Upg. Tag Payment Management FR";
    begin
        // Set the upgrade tag to indicate that the data update is executed/skipped and the feature is enabled.
        // This is needed when the feature is enabled by default in a future version, to skip the data upgrade.
        if UpgradeTag.HasUpgradeTag(UpgTagPayment.GetPaymentUpgradeTag()) then
            exit;

        UpgradeTag.SetUpgradeTag(UpgTagPayment.GetPaymentUpgradeTag());
        if not DataUpgradeExecuted then
            UpgradeTag.SetSkippedUpgrade(UpgTagPayment.GetPaymentUpgradeTag(), true);
    end;
}
#endif