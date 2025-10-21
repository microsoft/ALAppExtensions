// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.DemoTool.Helpers;

codeunit 5275 "Create Return Reason"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPurchase: Codeunit "Contoso Purchase";
    begin
        ContosoPurchase.InsertReturnReason(Damaged(), DamageDescriptionLbl);
        ContosoPurchase.InsertReturnReason(WrongItem(), WrongItemDescriptionLbl);
        ContosoPurchase.InsertReturnReason(WrongSize(), WrongSizeDescriptionLbl);
        ContosoPurchase.InsertReturnReason(WrongColor(), WrongColorDescriptionLbl);
    end;

    procedure Damaged(): Code[10]
    begin
        exit(DamagedTok);
    end;

    procedure WrongItem(): Code[10]
    begin
        exit(ItemTok);
    end;

    procedure WrongSize(): Code[10]
    begin
        exit(SizeTok);
    end;

    procedure WrongColor(): Code[10]
    begin
        exit(ColorTok);
    end;

    var
        DamagedTok: Label 'DAMAGED', MaxLength = 10;
        ItemTok: Label 'ITEM', MaxLength = 10;
        SizeTok: Label 'SIZE', MaxLength = 10;
        ColorTok: Label 'COLOR', MaxLength = 10;
        DamageDescriptionLbl: Label 'Damaged or defective', MaxLength = 50;
        WrongItemDescriptionLbl: Label 'Wrong item', MaxLength = 50;
        WrongSizeDescriptionLbl: Label 'Wrong size', MaxLength = 50;
        WrongColorDescriptionLbl: Label 'Wrong color', MaxLength = 50;
}
