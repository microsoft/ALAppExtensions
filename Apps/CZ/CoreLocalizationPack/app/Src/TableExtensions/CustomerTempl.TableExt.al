tableextension 31037 "Customer Templ. CZL" extends "Customer Templ."
{
    fields
    {
        field(11772; "Validate Registration No. CZL"; Boolean)
        {
            Caption = 'Validate Registration No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Validate Registration No. CZL" then
                    TestField("Validate EU Vat Reg. No.", false);
            end;
        }
    }
}