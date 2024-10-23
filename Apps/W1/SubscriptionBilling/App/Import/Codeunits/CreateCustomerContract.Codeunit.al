namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.NoSeries;

codeunit 8008 "Create Customer Contract"
{
    Access = Internal;
    TableNo = "Imported Customer Contract";

    trigger OnRun()
    begin
        ImportedCustomerContract := Rec;
        TestImportedCustomerContract();
        CreateCustomerContract();
        Rec := ImportedCustomerContract;
        Rec.Modify(true);
    end;

    local procedure TestImportedCustomerContract()
    begin
        ImportedCustomerContract.TestField("Contract created", false);
        ImportedCustomerContract.TestField("Contract No.");
        ImportedCustomerContract.TestField("Sell-to Customer No.");
        if ImportedCustomerContract."Contract No." <> '' then
            TestIfCustomerContractSeriesNoCanUseManualNos();
        OnAfterTestImportedCustomerContract(ImportedCustomerContract);
    end;

    local procedure TestIfCustomerContractSeriesNoCanUseManualNos()
    var
        NoSeries: Codeunit "No. Series";
    begin
        ServiceContractSetup.Get();
        ServiceContractSetup.TestField("Customer Contract Nos.");
        NoSeries.TestManual(ServiceContractSetup."Customer Contract Nos.");
    end;

    local procedure CreateCustomerContract()
    var
        CustomerContract: Record "Customer Contract";
    begin
        CustomerContract.Init();
        CustomerContract."No." := ImportedCustomerContract."Contract No.";
        CustomerContract.Insert(true);
        CustomerContract.SetHideValidationDialog(true);
        OnAfterCustomerContractInsert(CustomerContract, ImportedCustomerContract);


        if ImportedCustomerContract."Sell-to Customer No." <> '' then
            CustomerContract.Validate("Sell-to Customer No.", ImportedCustomerContract."Sell-to Customer No.");
        if ImportedCustomerContract."Sell-to Contact No." <> '' then
            CustomerContract.Validate("Sell-to Contact No.", ImportedCustomerContract."Sell-to Contact No.");
        if ImportedCustomerContract."Bill-to Customer No." <> '' then
            CustomerContract.Validate("Bill-to Customer No.", ImportedCustomerContract."Bill-to Customer No.");
        if ImportedCustomerContract."Bill-to Contact No." <> '' then
            CustomerContract.Validate("Bill-to Contact No.", ImportedCustomerContract."Bill-to Contact No.");
        if ImportedCustomerContract."Currency Code" <> '' then
            CustomerContract.Validate("Currency Code", ImportedCustomerContract."Currency Code");
        if ImportedCustomerContract."Ship-to Code" <> '' then
            CustomerContract.Validate("Ship-to Code", ImportedCustomerContract."Ship-to Code");
        if ImportedCustomerContract."Contract Type" <> '' then
            CustomerContract.Validate("Contract Type", ImportedCustomerContract."Contract Type");
        if ImportedCustomerContract.Description <> '' then
            CustomerContract.SetDescription(ImportedCustomerContract.Description);
        if ImportedCustomerContract."Your Reference" <> '' then
            CustomerContract.Validate("Your Reference", ImportedCustomerContract."Your Reference");
        if ImportedCustomerContract."Salesperson Code" <> '' then
            CustomerContract.Validate("Salesperson Code", ImportedCustomerContract."Salesperson Code");
        if ImportedCustomerContract."Assigned User ID" <> '' then
            CustomerContract.Validate("Assigned User ID", ImportedCustomerContract."Assigned User ID");

        CustomerContract."Without Contract Deferrals" := ImportedCustomerContract."Without Contract Deferrals";
        CustomerContract."Detail Overview" := ImportedCustomerContract."Detail Overview";
        if ImportedCustomerContract."Payment Terms Code" <> '' then
            CustomerContract.Validate("Payment Terms Code", ImportedCustomerContract."Payment Terms Code");
        if ImportedCustomerContract."Payment Method Code" <> '' then
            CustomerContract.Validate("Payment Method Code", ImportedCustomerContract."Payment Method Code");

        if ImportedCustomerContract."Dimension from Job No." <> '' then
            CustomerContract.Validate("Dimension from Job No.", ImportedCustomerContract."Dimension from Job No.");
        if ImportedCustomerContract."Shortcut Dimension 1 Code" <> '' then
            CustomerContract.Validate("Shortcut Dimension 1 Code", ImportedCustomerContract."Shortcut Dimension 1 Code");
        if ImportedCustomerContract."Shortcut Dimension 2 Code" <> '' then
            CustomerContract.Validate("Shortcut Dimension 2 Code", ImportedCustomerContract."Shortcut Dimension 2 Code");

        CustomerContract.Modify(true);
        OnAfterCustomerContractModify(CustomerContract, ImportedCustomerContract);

        ImportedCustomerContract."Contract created" := true;
        ImportedCustomerContract."Error Text" := '';
        ImportedCustomerContract."Processed at" := CurrentDateTime();
        ImportedCustomerContract."Processed by" := CopyStr(UserId(), 1, MaxStrLen(ImportedCustomerContract."Processed by"));
    end;


    [InternalEvent(false, false)]
    local procedure OnAfterCustomerContractInsert(var CustomerContract: Record "Customer Contract"; var ImportedCustomerContract: Record "Imported Customer Contract")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCustomerContractModify(var CustomerContract: Record "Customer Contract"; var ImportedCustomerContract: Record "Imported Customer Contract")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterTestImportedCustomerContract(ImportedCustomerContract: Record "Imported Customer Contract")
    begin
    end;

    var
        ImportedCustomerContract: Record "Imported Customer Contract";
        ServiceContractSetup: Record "Service Contract Setup";
}