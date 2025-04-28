#pragma warning disable AA0247
codeunit 5256 "Create Sust. Vendor"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoUtility: Codeunit "Contoso Utilities";
        CreateVendorPostingGroup: Codeunit "Create Vendor Posting Group";
        ContosoCustomerVendor: Codeunit "Contoso Customer/Vendor";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreateVatPostingGroups: Codeunit "Create VAT Posting Groups";
        CreatePostingGroup: Codeunit "Create Posting Groups";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        ContosoCustomerVendor.InsertVendor(SustVendor64000(), SustVendor64000Lbl, CreateCountryRegion.US(), SustVendor64000Add1Lbl, '', SustVendor64000ZipLbl, '', CreateVendorPostingGroup.Domestic(), CreatePostingGroup.DomesticPostingGroup(), CreateVatPostingGroups.Domestic(), '', '', false, CreatePaymentTerms.PaymentTermsDAYS21(), '', ContosoUtility.EmptyPicture(), '', '', '', Enum::"Application Method"::Manual);
    end;

    var
        SustVendor64000Lbl: Label 'Hydropower Powerplant', MaxLength = 100;
        SustVendor64000Add1Lbl: Label '120 Day Drive', MaxLength = 100;
        SustVendor64000ZipLbl: Label '61236', MaxLength = 20;

    procedure SustVendor64000(): Code[20]
    begin
        exit('64000');
    end;
}
