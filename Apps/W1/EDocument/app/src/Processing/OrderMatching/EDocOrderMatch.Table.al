namespace Microsoft.eServices.EDocument.OrderMatch;

using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument;

table 6164 "E-Doc. Order Match"
{
    DataClassification = CustomerContent;
    Access = Internal;

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
        field(5; Quantity; Integer)
        {
            Caption = 'Quantity';
        }
        field(6; "Direct Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
        }
        field(7; "Line Discount %"; Decimal)
        {
            Caption = 'Discount %';
        }
        field(8; "Unit of Measure Code"; Code[20])
        {
            Caption = 'Unit of Measure';
        }
        field(9; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(10; "Fully Matched"; Boolean)
        {
            Caption = 'Fully Matched';
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
            SumIndexFields = Quantity;
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


}