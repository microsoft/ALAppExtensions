#if CLEAN22
pageextension 5319 "Finance Manager RC SIE" extends "Finance Manager Role Center"
{
    actions
    {
        addafter("Group1")
        {
            group("SIE")
            {
                Caption = 'SIE';
                action("Import SIE")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import SIE';
                    RunObject = report "Import SIE";
                    Tooltip = 'Run the Import SIE report.';
                }
                action("Export SIE")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'SIE Export';
                    Tooltip = 'SIE export functionality was moved to the SIE extension. To create a file, you must run export from the audit file export document with the SIE export format selected.';
                    RunObject = page "Audit File Export Documents";
                }
                action("Dimensions SIE")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions SIE';
                    RunObject = page "Dimensions SIE";
                    Tooltip = 'Open the Dimensions SIE page.';
                }
            }
        }
    }
}
#endif