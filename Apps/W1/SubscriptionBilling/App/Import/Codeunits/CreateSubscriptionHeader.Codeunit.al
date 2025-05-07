namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Foundation.NoSeries;

codeunit 8005 "Create Subscription Header"
{
    TableNo = "Imported Subscription Header";

    trigger OnRun()
    begin
        ImportedServiceObject := Rec;
        TestImportedServiceObject();
        CreateServiceObject();
        Rec := ImportedServiceObject;
        Rec.Modify(true);
    end;

    local procedure TestImportedServiceObject()
    var
        Item: Record Item;
    begin
        ImportedServiceObject.TestField("Subscription Header created", false);
        if ImportedServiceObject."Subscription Header No." <> '' then
            TestIfServiceObjectSeriesNoCanUseManualNos();
        ImportedServiceObject.TestField("Item No.");
        Item.Get(ImportedServiceObject."Item No.");
        if not (Item."Subscription Option" in ["Item Service Commitment Type"::"Service Commitment Item", "Item Service Commitment Type"::"Sales with Service Commitment"]) then
            Error(ItemServiceCommitmentOptionErr, "Item Service Commitment Type"::"Service Commitment Item", "Item Service Commitment Type"::"Sales with Service Commitment");
        if ImportedServiceObject."Quantity (Decimal)" <= 0 then
            Error(ImportedServiceObjectQuantityErr);
        OnAfterTestImportedSubscriptionHeader(ImportedServiceObject);
    end;

    local procedure TestIfServiceObjectSeriesNoCanUseManualNos()
    var
        NoSeries: Codeunit "No. Series";
    begin
        ServiceContractSetup.Get();
        ServiceContractSetup.TestField("Subscription Header No.");
        NoSeries.TestManual(ServiceContractSetup."Subscription Header No.");
    end;

    local procedure CreateServiceObject()
    var
        ServiceObject: Record "Subscription Header";
    begin
        ServiceObject.Init();
        ServiceObject."No." := ImportedServiceObject."Subscription Header No.";
        ServiceObject.Insert(true);
        ServiceObject.SkipInsertServiceCommitmentsFromStandardServCommPackages(true);
        ServiceObject.SetHideValidationDialog(true);
        OnAfterSubscriptionHeaderInsert(ServiceObject, ImportedServiceObject);

        ServiceObject.Type := ServiceObject.Type::Item;
        ServiceObject.Validate("Source No.", ImportedServiceObject."Item No.");
        if ImportedServiceObject.Description <> '' then
            ServiceObject.Description := ImportedServiceObject.Description;
        ServiceObject.Validate(Quantity, ImportedServiceObject."Quantity (Decimal)");
        if ImportedServiceObject."Unit of Measure" <> '' then
            ServiceObject.Validate("Unit of Measure", ImportedServiceObject."Unit of Measure");
        if ImportedServiceObject."Customer Reference" <> '' then
            ServiceObject.Validate("Customer Reference", ImportedServiceObject."Customer Reference");
        if ImportedServiceObject."Serial No." <> '' then
            ServiceObject.Validate("Serial No.", ImportedServiceObject."Serial No.");
        if ImportedServiceObject.Version <> '' then
            ServiceObject.Validate(Version, ImportedServiceObject.Version);
        if ImportedServiceObject."Key" <> '' then
            ServiceObject.Validate("Key", ImportedServiceObject."Key");
        if ImportedServiceObject."Provision Start Date" <> 0D then
            ServiceObject.Validate("Provision Start Date", ImportedServiceObject."Provision Start Date");
        if ImportedServiceObject."Provision End Date" <> 0D then
            ServiceObject.Validate("Provision End Date", ImportedServiceObject."Provision End Date");
        if ImportedServiceObject."End-User Customer No." <> '' then
            ServiceObject.Validate("End-User Customer No.", ImportedServiceObject."End-User Customer No.");
        if ImportedServiceObject."End-User Contact No." <> '' then
            ServiceObject.Validate("End-User Contact No.", ImportedServiceObject."End-User Contact No.");
        if ImportedServiceObject."Bill-to Customer No." <> '' then
            ServiceObject.Validate("Bill-to Customer No.", ImportedServiceObject."Bill-to Customer No.");
        if ImportedServiceObject."Bill-to Contact No." <> '' then
            ServiceObject.Validate("Bill-to Contact No.", ImportedServiceObject."Bill-to Contact No.");
        if ImportedServiceObject."Ship-to Code" <> '' then
            ServiceObject.Validate("Ship-to Code", ImportedServiceObject."Ship-to Code");
        ServiceObject.Modify(true);
        OnAfterSubscriptionHeaderModify(ServiceObject, ImportedServiceObject);

        ImportedServiceObject."Subscription Header No." := ServiceObject."No.";
        ImportedServiceObject."Subscription Header created" := true;
        ImportedServiceObject."Error Text" := '';
        ImportedServiceObject."Processed at" := CurrentDateTime();
        ImportedServiceObject."Processed by" := CopyStr(UserId(), 1, MaxStrLen(ImportedServiceObject."Processed by"));
    end;


    [IntegrationEvent(false, false)]
    local procedure OnAfterSubscriptionHeaderInsert(var SubscriptionHeader: Record "Subscription Header"; var ImportedSubscriptionHeader: Record "Imported Subscription Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSubscriptionHeaderModify(var SubscriptionHeader: Record "Subscription Header"; var ImportedSubscriptionHeader: Record "Imported Subscription Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTestImportedSubscriptionHeader(ImportedSubscriptionHeader: Record "Imported Subscription Header")
    begin
    end;

    var
        ImportedServiceObject: Record "Imported Subscription Header";
        ServiceContractSetup: Record "Subscription Contract Setup";
        ItemServiceCommitmentOptionErr: Label 'The Subscription Option must be "%1" or "%2".', Comment = '%1 = "Subscription Item", %2 = "Sales with Subscriptions"';
        ImportedServiceObjectQuantityErr: Label 'Quantity cannot be empty, 0 or negative.';
}