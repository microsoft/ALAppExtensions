// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

codeunit 18640 "Migrate FA Depreciation Data"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        MigrateFAShiftData();
    end;

    local procedure MigrateFAShiftData()
    var
        FixedAssetShift: Record "Fixed Asset Shift";
    begin
        FixedAssetShift.SetFilter("FA Posting Group", '<>%1', '');
        if FixedAssetShift.FindSet() then
            repeat
                FixedAssetShift."Fixed Asset Posting Group" := FixedAssetShift."FA Posting Group";
                FixedAssetShift."FA Posting Group" := '';
                FixedAssetShift.Modify();
            until FixedAssetShift.Next() = 0;
    end;
}
