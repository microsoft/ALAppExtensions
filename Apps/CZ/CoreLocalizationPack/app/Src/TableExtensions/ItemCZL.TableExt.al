// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

#if not CLEAN22
using Microsoft.Inventory.Intrastat;
#endif
using Microsoft.Inventory.Ledger;

tableextension 11745 "Item CZL" extends Item
{
    fields
    {
        field(31066; "Statistic Indication CZL"; Code[10])
        {
            Caption = 'Statistic Indication';
            DataClassification = CustomerContent;
#if not CLEAN22
            TableRelation = "Statistic Indication CZL".Code where("Tariff No." = field("Tariff No."));
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

        }
        field(31067; "Specific Movement CZL"; Code[10])
        {
            Caption = 'Specific Movement';
            DataClassification = CustomerContent;
#if not CLEAN22
            TableRelation = "Specific Movement CZL".Code;
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
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
