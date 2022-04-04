tableextension 10689 "Elec. VAT Posting Setup" extends "VAT Posting Setup"
{

    fields
    {
        modify("Sales SAF-T Standard Tax Code")
        {
            trigger OnAfterValidate()
            begin
                CheckVATRateMatch("Sales SAF-T Standard Tax Code");
            end;
        }
        modify("Purch. SAF-T Standard Tax Code")
        {
            trigger OnAfterValidate()
            begin
                CheckVATRateMatch("Purch. SAF-T Standard Tax Code");
            end;
        }
    }

    local procedure CheckVATRateMatch(VATCodeValue: Code[10])
    var
        VATCode: Record "VAT Code";
    begin
        if VATCodeValue = '' then
            exit;
        if not VATCode.Get(VATCodeValue) then
            exit;
        if not VATCode."Report VAT Rate" then
            exit;
        if VATCode."VAT Rate For Reporting" <> "VAT %" then
            Message(VATRateDoesNotMatchMsg, VATCode."VAT Rate For Reporting", "VAT %");
    end;

    var
        VATRateDoesNotMatchMsg: Label 'The VAT code you have selected has a VAT rate for reporting (%1 %) that is different than a VAT rate in the VAT posting setup (%2)', Comment = '%1,%2 = VAT rates/numbers';
}