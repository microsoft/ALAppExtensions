codeunit 5106 "Create Svc Cust Data"
{
    Permissions = tabledata Customer = ri,
        tabledata "Tax Area" = ri;

    var
        DoRunTriggers: Boolean;

    trigger OnRun()
    begin
        DoRunTriggers := true;
        OnBeforeStartCreation(DoRunTriggers);
        SvcDemoDataSetup.Get();

        InsertCustomerData(SvcDemoDataSetup."Customer No.", CustomerLbl, SvcDemoDataSetup."Cust. Posting Group", SvcDemoDataSetup."Cust. Gen. Bus. Posting Group");
        OnAfterCreatedCustomers();
    end;

    var
        SvcDemoDataSetup: Record "Svc Demo Data Setup";
        CustomerLbl: Label 'Adatum Corporation', MaxLength = 30;

    local procedure InsertCustomerData("No.": Code[20]; Name: Text[30]; CustomerPostingGroup: Code[20]; BusPostingGroup: Code[20])
    var
        Customer: Record Customer;
        TaxArea: Record "Tax Area";
    begin
        if Customer.Get("No.") then
            exit;

        Customer.Init();

        Customer.Validate("No.", "No.");
        Customer.Validate(Name, Name);

        if SvcDemoDataSetup."Company Type" = SvcDemoDataSetup."Company Type"::"Sales Tax" then
            if TaxArea.FindFirst() then
                Customer.Validate("Tax Area Code", TaxArea.Code);

        if Customer."Customer Posting Group" = '' then
            Customer.Validate("Customer Posting Group", CustomerPostingGroup);
        if Customer."Gen. Bus. Posting Group" = '' then
            Customer.Validate("Gen. Bus. Posting Group", BusPostingGroup);

        OnBeforeCustomerInsert(Customer);
        Customer.Insert(DoRunTriggers);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCustomerInsert(var Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatedCustomers()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeStartCreation(var DoRunTriggers: Boolean)
    begin
    end;
}