// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.FixedAssets.Setup;

codeunit 31208 "Create FA Setup CZF"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "FA Setup" = rim;

    trigger OnRun()
    begin
        UpdateFASetup()
    end;

    local procedure UpdateFASetup()
    var
        CreateDepreciationBookCZ: Codeunit "Create Depreciation Book CZ";
        CreateNoSeriesCZF: Codeunit "Create No. Series CZF";
    begin
        ValidateRecordFields(CreateDepreciationBookCZ.SecondTax(), CreateNoSeriesCZF.FAHIS(), true, true);
    end;

    local procedure ValidateRecordFields(TaxDepreciationBook: Code[10]; FixedAssetHistoryNos: Code[20]; FixedAssetHistory: Boolean; FAAcquisitionAsCustom2: Boolean)
    var
        FASetup: Record "FA Setup";
    begin
        FASetup.Get();
        FASetup.Validate("Tax Depreciation Book CZF", TaxDepreciationBook);
        FASetup.Validate("Fixed Asset History Nos. CZF", FixedAssetHistoryNos);
        FASetup.Validate("Fixed Asset History CZF", FixedAssetHistory);
        FASetup.Validate("FA Acquisition As Custom 2 CZF", FAAcquisitionAsCustom2);
        FASetup.Modify(true);
    end;
}
