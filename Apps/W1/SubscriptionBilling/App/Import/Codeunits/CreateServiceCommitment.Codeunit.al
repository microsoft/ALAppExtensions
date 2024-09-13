namespace Microsoft.SubscriptionBilling;

codeunit 8006 "Create Service Commitment"
{
    Access = Internal;
    TableNo = "Imported Service Commitment";

    trigger OnRun()
    begin
        ImportedServiceCommitment := Rec;
        if SkipRun() then
            exit;
        TestImportedServiceCommitment();
        CreateServiceCommitment();
        Rec := ImportedServiceCommitment;
        Rec.Modify(true);
    end;

    local procedure SkipRun(): Boolean
    begin
        if ImportedServiceCommitment.IsContractCommentLine() then
            exit(true);
        if ImportedServiceCommitment."Service Commitment created" then
            exit(true);
    end;

    local procedure TestImportedServiceCommitment()
    var
        ServiceObject: Record "Service Object";
        ServiceCommitmentPackage: Record "Service Commitment Package";
    begin
        ImportedServiceCommitment.TestField("Service Object No.");
        if not ServiceObject.Get(ImportedServiceCommitment."Service Object No.") then
            Error(ServiceObjectDoesNotExistErr);
        DateFormulaManagement.ErrorIfDateEmpty(ImportedServiceCommitment."Service Start Date", ImportedServiceCommitment.FieldCaption("Service Start Date"));
        ImportedServiceCommitment.TestField("Calculation Base Amount");
        if (ImportedServiceCommitment."Calculation Base %" < 0) or (ImportedServiceCommitment."Calculation Base %" > 100) then
            Error(ValueShouldBeBetweenErr, ImportedServiceCommitment.FieldCaption("Calculation Base %"), 0, 100);
        if (ImportedServiceCommitment."Discount %" < 0) or (ImportedServiceCommitment."Discount %" > 100) then
            Error(ValueShouldBeBetweenErr, ImportedServiceCommitment.FieldCaption("Discount %"), 0, 100);
        DateFormulaManagement.ErrorIfDateFormulaEmpty(ImportedServiceCommitment."Billing Base Period", ImportedServiceCommitment.FieldCaption("Billing Base Period"));
        DateFormulaManagement.ErrorIfDateFormulaNegative(ImportedServiceCommitment."Billing Base Period");
        DateFormulaManagement.ErrorIfDateFormulaNegative(ImportedServiceCommitment."Notice Period");
        DateFormulaManagement.ErrorIfDateFormulaNegative(ImportedServiceCommitment."Initial Term");
        DateFormulaManagement.ErrorIfDateFormulaNegative(ImportedServiceCommitment."Extension Term");
        ImportedServiceCommitment.TestField("Billing Rhythm");
        DateFormulaManagement.ErrorIfDateFormulaNegative(ImportedServiceCommitment."Billing Rhythm");
        if ImportedServiceCommitment."Package Code" <> '' then
            ServiceCommitmentPackage.Get(ImportedServiceCommitment."Package Code");
        if ImportedServiceCommitment."Usage Based Pricing" <> "Usage Based Pricing"::None then
            ImportedServiceCommitment.TestField("Usage Based Billing", true);
        if ImportedServiceCommitment."Usage Based Billing" then
            ImportedServiceCommitment.TestField("Invoicing via", "Invoicing Via"::Contract);
        if ImportedServiceCommitment."Usage Based Pricing" <> "Usage Based Pricing"::"Unit Cost Surcharge" then
            ImportedServiceCommitment.TestField("Pricing Unit Cost Surcharge %", 0);
        OnAfterTestImportedServiceCommitment(ImportedServiceCommitment);
    end;

    local procedure CreateServiceCommitment()
    var
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
    begin
        ServiceCommitment.Init();
        ServiceCommitment.Validate("Service Object No.", ImportedServiceCommitment."Service Object No.");
        if ImportedServiceCommitment."Service Commitment Entry No." <> 0 then
            ServiceCommitment."Entry No." := ImportedServiceCommitment."Service Commitment Entry No."
        else
            ServiceCommitment."Entry No." := 0;
        ServiceCommitment.SetSkipTestPackageCode(true);
        ServiceCommitment.Insert(true);
        OnAfterServiceCommitmentInsert(ServiceCommitment, ImportedServiceCommitment);

        ServiceCommitment."Invoicing via" := ImportedServiceCommitment."Invoicing via";
        ServiceCommitment."Invoicing Item No." := ImportedServiceCommitment."Invoicing Item No.";
        ServiceCommitment.Template := ImportedServiceCommitment."Template Code";
        ServiceCommitment.Validate("Package Code", ImportedServiceCommitment."Package Code");
        ServiceCommitment.Partner := ImportedServiceCommitment.Partner;
        ServiceCommitment.Description := ImportedServiceCommitment.Description;
        ServiceCommitment.Validate("Extension Term", ImportedServiceCommitment."Extension Term");
        ServiceCommitment.Validate("Notice Period", ImportedServiceCommitment."Notice Period");
        ServiceCommitment.Validate("Initial Term", ImportedServiceCommitment."Initial Term");

        ServiceCommitment.Validate("Service Start Date", ImportedServiceCommitment."Service Start Date");
        ServiceCommitment.Validate("Service End Date", ImportedServiceCommitment."Service End Date");
        if ImportedServiceCommitment."Next Billing Date" <> 0D then
            ServiceCommitment."Next Billing Date" := ImportedServiceCommitment."Next Billing Date"
        else
            ServiceCommitment."Next Billing Date" := ImportedServiceCommitment."Service Start Date";
        ServiceCommitment.CheckServiceDates(ServiceCommitment."Service Start Date", ServiceCommitment."Service End Date", ServiceCommitment."Next Billing Date");
        ServiceCommitment.SetCurrencyData(ImportedServiceCommitment."Currency Factor", ImportedServiceCommitment."Currency Factor Date", ImportedServiceCommitment."Currency Code");

        ServiceCommitment."Calculation Base Amount" := ImportedServiceCommitment."Calculation Base Amount";
        ServiceCommitment."Calculation Base %" := ImportedServiceCommitment."Calculation Base %";
        ServiceCommitment.CalculatePrice();

        if ImportedServiceCommitment."Discount %" <> 0 then
            ServiceCommitment.Validate("Discount %", ImportedServiceCommitment."Discount %");
        if ImportedServiceCommitment."Discount Amount" <> 0 then
            ServiceCommitment.Validate("Discount Amount", ImportedServiceCommitment."Discount Amount");
        if ImportedServiceCommitment."Service Amount" <> 0 then
            ServiceCommitment.Validate("Service Amount", ImportedServiceCommitment."Service Amount");
        ServiceCommitment."Billing Base Period" := ImportedServiceCommitment."Billing Base Period";
        ServiceCommitment."Billing Rhythm" := ImportedServiceCommitment."Billing Rhythm";
        if ImportedServiceCommitment."Discount Amount (LCY)" <> 0 then
            ServiceCommitment."Discount Amount (LCY)" := ImportedServiceCommitment."Discount Amount (LCY)";
        if ImportedServiceCommitment."Service Amount (LCY)" <> 0 then
            ServiceCommitment."Service Amount (LCY)" := ImportedServiceCommitment."Service Amount (LCY)";
        if ImportedServiceCommitment."Calculation Base Amount (LCY)" <> 0 then
            ServiceCommitment."Calculation Base Amount (LCY)" := ImportedServiceCommitment."Calculation Base Amount (LCY)";

        ServiceCommitment.CalculateInitialTermUntilDate();
        if ServiceCommitment."Service End Date" = 0D then
            ServiceCommitment.CalculateInitialServiceEndDate();
        ServiceCommitment.CalculateInitialCancellationPossibleUntilDate();

        ServiceObject.Get(ServiceCommitment."Service Object No.");
        ServiceCommitment.SetDefaultDimensionFromItem(ServiceObject."Item No.");
        ServiceCommitment."Renewal Term" := ServiceCommitment."Initial Term";
        ServiceCommitment."Usage Based Billing" := ImportedServiceCommitment."Usage Based Billing";
        ServiceCommitment."Usage Based Pricing" := ImportedServiceCommitment."Usage Based Pricing";
        ServiceCommitment."Pricing Unit Cost Surcharge %" := ImportedServiceCommitment."Pricing Unit Cost Surcharge %";
        ServiceCommitment."Supplier Reference Entry No." := ImportedServiceCommitment."Supplier Reference Entry No.";
        OnBeforeServiceCommitmentModify(ServiceCommitment, ImportedServiceCommitment);
        ServiceCommitment.SetSkipArchiving(true);
        ServiceCommitment.Modify(true);

        if ImportedServiceCommitment."Service Commitment Entry No." = 0 then
            ImportedServiceCommitment."Service Commitment Entry No." := ServiceCommitment."Entry No.";

        if ImportedServiceCommitment."Invoicing via" = "Invoicing Via"::Sales then
            ImportedServiceCommitment."Contract Line created" := true;
        ImportedServiceCommitment."Service Commitment created" := true;
        ImportedServiceCommitment.ClearErrorTextAndSetProcessedFields();
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeServiceCommitmentModify(var ServiceCommitment: Record "Service Commitment"; var ImportedServiceCommitment: Record "Imported Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterServiceCommitmentInsert(var ServiceCommitment: Record "Service Commitment"; var ImportedServiceCommitment: Record "Imported Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterTestImportedServiceCommitment(var ImportedServiceCommitment: Record "Imported Service Commitment")
    begin
    end;

    var
        ImportedServiceCommitment: Record "Imported Service Commitment";
        DateFormulaManagement: Codeunit "Date Formula Management";
        ServiceObjectDoesNotExistErr: Label 'The Service Object does not exist. The Service Commitment was not created.';
        ValueShouldBeBetweenErr: Label '%1 value should be between %2 and %3.', Comment = '%1 = FieldCaption, %2 = minimum value, %3 = maximum value';
}