tableextension 11514 "Swiss QR-Bill Gen Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        field(11500; "Swiss QR-Bill"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}