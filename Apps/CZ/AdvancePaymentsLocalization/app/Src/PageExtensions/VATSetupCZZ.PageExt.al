#pragma warning disable AA0247
pageextension 31235 "VAT Setup CZZ" extends "VAT Setup"
{
    layout
    {
        addlast(NonDeductibleVAT)
        {
            field(UseForAdvanceCZZ; Rec."Use For Advances CZZ")
            {
                ApplicationArea = Basic, Suite;
                Enabled = Rec."Enable Non-Deductible VAT" and Rec."Enable Non-Deductible VAT CZL";
            }
        }
    }
}
