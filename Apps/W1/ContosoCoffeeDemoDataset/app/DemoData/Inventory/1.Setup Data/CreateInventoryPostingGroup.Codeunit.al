// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.DemoTool.Helpers;

codeunit 5229 "Create Inventory Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertInventoryPostingGroup(Resale(), ResaleItemsLbl);
    end;

    procedure Resale(): Code[20]
    begin
        exit(ResaleTok);
    end;

    var
        ResaleItemsLbl: Label 'Resale items', MaxLength = 100;
        ResaleTok: Label 'RESALE', MaxLength = 20;
}
