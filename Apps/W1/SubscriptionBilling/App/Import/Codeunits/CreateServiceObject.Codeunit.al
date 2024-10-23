namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Foundation.NoSeries;

codeunit 8005 "Create Service Object"
{
    Access = Internal;
    TableNo = "Imported Service Object";

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
        ImportedServiceObject.TestField("Service Object created", false);
        if ImportedServiceObject."Service Object No." <> '' then
            TestIfServiceObjectSeriesNoCanUseManualNos();
        ImportedServiceObject.TestField("Item No.");
        Item.Get(ImportedServiceObject."Item No.");
        if not (Item."Service Commitment Option" in ["Item Service Commitment Type"::"Service Commitment Item", "Item Service Commitment Type"::"Sales with Service Commitment"]) then
            Error(ItemServiceCommitmentOptionErr, "Item Service Commitment Type"::"Service Commitment Item", "Item Service Commitment Type"::"Sales with Service Commitment");
        if ImportedServiceObject."Quantity (Decimal)" <= 0 then
            Error(ImportedServiceObjectQuantityErr);
        OnAfterTestImportedServiceObject(ImportedServiceObject);
    end;

    local procedure TestIfServiceObjectSeriesNoCanUseManualNos()
    var
        NoSeries: Codeunit "No. Series";
    begin
        ServiceContractSetup.Get();
        ServiceContractSetup.TestField("Service Object Nos.");
        NoSeries.TestManual(ServiceContractSetup."Service Object Nos.");
    end;

    local procedure CreateServiceObject()
    var
        ServiceObject: Record "Service Object";
    begin
        ServiceObject.Init();
        ServiceObject."No." := ImportedServiceObject."Service Object No.";
        ServiceObject.Insert(true);
        ServiceObject.SkipInsertServiceCommitmentsFromStandardServCommPackages(true);
        ServiceObject.SetHideValidationDialog(true);
        OnAfterServiceObjectInsert(ServiceObject, ImportedServiceObject);

        ServiceObject.Validate("Item No.", ImportedServiceObject."Item No.");
        if ImportedServiceObject.Description <> '' then
            ServiceObject.Description := ImportedServiceObject.Description;
        ServiceObject.Validate("Quantity Decimal", ImportedServiceObject."Quantity (Decimal)");
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
        OnAfterServiceObjectModify(ServiceObject, ImportedServiceObject);

        ImportedServiceObject."Service Object No." := ServiceObject."No.";
        ImportedServiceObject."Service Object created" := true;
        ImportedServiceObject."Error Text" := '';
        ImportedServiceObject."Processed at" := CurrentDateTime();
        ImportedServiceObject."Processed by" := CopyStr(UserId(), 1, MaxStrLen(ImportedServiceObject."Processed by"));
    end;


    [InternalEvent(false, false)]
    local procedure OnAfterServiceObjectInsert(var ServiceObject: Record "Service Object"; var ImportedServiceObject: Record "Imported Service Object")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterServiceObjectModify(var ServiceObject: Record "Service Object"; var ImportedServiceObject: Record "Imported Service Object")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterTestImportedServiceObject(ImportedServiceObject: Record "Imported Service Object")
    begin
    end;

    var
        ImportedServiceObject: Record "Imported Service Object";
        ServiceContractSetup: Record "Service Contract Setup";
        ItemServiceCommitmentOptionErr: Label 'The Service Commitment Option must be "%1" or "%2".', Comment = '%1 = "Service Commitment Item", %2 = "Sales with Service Commitments"';
        ImportedServiceObjectQuantityErr: Label 'Quantity cannot be empty, 0 or negative.';
}