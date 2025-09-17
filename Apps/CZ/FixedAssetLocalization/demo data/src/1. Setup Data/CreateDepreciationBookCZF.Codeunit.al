// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.DemoTool.Helpers;

codeunit 11716 "Create Depreciation Book CZF"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAssetCZF: Codeunit "Contoso Fixed Asset CZF";
        CreateDepreciationBook: Codeunit "Create Depreciation Book CZ";
    begin
        ContosoFixedAssetCZF.UpdateDepreciationBook(CreateDepreciationBook.FirstAccount(), true, true, true, false, true, true, true);
        ContosoFixedAssetCZF.UpdateDepreciationBook(CreateDepreciationBook.SecondTax(), true, true, true, true, false, false, false);
        ContosoFixedAssetCZF.UpdateDepreciationBook(CreateDepreciationBook.ThirdRegister(), true, true, false, false, false, false, false);
    end;
}
