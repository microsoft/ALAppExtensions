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
        FAModuleSetup: Record "FA Module Setup";
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
    begin
        ContosoFixedAsset.InsertDepreciationBook(FirstAccount(), AccountBookLbl, true, true, true, true, true, true, true, true, true, 10, 1, true, true, true, true, true);
        ContosoFixedAsset.InsertDepreciationBook(SecondTax(), TaxBookLbl, false, false, false, false, false, false, false, false, true, 10, 1, false, true, true, true, true);
        ContosoFixedAsset.InsertDepreciationBook(ThirdRegister(), RegisterBookLbl, false, false, false, false, false, false, false, false, true, 10, 1, false, true, false, false, true);

        FAModuleSetup.Get();

        if FAModuleSetup."Default Depreciation Book" = '' then
            FAModuleSetup.Validate("Default Depreciation Book", ThirdRegister());

        FAModuleSetup.Modify();
    end;

    internal procedure DeleteDepreciationBooks()
    var
        ContosoFixedAssetCZ: Codeunit "Contoso Fixed Asset CZ";
        CreateFADepreciationBook: Codeunit "Create FA Depreciation Book";
    begin
        ContosoFixedAssetCZ.DeleteDepreciationBook(CreateFADepreciationBook.Company());
    end;

    internal procedure CreateDummyDepreciationBooks()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        CreateFADepreciationBook: Codeunit "Create FA Depreciation Book";
    begin
        ContosoFixedAsset.InsertDepreciationBook(CreateFADepreciationBook.Company(), '', false, false, false, false, false, false, false, false, false, 0);
    end;

    var
        FirstAccountLbl: Label '1-ACCOUNT', MaxLength = 10;
        SecondTaxLbl: Label '2-TAX', MaxLength = 10;
        ThirdRegisterLbl: Label '3-REGISTER', MaxLength = 10;
        AccountBookLbl: Label 'Accounting depreciation book', MaxLength = 100;
        TaxBookLbl: Label 'Tax depreciation book', MaxLength = 100;
        RegisterBookLbl: Label 'Register depreciation book', MaxLength = 100;

    procedure FirstAccount(): Code[10]
    begin
        exit(FirstAccountLbl);
    end;

    procedure SecondTax(): Code[10]
    begin
        exit(SecondTaxLbl);
    end;

    procedure ThirdRegister(): Code[10]
    begin
        exit(ThirdRegisterLbl);
    end;
}
