tableextension 10018 "IRS 1096 Company Information" extends "Company Information"
{
    fields
    {
        field(10018; "EIN Number"; Code[10])
        {
            Caption = 'EIN Number';
        }
        field(10019; "IRS Contact No."; Code[20])
        {
            Caption = 'IRS Contact No.';
            TableRelation = Employee;
        }
    }
}