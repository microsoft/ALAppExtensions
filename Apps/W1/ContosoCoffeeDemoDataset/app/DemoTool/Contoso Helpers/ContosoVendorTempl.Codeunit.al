codeunit 5661 "Contoso Vendor Templ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Vendor Templ." = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertVendorTempl(Code: Code[20]; Description: Text[100]; VendorPostingGroup: Code[20]; PaymentTermsCode: Code[10]; CountryRegionCode: Code[10]; PaymentMethodCode: Code[10]; PricesIncludingVAT: Boolean; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; ValidateEUVatRegNo: Boolean; ContactType: Enum "Contact Type")
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        VendorTempl: Record "Vendor Templ.";
        Exists: Boolean;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if VendorTempl.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VendorTempl.Validate(Code, Code);
        VendorTempl.Validate(Description, Description);
        VendorTempl.Validate("Vendor Posting Group", VendorPostingGroup);
        VendorTempl.Validate("Payment Terms Code", PaymentTermsCode);
        VendorTempl.Validate("Country/Region Code", CountryRegionCode);
        VendorTempl.Validate("Payment Method Code", PaymentMethodCode);
        VendorTempl.Validate("Prices Including VAT", PricesIncludingVAT);
        VendorTempl.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        if ContosoCoffeeDemoDataSetup."Company Type" <> ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then begin
            VendorTempl.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
            VendorTempl.Validate("Validate EU Vat Reg. No.", ValidateEUVatRegNo);
        end;
        VendorTempl.Validate("Contact Type", ContactType);

        if Exists then
            VendorTempl.Modify(true)
        else
            VendorTempl.Insert(true);
    end;
}