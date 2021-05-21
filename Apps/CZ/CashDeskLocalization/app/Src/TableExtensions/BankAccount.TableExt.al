tableextension 11778 "Bank Account CZP" extends "Bank Account"
{
    fields
    {
        field(11750; "Account Type CZP"; Enum "Bank Account Type CZP")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
