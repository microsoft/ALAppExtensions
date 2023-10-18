codeunit 5116 "Create Common Customer/Vendor"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoCustomerVendor: Codeunit "Contoso Customer/Vendor";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        ContosoCustomerVendor.InsertCustomer(DomesticCustomer1(), LocalCustomerLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", '', '', '', CommonPostingGroup.Domestic(), CommonPostingGroup.Domestic(), CommonPostingGroup.Domestic(), '', '', false);
        ContosoCustomerVendor.InsertCustomer(DomesticCustomer2(), Customer20000NameLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", '', '', '', CommonPostingGroup.Domestic(), CommonPostingGroup.Domestic(), CommonPostingGroup.Domestic(), '', '', false);
        ContosoCustomerVendor.InsertCustomer(DomesticCustomer3(), Customer30000NameLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", '', '', '', CommonPostingGroup.Domestic(), CommonPostingGroup.Domestic(), CommonPostingGroup.Domestic(), '', '', false);

        ContosoCustomerVendor.InsertVendor(DomesticVendor1(), LocalVendorLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", '', '', '', CommonPostingGroup.Domestic(), CommonPostingGroup.Domestic(), CommonPostingGroup.Domestic(), '', '', false);
        ContosoCustomerVendor.InsertVendor(DomesticVendor2(), Vendor20000NameLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", '', '', '', CommonPostingGroup.Domestic(), CommonPostingGroup.Domestic(), CommonPostingGroup.Domestic(), '', '', false);
        ContosoCustomerVendor.InsertVendor(DomesticVendor3(), Vendor30000NameLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", '', '', '', CommonPostingGroup.Domestic(), CommonPostingGroup.Domestic(), CommonPostingGroup.Domestic(), '', '', false);
    end;

    var
        LocalVendorLbl: Label 'Fabrikam, Inc.', MaxLength = 100;
        Vendor20000NameLbl: Label 'First Up Consultants', MaxLength = 100;
        Vendor30000NameLbl: Label 'Graphic Design Institute', MaxLength = 100;
        LocalCustomerLbl: Label 'Adatum Corporation', MaxLength = 100;
        Customer20000NameLbl: Label 'Trey Research', MaxLength = 100;
        Customer30000NameLbl: Label 'School of Fine Art', MaxLength = 100;

    procedure DomesticVendor1(): Code[20]
    begin
        exit('10000');
    end;

    procedure DomesticVendor2(): Code[20]
    begin
        exit('20000');
    end;

    procedure DomesticVendor3(): Code[20]
    begin
        exit('30000');
    end;

    procedure DomesticCustomer1(): Code[20]
    begin
        exit('10000');
    end;

    procedure DomesticCustomer2(): Code[20]
    begin
        exit('20000');
    end;

    procedure DomesticCustomer3(): Code[20]
    begin
        exit('30000');
    end;
}
