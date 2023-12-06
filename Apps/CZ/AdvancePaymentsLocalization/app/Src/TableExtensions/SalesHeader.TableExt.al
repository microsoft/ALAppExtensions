// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Document;

tableextension 31005 "Sales Header CZZ" extends "Sales Header"
{
    fields
    {
        modify("Bill-to Customer No.")
        {
            trigger OnAfterValidate()
            begin
                if "Bill-to Customer No." <> xRec."Bill-to Customer No." then
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
            CalcFormula = exist("Sales Adv. Letter Header CZZ" where("Order No." = field("No."), Status = filter(New | "To Pay")));
            Editable = false;
        }
    }

    trigger OnDelete()
    begin
        DeleteAdvanceLetterApplication();
    end;

    local procedure DeleteAdvanceLetterApplication()
    var
        AdvanceLetterApplication: Record "Advance Letter Application CZZ";
    begin
        if "Document Type" in ["Document Type"::Order, "Document Type"::Invoice] then begin
            if "Document Type" = "Document Type"::Order then
                AdvanceLetterApplication.SetRange("Document Type", "Adv. Letter Usage Doc.Type CZZ"::"Sales Order")
            else
                AdvanceLetterApplication.SetRange("Document Type", "Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice");
            AdvanceLetterApplication.SetRange("Document No.", "No.");
            AdvanceLetterApplication.DeleteAll();
        end;
    end;
}
