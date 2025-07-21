// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Journal;
using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;

codeunit 31202 "Create Invt. Mvmt. Templ. CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
        ContosoInventoryCZ: Codeunit "Contoso Inventory CZ";
        CreatePostingGroupsCZ: Codeunit "Create Posting Groups CZ";
    begin
        ContosoInventoryCZ.InsertInvtMovementTemplate(Surplus(), SurplusDescriptionLbl, InvtMovementTemplateCZL."Entry Type"::"Positive Adjmt.", CreatePostingGroupsCZ.ISurplus());
        ContosoInventoryCZ.InsertInvtMovementTemplate(Deficiency(), DeficiencyDescriptionLbl, InvtMovementTemplateCZL."Entry Type"::"Negative Adjmt.", CreatePostingGroupsCZ.IDeficiency());
        ContosoInventoryCZ.InsertInvtMovementTemplate(Transfer(), TransferDescriptionLbl, InvtMovementTemplateCZL."Entry Type"::Transfer, CreatePostingGroupsCZ.ITransfer());
    end;

    procedure Surplus(): Code[10]
    begin
        exit(SurplusTok);
    end;

    procedure Deficiency(): Code[10]
    begin
        exit(DeficiencyTok);
    end;

    procedure Transfer(): Code[10]
    begin
        exit(TransferTok);
    end;

    var
        SurplusTok: Label 'SURPLUS', MaxLength = 10;
        SurplusDescriptionLbl: Label 'Physical Inventory Surplus', MaxLength = 80;
        DeficiencyTok: Label 'DEFICIENCY', MaxLength = 10;
        DeficiencyDescriptionLbl: Label 'Physical Inventory Deficiency', MaxLength = 80;
        TransferTok: Label 'TRANSFER', MaxLength = 10;
        TransferDescriptionLbl: Label 'Inventory Transfer', MaxLength = 80;
}
