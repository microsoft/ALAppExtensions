codeunit 5683 "Create Cont Job Responsibility"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure UpdateCustomerContactJobResposibility()
    var
        Customer: Record Customer;
        Contact: Record Contact;
        CreateJobResponsibility: Codeunit "Create Job Responsibility";
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        if Customer.FindSet() then
            repeat
                Contact.Get(Customer."Primary Contact No.");
                ContosoCRM.InsertContactJobResponsibility(Contact."No.", CreateJobResponsibility.Purchase());
            until Customer.Next() = 0;
    end;

    procedure UpdateVendorContactJobResposibility()
    var
        Vendor: Record Vendor;
        Contact: Record Contact;
        CreateJobResponsibility: Codeunit "Create Job Responsibility";
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        if Vendor.FindSet() then
            repeat
                Contact.Get(Vendor."Primary Contact No.");
                ContosoCRM.InsertContactJobResponsibility(Contact."No.", CreateJobResponsibility.Sale());
            until Vendor.Next() = 0;
    end;
}