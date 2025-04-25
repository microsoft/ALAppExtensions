// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.Inventory.Item;
using Microsoft.DemoData.Finance;

codeunit 19029 "Create IN Item Charge"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertItemCharge(var Rec: Record "Item Charge")
    var
        CreateItemCharge: Codeunit "Create Item Charge";
        CreateINGSTGroup: Codeunit "Create IN GST Group";
        CreateINHSNSAC: Codeunit "Create IN HSN/SAC";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        case Rec."No." of
            CreateItemCharge.JBFreight(),
            CreateItemCharge.PurchAllowance():
                ValidateRecordFields(Rec, CreateVATPostingGroups.Zero(), CreateINGSTGroup.GSTGroup2089(), CreateINHSNSAC.HSNSACCode2089001());
        end;
    end;

    local procedure ValidateRecordFields(var ItemCharge: Record "Item Charge"; VATProdPostingGroup: Code[20]; GSTGroupCode: Code[10]; HSNSACCode: Code[10])
    begin
        ItemCharge.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        ItemCharge.Validate("GST Group Code", GSTGroupCode);
        ItemCharge.Validate("HSN/SAC Code", HSNSACCode);
    end;
}
