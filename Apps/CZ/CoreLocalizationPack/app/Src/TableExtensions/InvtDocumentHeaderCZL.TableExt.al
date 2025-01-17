// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Document;

using Microsoft.Inventory.Journal;

tableextension 31034 "Invt. Document Header CZL" extends "Invt. Document Header"
{
    fields
    {
        field(11700; "Invt. Movement Template CZL"; Code[10])
        {
            Caption = 'Inventory Movement Template';
            TableRelation = if ("Document Type" = const(Receipt)) "Invt. Movement Template CZL" where("Entry Type" = const("Positive Adjmt.")) else
            if ("Document Type" = const(Shipment)) "Invt. Movement Template CZL" where("Entry Type" = const("Negative Adjmt."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
            begin
                Validate("Gen. Bus. Posting Group", '');
                if InvtMovementTemplateCZL.Get("Invt. Movement Template CZL") then begin
                    if "Document Type" = Enum::"Invt. Doc. Document Type"::Receipt then
                        InvtMovementTemplateCZL.TestField("Entry Type", InvtMovementTemplateCZL."Entry Type"::"Positive Adjmt.")
                    else
                        InvtMovementTemplateCZL.TestField("Entry Type", InvtMovementTemplateCZL."Entry Type"::"Negative Adjmt.");
                    Validate("Gen. Bus. Posting Group", InvtMovementTemplateCZL."Gen. Bus. Posting Group");
                end;
            end;
        }
    }
}
