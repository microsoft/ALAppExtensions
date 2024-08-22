tableextension 31067 "VAT Setup CZL" extends "VAT Setup"
{
    fields
    {
        field(11700; "Enable Non-Deductible VAT CZL"; Boolean)
        {
            Caption = 'Enable Non-Deductible VAT CZ';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ConfirmMgt: Codeunit "Confirm Management";
            begin
                TestField("Enable Non-Deductible VAT");
                if xRec."Enable Non-Deductible VAT CZL" and not "Enable Non-Deductible VAT CZL" then
                    TestField("Enable Non-Deductible VAT CZL", false);
                if not ConfirmMgt.GetResponse(UpdateAllowNonDeductibleVATQst, true) then
                    error('');
                NonDeductibleVATCZL.UpdateAllowNonDeductibleVAT();
                if ConfirmMgt.GetResponse(OpenNonDeductibleVATSetupQst, true) then
                    Page.RunModal(Page::"Non-Deductible VAT Setup CZL");
            end;
        }
    }

    var
        NonDeductibleVATCZL: Codeunit "Non-Deductible VAT CZL";
        UpdateAllowNonDeductibleVATQst: Label 'When you enable it the "Allow Non-Deductible VAT" field in the VAT Posting Setup table will be updated.\\Do you want to continue?';
        OpenNonDeductibleVATSetupQst: Label 'Do you want to open the Non-Deductible VAT Setup page to complete the activation CZ feature?';
}