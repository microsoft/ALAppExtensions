pageextension 5281 "Source Codes SAF-T" extends "Source Codes"
{
    layout
    {
        addlast(Control1)
        {
            field(SourceCodeSAFT; Rec."Source Code SAF-T")
            {
                ApplicationArea = Basic, Suite;
                Tooltip = 'Specifies the code that will be exported to the JournalID XML node in the SAF-T file.';
            }
        }
    }
}