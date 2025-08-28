// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.FixedAssets.Depreciation;

codeunit 31499 "Create FA Depr. Book CZF"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertFADepreciationBook(var Rec: Record "FA Depreciation Book")
    var
        CreateFixedAsset: Codeunit "Create Fixed Asset";
        CreateDepreciationBookCZ: Codeunit "Create Depreciation Book CZ";
        CreateTaxDeprGrpCZF: Codeunit "Create Tax Depr. Grp. CZF";
    begin
        if Rec."Depreciation Book Code" <> CreateDepreciationBookCZ.SecondTax() then
            exit;

        case Rec."FA No." of
            CreateFixedAsset.FA000010(),
            CreateFixedAsset.FA000020(),
            CreateFixedAsset.FA000030(),
            CreateFixedAsset.FA000040(),
            CreateFixedAsset.FA000060(),
            CreateFixedAsset.FA000070(),
            CreateFixedAsset.FA000090():
                ValidateFADepreciationBook(Rec, CreateTaxDeprGrpCZF.TwoR());
            CreateFixedAsset.FA000050(),
            CreateFixedAsset.FA000080():
                ValidateFADepreciationBook(Rec, CreateTaxDeprGrpCZF.ThreeR());
        end;
    end;

    local procedure ValidateFADepreciationBook(var FADepreciationBook: Record "FA Depreciation Book"; TaxDepreciationGroupCode: Code[20])
    begin
        FADepreciationBook.Validate("Tax Deprec. Group Code CZF", TaxDepreciationGroupCode);
    end;
}
