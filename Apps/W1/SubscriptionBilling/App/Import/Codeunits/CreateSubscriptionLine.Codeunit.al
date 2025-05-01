namespace Microsoft.SubscriptionBilling;

codeunit 8006 "Create Subscription Line"
{
    TableNo = "Imported Subscription Line";

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
        if ImportedServiceCommitment."Subscription Line created" then
            exit(true);
    end;

    local procedure TestImportedServiceCommitment()
    var
        ServiceObject: Record "Subscription Header";
        ServiceCommitmentPackage: Record "Subscription Package";
    begin
        ImportedServiceCommitment.TestField("Subscription Header No.");
        if not ServiceObject.Get(ImportedServiceCommitment."Subscription Header No.") then
            Error(ServiceObjectDoesNotExistErr);
        DateFormulaManagement.ErrorIfDateEmpty(ImportedServiceCommitment."Subscription Line Start Date", ImportedServiceCommitment.FieldCaption("Subscription Line Start Date"));
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
        if ImportedServiceCommitment."Subscription Package Code" <> '' then
            ServiceCommitmentPackage.Get(ImportedServiceCommitment."Subscription Package Code");
        if ImportedServiceCommitment."Usage Based Pricing" <> "Usage Based Pricing"::None then
            ImportedServiceCommitment.TestField("Usage Based Billing", true);
        if ImportedServiceCommitment."Usage Based Billing" then
            ImportedServiceCommitment.TestField("Invoicing via", "Invoicing Via"::Contract);
        if ImportedServiceCommitment."Usage Based Pricing" <> "Usage Based Pricing"::"Unit Cost Surcharge" then
            ImportedServiceCommitment.TestField("Pricing Unit Cost Surcharge %", 0);
        OnAfterTestImportedSubscriptionLine(ImportedServiceCommitment);
    end;

    local procedure CreateServiceCommitment()
    var
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        ContractsItemManagement: Codeunit "Sub. Contracts Item Management";
    begin
        ServiceCommitment.Init();
        ServiceCommitment.Validate("Subscription Header No.", ImportedServiceCommitment."Subscription Header No.");
        if ImportedServiceCommitment."Subscription Line Entry No." <> 0 then
            ServiceCommitment."Entry No." := ImportedServiceCommitment."Subscription Line Entry No."
        else
            ServiceCommitment."Entry No." := 0;
        ServiceCommitment.SetSkipTestPackageCode(true);
        ServiceCommitment.Insert(true);
        OnAfterSubscriptionLineInsert(ServiceCommitment, ImportedServiceCommitment);

        ServiceCommitment."Invoicing via" := ImportedServiceCommitment."Invoicing via";
        if ImportedServiceCommitment."Invoicing Item No." <> '' then
            ServiceCommitment."Invoicing Item No." := ImportedServiceCommitment."Invoicing Item No."
        else
            if ServiceObject.Get(ServiceCommitment."Subscription Header No.") then
                if ServiceObject.IsItem() then
                    if ContractsItemManagement.IsServiceCommitmentItem(ServiceObject."Source No.") then
                        ServiceCommitment."Invoicing Item No." := ServiceObject."Source No.";
        ServiceCommitment.Template := ImportedServiceCommitment."Template Code";
        ServiceCommitment.Validate("Subscription Package Code", ImportedServiceCommitment."Subscription Package Code");
        ServiceCommitment.Partner := ImportedServiceCommitment.Partner;
        ServiceCommitment.Description := ImportedServiceCommitment.Description;
        ServiceCommitment.Validate("Extension Term", ImportedServiceCommitment."Extension Term");
        ServiceCommitment.Validate("Notice Period", ImportedServiceCommitment."Notice Period");
        ServiceCommitment.Validate("Initial Term", ImportedServiceCommitment."Initial Term");

        ServiceCommitment.Validate("Subscription Line Start Date", ImportedServiceCommitment."Subscription Line Start Date");
        ServiceCommitment.Validate("Subscription Line End Date", ImportedServiceCommitment."Subscription Line End Date");
        if ImportedServiceCommitment."Next Billing Date" <> 0D then
            ServiceCommitment."Next Billing Date" := ImportedServiceCommitment."Next Billing Date"
        else
            ServiceCommitment."Next Billing Date" := ImportedServiceCommitment."Subscription Line Start Date";
        ServiceCommitment.CheckServiceDates(ServiceCommitment."Subscription Line Start Date", ServiceCommitment."Subscription Line End Date", ServiceCommitment."Next Billing Date");
        ServiceCommitment.SetCurrencyData(ImportedServiceCommitment."Currency Factor", ImportedServiceCommitment."Currency Factor Date", ImportedServiceCommitment."Currency Code");

        ServiceCommitment."Usage Based Billing" := ImportedServiceCommitment."Usage Based Billing";
        ServiceCommitment."Usage Based Pricing" := ImportedServiceCommitment."Usage Based Pricing";
        ServiceCommitment."Pricing Unit Cost Surcharge %" := ImportedServiceCommitment."Pricing Unit Cost Surcharge %";
        ServiceCommitment."Supplier Reference Entry No." := ImportedServiceCommitment."Supplier Reference Entry No.";
        ServiceCommitment."Calculation Base Amount" := ImportedServiceCommitment."Calculation Base Amount";
        ServiceCommitment."Calculation Base %" := ImportedServiceCommitment."Calculation Base %";
        ServiceCommitment.CalculatePrice();

        if ImportedServiceCommitment."Discount %" <> 0 then
            ServiceCommitment.Validate("Discount %", ImportedServiceCommitment."Discount %");
        if ImportedServiceCommitment."Discount Amount" <> 0 then
            ServiceCommitment.Validate("Discount Amount", ImportedServiceCommitment."Discount Amount");
        if ImportedServiceCommitment.Amount <> 0 then
            ServiceCommitment.Validate(Amount, ImportedServiceCommitment.Amount);
        ServiceCommitment."Billing Base Period" := ImportedServiceCommitment."Billing Base Period";
        ServiceCommitment."Billing Rhythm" := ImportedServiceCommitment."Billing Rhythm";
        if ImportedServiceCommitment."Discount Amount (LCY)" <> 0 then
            ServiceCommitment."Discount Amount (LCY)" := ImportedServiceCommitment."Discount Amount (LCY)";
        if ImportedServiceCommitment."Amount (LCY)" <> 0 then
            ServiceCommitment."Amount (LCY)" := ImportedServiceCommitment."Amount (LCY)";
        if ImportedServiceCommitment."Calculation Base Amount (LCY)" <> 0 then
            ServiceCommitment."Calculation Base Amount (LCY)" := ImportedServiceCommitment."Calculation Base Amount (LCY)";

        ServiceCommitment.CalculateInitialTermUntilDate();
        if ServiceCommitment."Subscription Line End Date" = 0D then
            ServiceCommitment.CalculateInitialServiceEndDate();
        ServiceCommitment.CalculateInitialCancellationPossibleUntilDate();

        ServiceCommitment.SetDefaultDimensions(true);
        ServiceCommitment."Renewal Term" := ServiceCommitment."Initial Term";
        ServiceCommitment."Create Contract Deferrals" := ImportedServiceCommitment."Create Contract Deferrals";
        OnBeforeSubscriptionLineModify(ServiceCommitment, ImportedServiceCommitment);
        ServiceCommitment.SetSkipArchiving(true);
        ServiceCommitment.Modify(true);

        if ImportedServiceCommitment."Subscription Line Entry No." = 0 then
            ImportedServiceCommitment."Subscription Line Entry No." := ServiceCommitment."Entry No.";

        if ImportedServiceCommitment."Invoicing via" = "Invoicing Via"::Sales then
            ImportedServiceCommitment."Sub. Contract Line created" := true;
        ImportedServiceCommitment."Subscription Line created" := true;
        ImportedServiceCommitment.ClearErrorTextAndSetProcessedFields();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSubscriptionLineModify(var SubscriptionLine: Record "Subscription Line"; var ImportedServiceCommitment: Record "Imported Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSubscriptionLineInsert(var SubscriptionLine: Record "Subscription Line"; var ImportedServiceCommitment: Record "Imported Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestImportedSubscriptionLine(var ImportedSubscriptionLine: Record "Imported Subscription Line")
    begin
    end;

    var
        ImportedServiceCommitment: Record "Imported Subscription Line";
        DateFormulaManagement: Codeunit "Date Formula Management";
        ServiceObjectDoesNotExistErr: Label 'The Subscription does not exist. The Subscription Line was not created.';
        ValueShouldBeBetweenErr: Label '%1 value should be between %2 and %3.', Comment = '%1 = FieldCaption, %2 = minimum value, %3 = maximum value';
}