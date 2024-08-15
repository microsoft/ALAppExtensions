tableextension 6370 SignUpEDocCustomer extends Customer
{
    fields
    {
        field(6370; "SignUpService Participant Id"; Text[50]) // TODO: Use a common value from BC
        {
            DataClassification = CustomerContent;
            Caption = 'Service Participant Id';
        }
    }
}
