tableextension 4854 "AutoAcc Invoice Posting Buffer" extends "Invoice Posting Buffer"
{
    fields
    {
        field(4850; "Automatic Account Group"; Code[10])
        {
            Caption = 'Automatic Account Group';
            DataClassification = SystemMetadata;
            TableRelation = "Automatic Account Header";
        }
    }
}
