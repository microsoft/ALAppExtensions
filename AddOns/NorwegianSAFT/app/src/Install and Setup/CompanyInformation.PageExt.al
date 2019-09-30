pageextension 10689 "SAF-T Company Contact" extends "Company Information"
{
    layout
    {
        addlast(Communication)
        {
            field(SAFTContactNo; "SAF-T Contact No.")
            {
                ApplicationArea = Basic, Suite;
                Tooltip = 'Specifies the employee of the company whose information will be exported as the contact for the SAF-T file.';
            }
        }
    }
}