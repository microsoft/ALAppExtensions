namespace Microsoft.eServices.EDocument.OrderMatch;

using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.OrderMatch.Copilot;

table 6164 "E-Doc. Order Match"
{
    DataClassification = CustomerContent;
    Access = Internal;
    ReplicateData = false;

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
            Caption = 'E-Document Imported Line No.';
            TableRelation = "E-Doc. Imported Line"."Line No." where("E-Document Entry No." = field("E-Document Entry No."));
        }
#if not CLEANSCHEMA29
        field(5; Quantity; Integer)
        {
            Caption = 'Quantity';
            ObsoleteReason = 'This field has been replaced by the Precise Quantity field.';
#if CLEAN26
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#else
            ObsoleteState = Pending;
            ObsoleteTag = '26.0';
#endif
        }
#endif
        field(6; "E-Document Direct Unit Cost"; Decimal)
        {
            Caption = 'E-Document Unit Cost';
        }
        field(7; "PO Direct Unit Cost"; Decimal)
        {
            Caption = 'Purchase Order Unit Cost';
        }
        field(8; "Line Discount %"; Decimal)
        {
            Caption = 'Discount %';
        }
        field(9; "Unit of Measure Code"; Code[20])
        {
            Caption = 'Unit of Measure';
        }
        field(10; "E-Document Description"; Text[100])
        {
            Caption = 'E-Document Description';
        }
        field(11; "PO Description"; Text[100])
        {
            Caption = 'Purchase Order Description';
        }
        field(12; "Fully Matched"; Boolean)
        {
            Caption = 'Fully Matched';
        }
        field(13; "Precise Quantity"; Decimal)
        {
            Caption = 'Quantity';
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
        key(Key2; "E-Document Entry No.", "E-Document Line No.", "Document Order No.")
        {
            SumIndexFields = "Precise Quantity";
        }
    }

    procedure GetPurchaseLine() PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Get(Enum::"Purchase Document Type"::Order, Rec."Document Order No.", Rec."Document Line No.");
    end;

    procedure GetImportedLine() ImportedLine: Record "E-Doc. Imported Line";
    begin
        ImportedLine.Get(Rec."E-Document Entry No.", Rec."E-Document Line No.");
    end;

    procedure InsertMatch(var TempAIProposalBuffer: Record "E-Doc. PO Match Prop. Buffer" temporary; var TempEDocMatches: Record "E-Doc. Order Match" temporary)
    begin
        TempEDocMatches.Init();
        TempEDocMatches.Validate("Document Order No.", TempAIProposalBuffer."Document Order No.");
        TempEDocMatches.Validate("Document Line No.", TempAIProposalBuffer."Document Line No.");
        TempEDocMatches.Validate("E-Document Entry No.", TempAIProposalBuffer."E-Document Entry No.");
        TempEDocMatches.Validate("E-Document Line No.", TempAIProposalBuffer."E-Document Line No.");
        TempEDocMatches.Validate("Precise Quantity", TempAIProposalBuffer."Matched Quantity");
        TempEDocMatches.Validate("E-Document Direct Unit Cost", TempAIProposalBuffer."E-Document Direct Unit Cost");
        TempEDocMatches.Validate("Line Discount %", TempAIProposalBuffer."E-Document Line Discount");
        TempEDocMatches.Validate("PO Direct Unit Cost", TempAIProposalBuffer."PO Direct Unit Cost");
        TempEDocMatches."E-Document Description" := TempAIProposalBuffer."E-Document Description";
        TempEDocMatches."PO Description" := TempAIProposalBuffer."PO Description";
        TempEDocMatches.Insert();
    end;


}