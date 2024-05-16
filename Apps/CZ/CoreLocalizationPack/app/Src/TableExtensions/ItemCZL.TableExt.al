// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

using Microsoft.Inventory.Ledger;

tableextension 11745 "Item CZL" extends Item
{
    fields
    {
        field(31066; "Statistic Indication CZL"; Code[10])
        {
            Caption = 'Statistic Indication';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

        }
        field(31067; "Specific Movement CZL"; Code[10])
        {
            Caption = 'Specific Movement';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
    }

    procedure CheckOpenItemLedgerEntriesCZL()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ChangeErr: Label ' cannot be changed';
    begin
        if "No." = '' then
            exit;

        ItemLedgerEntry.SetCurrentKey("Item No.", Open);
        ItemLedgerEntry.SetRange("Item No.", "No.");
        ItemLedgerEntry.SetRange(Open, true);
        if not ItemLedgerEntry.IsEmpty() then
            FieldError("Inventory Posting Group", ChangeErr);

        ItemLedgerEntry.SetRange(Open);
        ItemLedgerEntry.SetRange("Completely Invoiced", false);
        if not ItemLedgerEntry.IsEmpty() then
            FieldError("Inventory Posting Group", ChangeErr);
    end;
}
