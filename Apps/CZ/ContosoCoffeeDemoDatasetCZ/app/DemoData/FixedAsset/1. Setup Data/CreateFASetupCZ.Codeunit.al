// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.FixedAssets.Setup;

codeunit 11715 "Create FA Setup CZ"
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
    begin
        ValidateRecordFields(CreateDepreciationBookCZ.FirstAccount(), true, false);
    end;

    local procedure ValidateRecordFields(DefaultDepreciationBook: Code[10]; AllowPostingToMainAssets: Boolean; AutomaticInsurancePosting: Boolean)
    var
        FASetup: Record "FA Setup";
    begin
        FASetup.Get();
        FASetup.Validate("Default Depr. Book", DefaultDepreciationBook);
        FASetup.Validate("Allow Posting to Main Assets", AllowPostingToMainAssets);
        FASetup.Validate("Automatic Insurance Posting", AutomaticInsurancePosting);
        FASetup.Modify(true);
    end;
}
