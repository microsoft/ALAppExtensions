namespace Microsoft.EServices.EDocument.OrderMatch.Copilot;
using Microsoft.eServices.EDocument.OrderMatch;
using Microsoft.eServices.EDocument;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Setup;

table 6163 "E-Doc. PO Match Prop. Buffer"
{
    TableType = Temporary;
    Extensible = false;
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document Order No."; Code[20])
        {
            Caption = 'Document Order No.';
            TableRelation = "Purchase Header"."No." where("Document Type" = const(Order));
        }
        field(2; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            TableRelation = "Purchase Line"."Line No." where("Document Type" = const(Order), "Document No." = field("Document Order No."));
        }
        field(3; "E-Document Entry No."; Integer)
        {
            Caption = 'E-Document Entry No.';
            TableRelation = "E-Document";
        }
        field(4; "E-Document Line No."; Integer)
        {
            Caption = 'E-Document Line No.';
            TableRelation = "E-Doc. Imported Line"."Line No." where("E-Document Entry No." = field("E-Document Entry No."));
        }
        field(5; "E-Document Description"; Text[100])
        {
            Caption = 'E-Document Line Description';
        }
        field(6; "PO Description"; Text[100])
        {
            Caption = 'Purchase Order Line Description';
        }
        field(7; "E-Document Direct Unit Cost"; Decimal)
        {
            Caption = 'E-Document Direct Unit Cost';
        }
        field(8; "PO Direct Unit Cost"; Decimal)
        {
            Caption = 'Purchase Order Direct Unit Cost';
        }
        field(9; "E-Document Line Discount"; Decimal)
        {
            Caption = 'E-Document Line Discount';
        }
        field(10; "PO Line Discount"; Decimal)
        {
            Caption = 'Purchase Order Line Discount';
        }
        field(11; "Matched Quantity"; Integer)
        {
            Caption = 'Matched Quantity';
        }
        field(12; "AI Proposal"; Text[2048])
        {
            Caption = 'Proposal';
        }
        field(14; "Learn Matching Rule"; Boolean)
        {
            Caption = 'Learn Matching Rule';
        }
    }

    keys
    {
        key(Key1; "Document Order No.", "Document Line No.", "E-Document Entry No.", "E-Document Line No.")
        {
            Clustered = true;
        }
    }
    procedure GetStyle() Result: Text
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        EDocPOCopilotMatching: codeunit "E-Doc. PO Copilot Matching";
        CostDifferenceValue: Decimal;
    begin
        if PurchasesPayablesSetup.Get() then;

        CostDifferenceValue := EDocPOCopilotMatching.CostDifference(Rec."PO Direct Unit Cost", Rec."PO Line Discount", Rec."E-Document Direct Unit Cost", Rec."E-Document Line Discount");

        if CostDifferenceValue = 0 then
            exit('Favorable')
        else
            if CostDifferenceValue < PurchasesPayablesSetup."E-Document Matching Difference" then
                exit('Ambiguous')
            else
                if CostDifferenceValue > PurchasesPayablesSetup."E-Document Matching Difference" then
                    exit('Unfavorable');

        exit('None');
    end;

}