// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Journal;

pageextension 11711 "Item Journal CZL" extends "Item Journal"
{
    layout
    {
        addafter("Transport Method")
        {
            field("Transaction Specification CZL"; Rec."Transaction Specification")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code for the transaction specification, for the purpose of reporting to INTRASTAT.';
            }
            field("Shpt. Method Code CZL"; Rec."Shpt. Method Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the item''s shipment method.';
                Visible = false;
            }
        }
        addafter("Document Date")
        {
            field("Invt. Movement Template CZL"; InvtMovementTemplateNameCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Inventory Movement Template';
                ToolTip = 'Specifies the template for item movement.';
                TableRelation = "Invt. Movement Template CZL" where("Entry Type" = filter(Purchase .. "Negative Adjmt."));

                trigger OnValidate()
                begin
                    Rec.Validate("Invt. Movement Template CZL", InvtMovementTemplateNameCZL);
                    EntryType := Rec."Entry Type";
                end;
            }
        }
        addafter("Gen. Prod. Posting Group")
        {
            field("G/L Correction CZL"; Rec."G/L Correction CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies to include general ledger corrections on the item journal line.';
                Visible = false;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        InvtMovementTemplateNameCZL := Rec."Invt. Movement Template CZL";
    end;

    trigger OnAfterGetRecord()
    begin
        InvtMovementTemplateNameCZL := Rec."Invt. Movement Template CZL";
    end;

    var
        InvtMovementTemplateNameCZL: Code[10];
}
