codeunit 4795 "Contoso Customer/Vendor"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Customer" = rim,
        tabledata "Vendor" = rim,
        tabledata "Customer Bank Account" = rim,
        tabledata "Customer Discount Group" = rim,
        tabledata "Customer Templ." = rim,
        tabledata "Dispute Status" = rim,
        tabledata "Ship-to Address" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertCustomer(CustomerNo: Code[20]; CustomerName: Text[100]; CountryOrRegionCode: Code[10]; Address: Text[100]; Address2: Text[50];
                            PostCode: Code[20]; CurrencyCode: Code[10]; CustomerPostingGroup: Code[20]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20];
                            VATRegistrationNo: Text[20]; TaxAreaCode: Code[20]; TaxLiable: Boolean; PaymentTermsCode: Code[10]; Picture: Codeunit "Temp Blob";
                            DocumentSendingProfile: Code[20]; Contact: Text[100]; TerritoryCode: Code[10];
                            LanguageCode: Code[10]; SalespersonCode: Code[20]; EMail: Text[80]; ReminderTermsCode: Code[10])
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
        Customer.Validate("Address 2", Address2);
        Customer.Validate("Currency Code", CurrencyCode);
        Customer.Validate("Payment Terms Code", PaymentTermsCode);
        Customer.Validate("Credit Limit (LCY)", 0);
        Customer.Validate("Customer Posting Group", CustomerPostingGroup);
        Customer.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::VAT then begin
            Customer.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
            Customer.Validate("VAT Registration No.", VATRegistrationNo);
        end else begin
            Customer.Validate("Tax Area Code", TaxAreaCode);
            Customer.Validate("Tax Liable", TaxLiable);
        end;

        Customer.Validate("Document Sending Profile", DocumentSendingProfile);
        Customer.Validate("Territory Code", TerritoryCode);
        Customer.Validate("Language Code", LanguageCode);
        Customer.Validate("Salesperson Code", SalespersonCode);
        Customer.Validate("E-Mail", EMail);
        Customer.Validate("Reminder Terms Code", ReminderTermsCode);
        // Needs to be after "VAT Registration No.", has check inside validation logic
        Customer.Validate("Country/Region Code", CountryOrRegionCode);
        Customer.Validate("Post Code", PostCode);

        if Picture.HasValue() then begin
            Picture.CreateInStream(ObjInStream);
            Customer.Image.ImportStream(ObjInStream, CustomerName);
        end;

        if Exists then
            Customer.Modify(true)
        else
            Customer.Insert(true);

        Customer.Validate(Contact, Contact);
        Customer.Modify(true);
    end;

    procedure InsertCustomer(CustomerNo: Code[20]; CustomerName: Text[100]; CountryOrRegionCode: Code[10]; Address: Text[100]; PostCode: Code[20]; CurrencyCode: Code[10]; CustomerPostingGroup: Code[20]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; VATRegistrationNo: Text[20]; TaxAreaCode: Code[20]; TaxLiable: Boolean; CustomerDiscountGroup: Code[20]; PaymentTermsCode: Code[10]; GLN: Code[13]; Picture: Codeunit "Temp Blob")
    begin
        InsertCustomer(CustomerNo, CustomerName, CountryOrRegionCode, Address, '', PostCode, CurrencyCode, CustomerPostingGroup, GenBusPostingGroup, VATBusPostingGroup, VATRegistrationNo, TaxAreaCode, TaxLiable, '', Picture, '', '', '', '', '', '', '');
    end;

    procedure InsertCustomer(CustomerNo: Code[20]; CustomerName: Text[100]; CountryOrRegionCode: Code[10]; Address: Text[100]; PostCode: Code[20]; CurrencyCode: Code[10]; CustomerPostingGroup: Code[20]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; VATRegistrationNo: Text[20]; TaxAreaCode: Code[20]; TaxLiable: Boolean)
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        InsertCustomer(CustomerNo, CustomerName, CountryOrRegionCode, Address, '', PostCode, CurrencyCode, CustomerPostingGroup, GenBusPostingGroup, VATBusPostingGroup, VATRegistrationNo, TaxAreaCode, TaxLiable, '', ContosoUtilities.EmptyPicture(), '', '', '', '', '', '', '');
    end;

    procedure InsertVendor(VendorNo: Code[20]; VendorName: Text[100]; CountryOrRegionCode: Code[10]; Address: Text[100]; PostCode: Code[20]; CurrencyCode: Code[10]; VendorPostingGroup: Code[20]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; VATRegistrationNo: Text[20]; TaxAreaCode: Code[20]; TaxLiable: Boolean; PaymentTermsCode: Code[10]; GLN: Code[13]; Picture: Codeunit "Temp Blob")
    begin
        InsertVendor(VendorNo, VendorName, CountryOrRegionCode, Address, '', PostCode, CurrencyCode, VendorPostingGroup, GenBusPostingGroup, VATBusPostingGroup, VATRegistrationNo, TaxAreaCode, TaxLiable, '', '', Picture, '', '', '', Enum::"Application Method"::"Apply to Oldest");
    end;

    procedure InsertVendor(VendorNo: Code[20]; VendorName: Text[100]; CountryOrRegionCode: Code[10]; Address: Text[100]; Address2: Text[50]; PostCode: Code[20]; CurrencyCode: Code[10]; VendorPostingGroup: Code[20]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; VATRegistrationNo: Text[20]; TaxAreaCode: Code[20]; TaxLiable: Boolean; PaymentTermsCode: Code[10]; GLN: Code[13]; Picture: Codeunit "Temp Blob"; Contact: Text[100]; TerritoryCode: Code[10]; Email: Text[80]; ApplicationMethod: Enum "Application Method")
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
        Vendor.Validate("Address 2", Address2);
        Vendor.Validate("Currency Code", CurrencyCode);
        Vendor.Validate("Territory Code", TerritoryCode);
        Vendor.Validate("E-Mail", Email);
        Vendor.Validate(GLN, GLN);
        Vendor.Validate("Payment Terms Code", PaymentTermsCode);
        Vendor.Validate("Vendor Posting Group", VendorPostingGroup);
        Vendor.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Vendor.Validate("Application Method", ApplicationMethod);

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::VAT then begin
            Vendor.Validate("VAT Registration No.", VATRegistrationNo);
            Vendor.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        end else begin
            Vendor.Validate("Tax Area Code", TaxAreaCode);
            Vendor.Validate("Tax Liable", TaxLiable);
        end;

        // Needs to be after "VAT Registration No.", has check inside validation logic
        Vendor.Validate("Country/Region Code", CountryOrRegionCode);
        Vendor.Validate("Post Code", PostCode);

        if Picture.HasValue() then begin
            Picture.CreateInStream(ObjInStream);
            Vendor.Image.ImportStream(ObjInStream, VendorName);
        end;

        if Exists then
            Vendor.Modify(true)
        else
            Vendor.Insert(true);

        if Contact <> '' then begin
            Vendor.Validate(Contact, Contact);
            Vendor.Modify(true);
        end;
    end;

    procedure InsertVendor(VendorNo: Code[20]; VendorName: Text[100]; CountryOrRegionCode: Code[10]; Address: Text[100]; PostCode: Code[20]; CurrencyCode: Code[10]; VendorPostingGroup: Code[20]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; VATRegistrationNo: Text[20]; TaxAreaCode: Code[20]; TaxLiable: Boolean)
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        InsertVendor(VendorNo, VendorName, CountryOrRegionCode, Address, '', PostCode, CurrencyCode, VendorPostingGroup, GenBusPostingGroup, VATBusPostingGroup, VATRegistrationNo, TaxAreaCode, TaxLiable, '', '', ContosoUtilities.EmptyPicture(), '', '', '', Enum::"Application Method"::"Apply to Oldest");
    end;

    procedure InsertCustomerBankAccount(CustomerNo: Code[20]; Code: Code[20]; Name: Text[100]; Address: Text[100]; Contact: Text[100]; PhoneNo: Text[30]; BankBranchNo: Text[20]; BankAccountNo: Text[30]; FaxNo: Text[30]; LanguageCode: Code[10]; IBAN: Code[50])
    var
        CustomerBankAccount: Record "Customer Bank Account";
        Exists: Boolean;
    begin
        if CustomerBankAccount.Get(CustomerNo, Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CustomerBankAccount.Validate("Customer No.", CustomerNo);
        CustomerBankAccount.Validate(Code, Code);
        CustomerBankAccount.Validate(Name, Name);
        CustomerBankAccount.Validate(Address, Address);
        CustomerBankAccount.Validate(Contact, Contact);
        CustomerBankAccount.Validate("Phone No.", PhoneNo);
        CustomerBankAccount."Bank Branch No." := StrSubstNo(BankBranchNo, 1, 5);
        CustomerBankAccount."Bank Account No." := BankAccountNo;
        CustomerBankAccount.Validate("Fax No.", FaxNo);
        CustomerBankAccount.Validate("Language Code", LanguageCode);
        CustomerBankAccount.Validate(IBAN, IBAN);

        if Exists then
            CustomerBankAccount.Modify(true)
        else
            CustomerBankAccount.Insert(true);
    end;

    procedure InsertCustomerDiscountGroup(Code: Code[20]; Description: Text[100])
    var
        CustomerDiscountGroup: Record "Customer Discount Group";
        Exists: Boolean;
    begin
        if CustomerDiscountGroup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CustomerDiscountGroup.Validate(Code, Code);
        CustomerDiscountGroup.Validate(Description, Description);

        if Exists then
            CustomerDiscountGroup.Modify(true)
        else
            CustomerDiscountGroup.Insert(true);
    end;

    procedure InsertCustomerTempl(Code: Code[20]; Description: Text[100]; CustomerPostingGroup: Code[20]; PaymentTermsCode: Code[10]; CountryRegionCode: Code[10]; PaymentMethodCode: Code[10]; PricesIncludingVAT: Boolean; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; ContactType: Enum "Contact Type"; AllowLineDisc: Boolean; ValidateEUVATRegNo: Boolean)
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CustomerTempl: Record "Customer Templ.";
        Exists: Boolean;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if CustomerTempl.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CustomerTempl.Validate(Code, Code);
        CustomerTempl.Validate(Description, Description);
        CustomerTempl.Validate("Customer Posting Group", CustomerPostingGroup);
        CustomerTempl.Validate("Payment Terms Code", PaymentTermsCode);
        CustomerTempl.Validate("Country/Region Code", CountryRegionCode);
        CustomerTempl.Validate("Payment Method Code", PaymentMethodCode);
        CustomerTempl.Validate("Prices Including VAT", PricesIncludingVAT);
        CustomerTempl.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        if ContosoCoffeeDemoDataSetup."Company Type" <> ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            CustomerTempl.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        CustomerTempl.Validate("Contact Type", ContactType);
        CustomerTempl.Validate("Allow Line Disc.", AllowLineDisc);
        CustomerTempl.Validate("Validate EU Vat Reg. No.", ValidateEUVatRegNo);

        if Exists then
            CustomerTempl.Modify(true)
        else
            CustomerTempl.Insert(true);
    end;

    procedure InsertDisputeStatus(Code: Code[10]; Description: Text[100])
    var
        DisputeStatus: Record "Dispute Status";
        Exists: Boolean;
    begin
        if DisputeStatus.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        DisputeStatus.Validate(Code, Code);
        DisputeStatus.Validate(Description, Description);

        if Exists then
            DisputeStatus.Modify(true)
        else
            DisputeStatus.Insert(true);
    end;

    procedure InsertShiptoAddress(CustomerNo: Code[20]; Code: Code[10]; Name: Text[100]; Address: Text[100]; City: Text[30]; CountryRegionCode: Code[10]; PostCode: Code[20])
    var
        ShiptoAddress: Record "Ship-to Address";
        Exists: Boolean;
    begin
        if ShiptoAddress.Get(CustomerNo, Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ShiptoAddress.Validate("Customer No.", CustomerNo);
        ShiptoAddress.Validate(Code, Code);
        ShiptoAddress.Validate(Name, Name);
        ShiptoAddress.Validate(Address, Address);
        ShiptoAddress.Validate(City, City);
        ShiptoAddress.Validate("Country/Region Code", CountryRegionCode);
        ShiptoAddress.Validate("Post Code", PostCode);

        if Exists then
            ShiptoAddress.Modify(true)
        else
            ShiptoAddress.Insert(true);
    end;
}
