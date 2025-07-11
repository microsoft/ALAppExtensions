// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.DemoTool.Helpers;

codeunit 19018 "Create IN FA Depreciation Book"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FAModuleSetup: Record "FA Module Setup";
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
    begin
        FAModuleSetup.Get();

        ContosoFixedAsset.InsertDepreciationBook(IncomeTax(), IncomeTaxBookLbl, false, false, false, false, false, false, false, false, false, 0);
    end;

    var
        IncomeTaxLbl: Label 'INCOME TAX', MaxLength = 10;
        IncomeTaxBookLbl: Label 'Income Tax Book', MaxLength = 100;

    procedure IncomeTax(): Code[10]
    begin
        exit(IncomeTaxLbl);
    end;
}
