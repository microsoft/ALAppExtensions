tableextension 31264 "Capacity Ledger Entry CZA" extends "Capacity Ledger Entry"
{
    fields
    {
        field(31005; "User ID CZA"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
    }
}
