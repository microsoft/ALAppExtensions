tableextension 11794 "Responsibility Center CZL" extends "Responsibility Center" 
{
    fields
    {
        field(11720; "Default Bank Account Code CZL"; Code[20])
        {
            Caption = 'Default Bank Account Code';
            TableRelation = "Bank Account" where("Currency Code" = const(''));
            DataClassification = CustomerContent;
        }
    }
}
