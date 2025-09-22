// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.PowerBIReports;

using System.Upgrade;

codeunit 36957 "PowerBI Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        TransferDimensionSetEntries();
        InitialSetupUpgrade();
        CloseIncomeSourceCodeUpgrade();
    end;

    local procedure TransferDimensionSetEntries()
    var
        FlatDimensionSetEntry: Record "PowerBI Flat Dim. Set Entry";
        UpgradeTag: Codeunit "Upgrade Tag";
        DataTransfer: DataTransfer;
        FieldNo: Integer;
    begin
        if UpgradeTag.HasUpgradeTag(TransferDimensionSetEntriesUpgradeTag()) then
            exit;

        FlatDimensionSetEntry.DeleteAll(false);
        DataTransfer.SetTables(Database::"Dimension Set Entry", Database::"PowerBI Flat Dim. Set Entry");
        for FieldNo := 1 to 18 do
            DataTransfer.AddFieldValue(FieldNo, FieldNo);
        DataTransfer.CopyRows();

        UpgradeTag.SetUpgradeTag(TransferDimensionSetEntriesUpgradeTag());
    end;

    local procedure InitialSetupUpgrade()
    var
        Initialization: Codeunit Initialization;
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(InitialSetupUpgradeTag()) then
            exit;
        Initialization.SetupDefaultsForPowerBIReportsIfNotInitialized();
        UpgradeTag.SetUpgradeTag(InitialSetupUpgradeTag());
    end;

    local procedure CloseIncomeSourceCodeUpgrade()
    var
        Initialization: Codeunit Initialization;
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(CloseIncomeSourceCodeUpgradeTag()) then
            exit;
        Initialization.InitializeCloseIncomeSourceCodes();
        UpgradeTag.SetUpgradeTag(CloseIncomeSourceCodeUpgradeTag());
    end;

    local procedure TransferDimensionSetEntriesUpgradeTag(): Code[250]
    begin
        exit('MS-561310-POWERBI-TRANSFER-DIMENSION-SET-ENTRIES-20250110');
    end;

    local procedure InitialSetupUpgradeTag(): Code[250]
    begin
        exit('MS-GH-PY-364-POWERBI-INITIAL-SETUP-20241125');
    end;

    local procedure CloseIncomeSourceCodeUpgradeTag(): Code[250]
    begin
        exit('MS-GH-PY-529-POWERBI-CLSINCOME-UPGRADE-20250123');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(TransferDimensionSetEntriesUpgradeTag());
    end;

}