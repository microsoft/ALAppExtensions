codeunit 4795 "Contoso Customer/Vendor"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Customer" = rim,
        tabledata "Vendor" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertCustomer(CustomerNo: Code[20]; CustomerName: Text[100]; CountryOrRegionCode: Code[10]; Address: Text[100]; PostCode: Code[20]; CurrencyCode: Code[10]; CustomerPostingGroup: Code[20]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; VATRegistrationNo: Text[20]; TaxAreaCode: Code[20]; TaxLiable: Boolean;
        CustomerDiscountGroup: Code[20]; PaymentTermsCode: Code[10]; GLN: Code[13]; Picture: Codeunit "Temp Blob")
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        Customer: Record Customer;
        ObjInStream: InStream;
        Exists: Boolean;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if Customer.Get(CustomerNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Customer.Validate("No.", CustomerNo);
        Customer.Validate(Name, CustomerName);

        Customer.Validate(Address, Address);
        Customer.Validate("Post Code", PostCode);

        Customer.Validate("Currency Code", CurrencyCode);
        Customer.Validate("Combine Shipments", true);
        Customer.Validate("Print Statements", true);

        Customer.Validate("Customer Disc. Group", CustomerDiscountGroup);
        Customer.Validate("Payment Terms Code", PaymentTermsCode);
        Customer.Validate(GLN, GLN);
        Customer.Validate("Credit Limit (LCY)", 0);
        Customer.Validate("Application Method", 1);
        Customer.Validate("Invoice Disc. Code", 'A');

        Customer.Validate("Customer Posting Group", CustomerPostingGroup);
        Customer.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::VAT then begin
            Customer.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
            Customer.Validate("VAT Registration No.", VATRegistrationNo);
        end else begin
            Customer.Validate("Tax Area Code", TaxAreaCode);
            Customer.Validate("Tax Liable", TaxLiable);
        end;

        // Needs to be after "VAT Registration No.", has check inside validation logic
        Customer.Validate("Country/Region Code", CountryOrRegionCode);

        if Picture.HasValue() then begin
            Picture.CreateInStream(ObjInStream);
            Customer.Image.ImportStream(ObjInStream, CustomerName);
        end;

        if Exists then
            Customer.Modify(true)
        else
            Customer.Insert(true);
    end;

    procedure InsertCustomer(CustomerNo: Code[20]; CustomerName: Text[100]; CountryOrRegionCode: Code[10]; Address: Text[100]; PostCode: Code[20]; CurrencyCode: Code[10]; CustomerPostingGroup: Code[20]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; VATRegistrationNo: Text[20]; TaxAreaCode: Code[20]; TaxLiable: Boolean)
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        InsertCustomer(CustomerNo, CustomerName, CountryOrRegionCode, Address, PostCode, CurrencyCode, CustomerPostingGroup, GenBusPostingGroup, VATBusPostingGroup, VATRegistrationNo, TaxAreaCode, TaxLiable, '', '', '', ContosoUtilities.EmptyPicture());
    end;

    procedure InsertVendor(VendorNo: Code[20]; VendorName: Text[100]; CountryOrRegionCode: Code[10]; Address: Text[100]; PostCode: Code[20]; CurrencyCode: Code[10]; VendorPostingGroup: Code[20]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; VATRegistrationNo: Text[20]; TaxAreaCode: Code[20]; TaxLiable: Boolean;
         PaymentTermsCode: Code[10]; GLN: Code[13]; Picture: Codeunit "Temp Blob")
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        Vendor: Record Vendor;
        ObjInStream: InStream;
        Exists: Boolean;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if Vendor.Get(VendorNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Vendor.Validate("No.", VendorNo);
        Vendor.Validate(Name, VendorName);
        Vendor.Validate(Address, Address);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate("Currency Code", CurrencyCode);

        Vendor.Validate(GLN, GLN);
        Vendor.Validate("Payment Method Code", PaymentTermsCode);
        Vendor.Validate("Application Method", 1);
        Vendor.Validate("Invoice Disc. Code", 'A');

        Vendor.Validate("Vendor Posting Group", VendorPostingGroup);
        Vendor.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::VAT then begin
            Vendor.Validate("VAT Registration No.", VATRegistrationNo);
            Vendor.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        end else begin
            Vendor.Validate("Tax Area Code", TaxAreaCode);
            Vendor.Validate("Tax Liable", TaxLiable);
        end;

        // Needs to be after "VAT Registration No.", has check inside validation logic
        Vendor.Validate("Country/Region Code", CountryOrRegionCode);

        if Picture.HasValue() then begin
            Picture.CreateInStream(ObjInStream);
            Vendor.Image.ImportStream(ObjInStream, VendorName);
        end;

        if Exists then
            Vendor.Modify(true)
        else
            Vendor.Insert(true);
    end;

    procedure InsertVendor(VendorNo: Code[20]; VendorName: Text[100]; CountryOrRegionCode: Code[10]; Address: Text[100]; PostCode: Code[20]; CurrencyCode: Code[10]; VendorPostingGroup: Code[20]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; VATRegistrationNo: Text[20]; TaxAreaCode: Code[20]; TaxLiable: Boolean)
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        InsertVendor(VendorNo, VendorName, CountryOrRegionCode, Address, PostCode, CurrencyCode, VendorPostingGroup, GenBusPostingGroup, VATBusPostingGroup, VATRegistrationNo, TaxAreaCode, TaxLiable, '', '', ContosoUtilities.EmptyPicture());
    end;
}