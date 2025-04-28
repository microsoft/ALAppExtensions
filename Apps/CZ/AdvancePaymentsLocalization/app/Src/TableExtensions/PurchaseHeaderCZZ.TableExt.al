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
        if IsAdvanceLetterDocTypeCZZ() then begin
            AdvanceLetterApplicationCZZ.SetRange("Document Type", GetAdvLetterUsageDocTypeCZZ());
            AdvanceLetterApplicationCZZ.SetRange("Document No.", "No.");
            AdvanceLetterApplicationCZZ.DeleteAll();
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
                AdvLetterUsageDocType := "Adv. Letter Usage Doc.Type CZZ"::"Purchase Order";
            "Document Type"::Invoice:
                AdvLetterUsageDocType := "Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice";
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
    local procedure OnAfterIsAdvanceLetterDocTypeCZZ(Rec: Record "Purchase Header"; var AdvanceLetterDocType: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetAdvLetterUsageDocTypeCZZ(Rec: Record "Purchase Header"; var AdvLetterUsageDocType: Enum "Adv. Letter Usage Doc.Type CZZ")
    begin
    end;
}
