// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Counting.Document;

using Microsoft.Inventory.Journal;

tableextension 11711 "Phys. Invt. Order Line CZL" extends "Phys. Invt. Order Line"
{
    fields
    {
        field(31079; "Invt. Movement Template CZL"; Code[10])
        {
            Caption = 'Inventory Movement Template';
            TableRelation = if ("Entry Type" = const(" ")) "Invt. Movement Template CZL" else
            if ("Entry Type" = const("Positive Adjmt.")) "Invt. Movement Template CZL" where("Entry Type" = const("Positive Adjmt.")) else
            if ("Entry Type" = const("Negative Adjmt.")) "Invt. Movement Template CZL" where("Entry Type" = const("Negative Adjmt."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
            begin
                Validate("Gen. Bus. Posting Group", '');
                if InvtMovementTemplateCZL.Get("Invt. Movement Template CZL") then
                    Validate("Gen. Bus. Posting Group", InvtMovementTemplateCZL."Gen. Bus. Posting Group");
            end;
        }
    }
}
