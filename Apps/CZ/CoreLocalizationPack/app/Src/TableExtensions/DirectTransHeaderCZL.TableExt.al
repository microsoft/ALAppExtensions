// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

using Microsoft.Inventory.Ledger;

tableextension 31054 "Direct Trans. Header CZL" extends "Direct Trans. Header"
{
#if not CLEANSCHEMA25
    fields
    {
        field(31000; "Intrastat Exclude CZL"; Boolean)
        {
            Caption = 'Intrastat Exclude';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
        }
    }
#endif

    procedure GetRegisterUserIDCZL(): Code[50]
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetFilterFromDirectTransHeaderCZL(Rec);
        if ItemLedgerEntry.FindFirst() then
            exit(ItemLedgerEntry.GetRegisterUserIDCZL());
    end;
}
