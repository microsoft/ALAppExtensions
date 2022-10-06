tableextension 18000 "GST Bank Account Ext" extends "Bank Account"
{
    fields
    {
        field(18000; "State Code"; code[10])
        {
            Caption = 'State Code';
            DataClassification = CustomerContent;
            TableRelation = "state";
        }
        field(18001; "GST Registration Status"; Enum "Bank Registration Status")
        {
            Caption = 'GST Registration Status';
            DataClassification = CustomerContent;
        }
        field(18002; "GST Registration No."; code[20])
        {
            Caption = 'GST Registration No.';
            DataClassification = CustomerContent;
        }
        field(18003; "IFSC Code"; Text[20])
        {
            Caption = 'IFSC Code';
            DataClassification = CustomerContent;
        }
    }
}