namespace Microsoft.eServices.EDocument;

using Microsoft.Finance.VAT.Setup;

tableextension 6103 "E-Document VAT Posting Setup" extends "VAT Posting Setup"
{
    fields
    {
        modify("Tax Category")
        {
            trigger OnAfterValidate()
            begin
                this.CheckStandardPeppolVATCategory();
                this.CheckNullPeppolVATCategory();
            end;
        }
    }

    var
        NullPeppolVatCategoryNoApplErr: Label 'Tax Category %1 cannot have 0 VAT.', Comment = '%1 = Tax Category Code';

    local procedure HasNullPeppolVATCategory(): Boolean
    begin
        exit(Rec."Tax Category" in [
            'Z', // Zero rated goods
            'E', // Exempt from tax
            'AE', // VAT reverse charge
            'K', // VAT exempt for EEA intra-community supply of goods and services
            'G' // Free export item, tax not charged
        ]);
    end;

    local procedure HasStandardPeppolVATCategory(): Boolean
    begin
        exit(Rec."Tax Category" = 'S');
    end;

    local procedure CheckNullPeppolVATCategory()
    var
        NullPeppolCateforyApplicableNotification: Notification;
    begin
        if this.HasNullPeppolVATCategory() and (Rec."VAT %" > 0) then
            Error(NullPeppolVatCategoryNoApplErr, Rec."Tax Category")
        else
            if not this.HasNullPeppolVATCategory() then begin
                NullPeppolCateforyApplicableNotification.Message := 'For 0 VAT, use one of the the standard PEPPOL VAT category codes. Z, E, AE, K or G';
                NullPeppolCateforyApplicableNotification.Scope := NotificationScope::LocalScope;
                NullPeppolCateforyApplicableNotification.Send();
            end
    end;

    local procedure CheckStandardPeppolVATCategory()
    begin
        if this.HasStandardPeppolVATCategory() and (Rec."VAT %" = 0) then
            Error(NullPeppolVatCategoryNoApplErr, Rec."Tax Category");
    end;
}
