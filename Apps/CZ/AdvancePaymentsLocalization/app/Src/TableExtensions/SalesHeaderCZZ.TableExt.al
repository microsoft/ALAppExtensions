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
        if IsAdvanceLetterDocTypeCZZ() then begin
            AdvanceLetterApplication.SetRange("Document Type", GetAdvLetterUsageDocTypeCZZ());
            AdvanceLetterApplication.SetRange("Document No.", "No.");
            AdvanceLetterApplication.DeleteAll();
        end;
    end;

    procedure IsAdvanceLetterDocTypeCZZ() AdvanceLetterDocType: Boolean
    begin
        AdvanceLetterDocType := "Document Type" in ["Document Type"::Order, "Document Type"::Invoice];
        OnAfterIsAdvanceLetterDocTypeCZZ(Rec, AdvanceLetterDocType);
    end;

    procedure GetAdvLetterUsageDocTypeCZZ() AdvLetterUsageDocType: Enum "Adv. Letter Usage Doc.Type CZZ"
    begin
        case "Document Type" of
            "Document Type"::Order:
                AdvLetterUsageDocType := "Adv. Letter Usage Doc.Type CZZ"::"Sales Order";
            "Document Type"::Invoice:
                AdvLetterUsageDocType := "Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice";
        end;
        OnAfterGetAdvLetterUsageDocTypeCZZ(Rec, AdvLetterUsageDocType);
    end;

    procedure HasAdvanceLetterLinkedCZZ(): Boolean
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
    begin
        AdvanceLetterApplicationCZZ.SetRange("Document Type", GetAdvLetterUsageDocTypeCZZ());
        AdvanceLetterApplicationCZZ.SetRange("Document No.", "No.");
        exit(not AdvanceLetterApplicationCZZ.IsEmpty());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsAdvanceLetterDocTypeCZZ(Rec: Record "Sales Header"; var AdvanceLetterDocType: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetAdvLetterUsageDocTypeCZZ(Rec: Record "Sales Header"; var AdvLetterUsageDocType: Enum "Adv. Letter Usage Doc.Type CZZ")
    begin
    end;
}
