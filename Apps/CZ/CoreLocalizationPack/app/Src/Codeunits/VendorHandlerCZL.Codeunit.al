// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

codeunit 11753 "Vendor Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterInsertEvent', '', false, false)]
    local procedure InitValueOnAfterInsertEvent(var Rec: Record Vendor)
    begin
        if Rec.IsTemporary() then
            exit;

        if not Rec."Allow Multiple Posting Groups" then begin
            Rec."Allow Multiple Posting Groups" := true;
            Rec.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterValidateEvent', 'Vendor Posting Group', false, false)]
    local procedure CheckChangeVendorPostingGroupOnAfterVendorPostingGroupValidate(var Rec: Record Vendor)
    begin
        Rec.CheckVendorLedgerOpenEntriesCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeIsContactUpdateNeeded', '', false, false)]
    local procedure CheckChangeOnBeforeIsContactUpdateNeeded(Vendor: Record Vendor; xVendor: Record Vendor; var UpdateNeeded: Boolean)
    begin
        UpdateNeeded := UpdateNeeded or
            (Vendor."Registration Number" <> xVendor."Registration Number") or
            (Vendor."Tax Registration No. CZL" <> xVendor."Tax Registration No. CZL");
    end;
}
