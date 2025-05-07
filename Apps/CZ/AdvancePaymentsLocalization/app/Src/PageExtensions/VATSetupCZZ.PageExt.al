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
                Enabled = UseForAdvanceEnable;
            }
        }
    }

    trigger OnOpenPage()
    begin
        UseForAdvanceEnable := NonDeductibleVATCZL.IsNonDeductibleVATEnabled();
    end;

    var
        NonDeductibleVATCZL: Codeunit "Non-Deductible VAT CZL";
        UseForAdvanceEnable: Boolean;
}
