tableextension 5280 "Company Contact SAF-T" extends "Company Information"
{
    fields
    {
        field(5280; "Contact No. SAF-T"; Code[20])
        {
            TableRelation = Employee;
        }
    }
}