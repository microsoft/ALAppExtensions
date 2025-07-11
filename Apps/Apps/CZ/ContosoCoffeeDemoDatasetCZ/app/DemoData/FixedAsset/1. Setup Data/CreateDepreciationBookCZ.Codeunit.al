// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.DemoTool.Helpers;

codeunit 31183 "Create Depreciation Book CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
    begin
        ContosoFixedAsset.InsertDepreciationBook(FirstAccount(), AccountBookLbl, true, true, true, true, true, true, true, true, true, 10);
        ContosoFixedAsset.InsertDepreciationBook(SecondTax(), TaxBookLbl, true, true, true, true, true, true, true, true, true, 10);
    end;

    var
        FirstAccountLbl: Label '1-ACCOUNT', MaxLength = 10;
        SecondTaxLbl: Label '2-TAX', MaxLength = 10;
        AccountBookLbl: Label 'Account book', MaxLength = 100;
        TaxBookLbl: Label 'Tax book', MaxLength = 100;

    procedure FirstAccount(): Code[10]
    begin
        exit(FirstAccountLbl);
    end;

    procedure SecondTax(): Code[10]
    begin
        exit(SecondTaxLbl);
    end;
}
