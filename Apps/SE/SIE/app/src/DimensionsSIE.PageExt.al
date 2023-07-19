#if CLEAN22
pageextension 5325 "Dimensions SIE" extends Dimensions
{
    actions
    {
        addafter(Translations)
        {
                action("Dimensions SIE")
                {
                    ApplicationArea = Suite;
                    Caption = 'Dimensions SIE';
                    Image = UserInterface;
                    RunObject = Page "Dimensions SIE";
                    ToolTip = 'View or edit the dimensions to use when importing or exporting general ledger data in the SIE format for your company.';
                }
        }
    }
}
#endif