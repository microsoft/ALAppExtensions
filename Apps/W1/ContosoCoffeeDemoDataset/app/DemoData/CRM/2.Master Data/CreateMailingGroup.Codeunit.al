// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.CRM;

using Microsoft.DemoTool.Helpers;

codeunit 5591 "Create Mailing Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertMailingGroup(Card(), XMasCardLbl);
        ContosoCRM.InsertMailingGroup(Gift(), XMasGiftLbl);
    end;

    procedure Card(): Code[10]
    begin
        exit(CardTok);
    end;

    procedure Gift(): Code[10]
    begin
        exit(GiftTok);
    end;

    var
        CardTok: Label 'X-CARD', MaxLength = 10;
        GiftTok: Label 'X-GIFT', MaxLength = 10;
        XMasCardLbl: Label 'X-mas card', MaxLength = 100;
        XMasGiftLbl: Label 'X-mas gift', MaxLength = 100;
}
