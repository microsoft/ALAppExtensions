codeunit 5116 "Create Job Customer Data"
{
    Permissions = tabledata Customer = ri,
        tabledata "Tax Area" = ri;

    trigger OnRun()
    begin
        JobsDemoDataSetup.Get();

        InsertCustomerData(JobsDemoDataSetup."Customer No.", CustomerLbl, JobsDemoDataSetup."Cust. Posting Group", JobsDemoDataSetup."Cust. Gen. Bus. Posting Group");
    end;

    var
        JobsDemoDataSetup: Record "Jobs Demo Data Setup";
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

        if JobsDemoDataSetup."Company Type" = JobsDemoDataSetup."Company Type"::"Sales Tax" then
            if TaxArea.FindFirst() then
                Customer.Validate("Tax Area Code", TaxArea.Code);

        if Customer."Customer Posting Group" = '' then
            Customer.Validate("Customer Posting Group", CustomerPostingGroup);
        if Customer."Gen. Bus. Posting Group" = '' then
            Customer.Validate("Gen. Bus. Posting Group", BusPostingGroup);
    end;

}