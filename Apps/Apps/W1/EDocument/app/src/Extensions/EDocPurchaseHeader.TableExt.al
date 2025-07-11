#pragma warning disable AA0247
tableextension 6169 "E-Doc. Purchase Header" extends "Purchase Header"
{

    fields
    {
        field(6100; "E-Document Link"; Guid)
        {
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(6101; "Amount Incl. VAT To Inv."; Decimal)
        {
            CalcFormula = sum("Purchase Line"."Amount Incl. VAT To Inv." where("Document Type" = field("Document Type"),
                                                                            "Document No." = field("No.")));
            Caption = 'Amount Incl. VAT To Inv.';
            Editable = false;
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(EDocKey1; "E-Document Link")
        {
        }
    }

    internal procedure IsLinkedToEDoc(EDocumentToExclude: Record "E-Document"): Boolean
    begin
        exit(not IsNullGuid("E-Document Link") and ("E-Document Link" <> EDocumentToExclude.SystemId));
    end;

}
