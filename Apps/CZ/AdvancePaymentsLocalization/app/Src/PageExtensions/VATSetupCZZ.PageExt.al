pageextension 31235 "VAT Setup CZZ" extends "VAT Setup"
{
    layout
    {
        addlast(NonDeductibleVAT)
        {
            field(UseForAdvanceCZZ; Rec."Use For Advances CZZ")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}