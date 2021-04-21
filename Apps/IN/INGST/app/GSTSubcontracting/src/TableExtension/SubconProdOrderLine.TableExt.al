tableextension 18469 "Subcon Prod. Order Line" extends "Prod. Order Line"
{
    fields
    {
        field(18451; "Subcontracting Order No."; Code[20])
        {
            Caption = 'Subcontracting Order No.';
            Editable = false;
            TableRelation = "Purchase Header"."No." where(
                "Document Type" = const(1),
                "No." = field("Subcontracting Order No."),
                Subcontracting = const(true));
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18452; "Subcontractor Code"; Code[20])
        {
            Caption = 'Subcontractor Code';
            Editable = false;
            TableRelation = Vendor."No." where(Subcontractor = const(true));
            DataClassification = EndUserIdentifiableInformation;
        }
    }
}