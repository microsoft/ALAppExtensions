#pragma warning disable AA0247
pageextension 14114 FinanceManagerRCExt extends "Finance Manager Role Center"
{
    actions
    {
        addafter("Incoming Documents")
        {
            action("Custom Declarations")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Custom Declarations';
                RunObject = page "Customs Declarations";
                Tooltip = 'Open the Customs Declarations page.';
            }
        }
    }
}
