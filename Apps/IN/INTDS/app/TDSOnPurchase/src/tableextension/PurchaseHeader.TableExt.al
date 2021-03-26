tableextension 18717 "Purchase Header" extends "Purchase Header"
{
    fields
    {
        field(18716; "Include GST in TDS Base"; Boolean)
        {
            Caption = 'Include GST in TDS Base';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PurchLine: Record "Purchase Line";
                CalculateTax: Codeunit "Calculate Tax";
            begin
                PurchLine.Reset();
                PurchLine.SetRange("Document Type", "Document Type");
                PurchLine.SetRange("Document No.", "No.");
                if PurchLine.FindSet() then
                    repeat
                        if PurchLine.Type <> PurchLine.Type::" " then
                            CalculateTax.CallTaxEngineOnPurchaseLine(PurchLine, PurchLine);
                    until PurchLine.Next() = 0;
            end;
        }
    }
}