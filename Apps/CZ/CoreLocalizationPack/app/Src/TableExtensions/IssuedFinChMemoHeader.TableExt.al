tableextension 11743 "Issued Fin.Ch. Memo Header CZL" extends "Issued Fin. Charge Memo Header"
{
    fields
    {
        field(11781; "Registration No. CZL"; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;
        }
        field(11782; "Tax Registration No. CZL"; Text[20])
        {
            Caption = 'Tax Registration No.';
            DataClassification = CustomerContent;
        }
    }
}
