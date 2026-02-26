// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.DemoData.Finance;
using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Setup;

codeunit 5609 "Create FA Jnl. Lines"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    EventSubscriberInstance = Manual;
    Permissions = tabledata "FA Setup" = r;

    trigger OnRun()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateFAJnlTemplate: Codeunit "Create FA Jnl. Template";
        CreateFixedAsset: Codeunit "Create Fixed Asset";
        FAJournalBatchName: Code[10];
        FAJournalTemplateName: Code[10];
        BalanceAccountNo: Code[20];
    begin
        FASetup.Get();
        FASetup.TestField("Default Depr. Book");
        FAJournalTemplateName := CreateFAJnlTemplate.Assets();
        FAJournalBatchName := CreateFAJnlTemplate.Default();
        BalanceAccountNo := CreateGLAccount.Cash();

        ContosoFixedAsset.InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 10000, CreateFixedAsset.FA000010(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", BalanceAccountNo, 65000);
        ContosoFixedAsset.InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 20000, CreateFixedAsset.FA000020(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", BalanceAccountNo, 70000);
        ContosoFixedAsset.InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 30000, CreateFixedAsset.FA000030(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", BalanceAccountNo, 95000);
        ContosoFixedAsset.InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 40000, CreateFixedAsset.FA000050(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", BalanceAccountNo, 15000);
        ContosoFixedAsset.InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 50000, CreateFixedAsset.FA000060(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", BalanceAccountNo, 60000);
        ContosoFixedAsset.InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 60000, CreateFixedAsset.FA000070(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", BalanceAccountNo, 1500);
        ContosoFixedAsset.InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 70000, CreateFixedAsset.FA000080(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", BalanceAccountNo, 11000);
        ContosoFixedAsset.InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 80000, CreateFixedAsset.FA000090(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", BalanceAccountNo, 4000);
        Codeunit.Run(Codeunit::"Post FA Jnl. Lines");

        CalculateDepreciationLines(ContosoUtilities.AdjustDate(19011231D), 1);
        CalculateDepreciationLines(ContosoUtilities.AdjustDate(19021231D), 2);
        Codeunit.Run(Codeunit::"Post FA Jnl. Lines");
    end;

    local procedure CalculateDepreciationLines(PostingDate: Date; BatchCount: Integer)
    var
        CalculateDepreciation: Report "Calculate Depreciation";
    begin
        CalculateDepreciation.InitializeRequest(FASetup."Default Depr. Book", PostingDate, false, 0, PostingDate, StrSubstNo('%1%2', AssetDepreciationLbl, BatchCount), DepreciationLbl, true);
        CalculateDepreciation.UseRequestPage(false);
        BindSubscription(this);
        CalculateDepreciation.Run();
        UnbindSubscription(this);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Calculate Depreciation", OnPostReportOnBeforeConfirmShowGenJournalLines, '', true, true)]
    local procedure ConfirmShowGenJournalLines(DeprBook: Record "Depreciation Book"; GenJnlLine: Record "Gen. Journal Line"; GenJnlLineCreatedCount: Integer; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    var
        FASetup: Record "FA Setup";
        AcquisitionLbl: Label 'Acquisition', MaxLength = 100;
        AssetAcquisitionLbl: Label 'ASSET-ACQ', MaxLength = 20;
        AssetDepreciationLbl: Label 'ASSET-DEPR', MaxLength = 20;
        DepreciationLbl: Label 'Depreciation', MaxLength = 100;
}