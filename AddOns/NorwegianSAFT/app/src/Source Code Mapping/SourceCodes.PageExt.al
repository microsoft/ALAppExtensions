pageextension 10684 "SAF-T Source Codes" extends "Source Codes"
{
    layout
    {
        addlast(Control1)
        {
            field(SAFTSourceCode; "SAF-T Source Code")
            {
                ApplicationArea = Basic, Suite;
                Tooltip = 'Specified the code that will be exported to the JournalID XML node in the SAF-T file.';
            }
        }
    }
}