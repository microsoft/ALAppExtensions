// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoTool.Helpers;

using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;

codeunit 5659 "Contoso Over Receipt Code"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Vendor Bank Account" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertOverReceiptCode(Code: Code[20]; Description: Text[100]; Default: Boolean; OverReceiptTolerancePer: Decimal)
    var
        OverReceiptCode: Record "Over-Receipt Code";
        Exists: Boolean;
    begin
        if OverReceiptCode.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        OverReceiptCode.Validate(Code, Code);
        OverReceiptCode.Validate(Description, Description);
        OverReceiptCode.Validate(Default, Default);
        OverReceiptCode.Validate("Over-Receipt Tolerance %", OverReceiptTolerancePer);

        if Exists then
            OverReceiptCode.Modify(true)
        else
            OverReceiptCode.Insert(true);
    end;
}
