namespace Microsoft.eServices.EDocument.OrderMatch;

using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument;
table 6165 "E-Doc. Imported Line"
{
    DataClassification = CustomerContent;
    Access = Internal;
    ReplicateData = false;

    fields
    {
        field(1; "E-Document Entry No."; Integer)
        {
            Caption = 'E-Document Entry No.';
            TableRelation = "E-Document";
            Editable = false;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(3; Type; Enum "Purchase Line Type")
        {
            Caption = 'Type';
            Editable = false;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(5; "Unit Of Measure Code"; Code[20])
        {
            Caption = 'Unit Of Measure';
            Editable = false;
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(7; "Matched Quantity"; Decimal)
        {
            Caption = 'Matched Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;

            trigger OnValidate()
            begin
                if ("Matched Quantity" > Quantity) or ("Matched Quantity" < 0) then
                    Error(MatchedQtyErr);

                Validate("Fully Matched");
            end;
        }
        field(8; "Fully Matched"; Boolean)
        {
            Caption = 'Fully Matched';
            Editable = false;

            trigger OnValidate()
            begin
                "Fully Matched" := "Matched Quantity" = Quantity;
            end;
        }
        field(9; "Direct Unit Cost"; Decimal)
        {
            Caption = 'Direct Unit Cost';
            Editable = false;
        }
        field(10; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            Editable = false;
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(11; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(12; "Converted to Internal Notation"; Boolean)
        {
            Caption = 'Converted to Internal Notation';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "E-Document Entry No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        MatchedQtyErr: Label 'The Matched Quantity should not exceed Quantity and cannot be less than zero.';

    procedure DisplayMatches()
    var
        EDocOrderMatch: Record "E-Doc. Order Match";
    begin
        EDocOrderMatch.SetRange("E-Document Entry No.", Rec."E-Document Entry No.");
        EDocOrderMatch.SetRange("E-Document Line No.", Rec."Line No.");
        if not EDocOrderMatch.IsEmpty() then
            Page.Run(Page::"E-Doc. Order Match", EDocOrderMatch);
    end;

    procedure Insert(EDocument: Record "E-Document"; TempDocumentLine: RecordRef; var TempEDocImportedLine: Record "E-Doc. Imported Line" temporary; NoConvertedToInternalNotation: Boolean)
    var
        PurchaseLine: Record "Purchase Line";
        LineNo: Integer;
    begin
        if TempDocumentLine.Number <> Database::"Purchase Line" then
            exit;
        TempDocumentLine.SetTable(PurchaseLine);

        TempEDocImportedLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        LineNo := TempEDocImportedLine.GetNextLineNo();

        Clear(TempEDocImportedLine);
        TempEDocImportedLine."E-Document Entry No." := EDocument."Entry No";
        TempEDocImportedLine."Line No." := LineNo;
        TempEDocImportedLine."No." := PurchaseLine."No.";
        TempEDocImportedLine."Unit Of Measure Code" := PurchaseLine."Unit of Measure Code";

        if TempEDocImportedLine."No." = '' then begin
            TempEDocImportedLine."No." := CopyStr(PurchaseLine."Item Reference No.", 1, MaxStrLen(PurchaseLine."No."));
            TempEDocImportedLine."Unit Of Measure Code" := PurchaseLine."Item Reference Unit of Measure";
        end;
        TempEDocImportedLine."Converted to Internal Notation" := NoConvertedToInternalNotation;

        TempEDocImportedLine.Description := PurchaseLine.Description;
        TempEDocImportedLine.Type := PurchaseLine.Type;
        TempEDocImportedLine.Quantity := PurchaseLine.Quantity;
        TempEDocImportedLine."Direct Unit Cost" := PurchaseLine."Direct Unit Cost";
        TempEDocImportedLine."Line Discount %" := 100 * (PurchaseLine."Line Discount Amount" / (PurchaseLine.Amount + PurchaseLine."Line Discount Amount"));
        TempEDocImportedLine.Insert();
    end;

    internal procedure GetNextLineNo(): Integer
    begin
        if Rec.FindLast() then;
        exit(Rec."Line No." + 10000);
    end;

    procedure GetStyle() Result: Text
    begin
        if Rec."Fully Matched" then
            exit('Favorable');
        if Rec."Matched Quantity" > 0 then
            exit('Ambiguous');

        exit('None');
    end;

}