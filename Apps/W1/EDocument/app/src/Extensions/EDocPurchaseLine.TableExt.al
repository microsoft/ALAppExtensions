#pragma warning disable AA0247
tableextension 6168 "E-Doc. Purchase Line" extends "Purchase Line"
{

    fields
    {
        modify("Amount Including VAT")
        {
            trigger OnAfterValidate()
            begin
                Validate("Amount Incl. VAT To Inv.");
            end;
        }
        field(6101; "Amount Incl. VAT To Inv."; Decimal)
        {
            Caption = 'Amount Incl. VAT To Inv.';
            Editable = false;
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                PurchaseHeader: Record "Purchase Header";
                Currency: Record Currency;
            begin
                GetPurchHeader(PurchaseHeader, Currency);
                "Amount Incl. VAT To Inv." := Round(
                    "Amount Including VAT" * "Qty. to Invoice" / Quantity,
                    Currency."Amount Rounding Precision")
            end;
        }

    }

    internal procedure GetStyle() Result: Text
    begin
        if Rec."Qty. Rcd. Not Invoiced" = 0 then
            exit('Subordinate');

        exit('None');
    end;

    internal procedure HasEDocMatch(EDocEntryNo: Integer): Boolean
    var
        EDocOrderMatch: Record "E-Doc. Order Match";
    begin
        EDocOrderMatch.SetRange("Document Order No.", Rec."Document No.");
        EDocOrderMatch.SetRange("Document Line No.", Rec."Line No.");
        EDocOrderMatch.SetRange("E-Document Entry No.", EDocEntryNo);
        exit(not EDocOrderMatch.IsEmpty());
    end;

}
