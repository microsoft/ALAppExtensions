tableextension 18807 "CompayInformationTCSExt" extends "Company Information"
{
    fields
    {
        field(18808; "Circle No."; text[30])
        {
            DataClassification = CustomerContent;
        }
        field(18809; "Assessing Officer"; text[30])
        {
            DataClassification = CustomerContent;
        }
        field(18810; "Ward No."; text[30])
        {
            DataClassification = CustomerContent;
        }
        field(18812; "T.C.A.N. No."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "T.C.A.N. No.";
        }
    }
}