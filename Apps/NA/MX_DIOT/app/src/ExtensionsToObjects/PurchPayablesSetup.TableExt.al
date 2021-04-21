tableextension 27030 "DIOT Purch. & Payables Setup" extends "Purchases & Payables Setup"
{
    fields
    {
        field(27030; "Default Vendor DIOT Type"; Option)
        {
            Caption = 'Default Vendor DIOT Type';
            OptionMembers = " ","Prof. Services","Lease and Rent",Others;
            OptionCaption = ' ,Prof. Services,Lease and Rent,Others';

            trigger OnValidate()
            begin
                if "Default Vendor DIOT Type" = "Default Vendor DIOT Type"::"Lease and Rent" then
                    Message(LeaseAndRentMsg);
            end;
        }
    }

    var
        LeaseAndRentMsg: Label 'Non-Mexican vendors cannot have Lease and Rent as their DIOT operation type. This default will only work for MX vendors. The rest will have their type changed to Others.';

}