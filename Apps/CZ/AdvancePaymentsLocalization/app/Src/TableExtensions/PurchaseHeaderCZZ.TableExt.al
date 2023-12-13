// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Document;

tableextension 31008 "Purchase Header CZZ" extends "Purchase Header"
{
    fields
    {
        modify("Pay-to Vendor No.")
        {
            trigger OnAfterValidate()
            begin
                if "Pay-to Vendor No." <> xRec."Pay-to Vendor No." then
                    DeleteAdvanceLetterApplication();
            end;
        }
        modify("Currency Code")
        {
            trigger OnAfterValidate()
            begin
                if "Currency Code" <> xRec."Currency Code" then
                    DeleteAdvanceLetterApplication();
            end;
        }
        field(31010; "Unpaid Advance Letter CZZ"; Boolean)
        {
            Caption = 'Unpaid Advance Letter';
            FieldClass = FlowField;
            CalcFormula = exist("Purch. Adv. Letter Header CZZ" where("Order No." = field("No."), Status = filter(New | "To Pay")));
            Editable = false;
        }
    }

    trigger OnDelete()
    begin
        DeleteAdvanceLetterApplication();
    end;

    local procedure DeleteAdvanceLetterApplication()
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
    begin
        if "Document Type" in ["Document Type"::Order, "Document Type"::Invoice] then begin
            if "Document Type" = "Document Type"::Order then
                AdvanceLetterApplicationCZZ.SetRange("Document Type", "Adv. Letter Usage Doc.Type CZZ"::"Purchase Order")
            else
                AdvanceLetterApplicationCZZ.SetRange("Document Type", "Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice");
            AdvanceLetterApplicationCZZ.SetRange("Document No.", "No.");
            AdvanceLetterApplicationCZZ.DeleteAll();
        end;
    end;
}
