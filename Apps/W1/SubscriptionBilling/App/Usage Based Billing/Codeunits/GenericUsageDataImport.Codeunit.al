namespace Microsoft.SubscriptionBilling;

using System.IO;

codeunit 8025 "Generic Usage Data Import"
{
    Access = Internal;
    TableNo = "Usage Data Import";
    SingleInstance = true;

    trigger OnRun()
    begin
        case Rec."Processing Step" of
            Enum::"Processing Step"::"Create Imported Lines":
                ImportUsageData(Rec);
            Enum::"Processing Step"::"Process Imported Lines":
                ProcessUsageData(Rec);
        end;
    end;

    local procedure ImportUsageData(var UsageDataImport: Record "Usage Data Import")
    var
        UsageDataBlob: Record "Usage Data Blob";
        UsageDataGenericImport: Record "Usage Data Generic Import";
    begin
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.DeleteAll(false);

        UsageDataBlob.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataBlob.SetRange("Import Status", UsageDataBlob."Import Status"::Ok);
        if UsageDataBlob.FindSet() then
            repeat
                ImportUsageDataBlobToUsageDataGenericImport(UsageDataBlob, UsageDataImport);
            until UsageDataBlob.Next() = 0
        else begin
            UsageDataImport.SetErrorReason(StrSubstNo(NoDataFoundErr, UsageDataImport."Processing Step"));
            UsageDataImport.Modify(false);
        end;
    end;

    local procedure ImportUsageDataBlobToUsageDataGenericImport(UsageDataBlob: Record "Usage Data Blob"; var UsageDataImport: Record "Usage Data Import")
    var
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        GenericImportSettings: Record "Generic Import Settings";
    begin
        UsageDataImport.TestField("Supplier No.");
        GenericImportSettings.Get(UsageDataImport."Supplier No.");
        GenericImportSettings.TestField("Data Exchange Definition");
        DataExchDef.Get(GenericImportSettings."Data Exchange Definition");
        if (DataExchDef."Reading/Writing XMLport" <> 0) = (DataExchDef."Reading/Writing Codeunit" <> 0) then
            Error(ProcessingSetupErr);

        CreateDataExch(DataExch, UsageDataBlob, DataExchDef.Code);
        DataExch."Related Record" := UsageDataImport.RecordId;
        DataExch.Modify(false);
        DataExch.ImportToDataExch(DataExchDef);
        DataExchDef.ProcessDataExchange(DataExch);
        DataExch.Delete(true);

        OnAfterImportUsageDataBlobToUsageDataGenericImport(UsageDataBlob, UsageDataImport);
    end;

    local procedure CreateDataExch(var DataExch: Record "Data Exch."; UsageDataBlob: Record "Usage Data Blob"; DataExchDefCode: Code[20])
    var
        FileContentInStream: InStream;
    begin
        UsageDataBlob.CalcFields(Data);
        UsageDataBlob.Data.CreateInStream(FileContentInStream);
        DataExch.InsertRec(UsageDataBlob.Source, FileContentInStream, DataExchDefCode);
    end;

    local procedure ProcessUsageData(var UsageDataImport: Record "Usage Data Import")
    var
        UsageDataGenericImport: Record "Usage Data Generic Import";
        ServiceCommitment: Record "Service Commitment";
        GenericImportSettings: Record "Generic Import Settings";
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        ErrorCount: Integer;
    begin
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        if UsageDataGenericImport.FindSet() then
            repeat
                UsageDataGenericImport.Validate("Processing Status", Enum::"Processing Status"::None);
                ErrorIfUsageDataGenericImportQuantityIsZero(UsageDataGenericImport);
                GenericImportSettings.Get(UsageDataImport."Supplier No.");
                if GenericImportSettings."Create Customers" then
                    CreateUsageDataCustomer(UsageDataGenericImport, UsageDataSupplierReference, UsageDataImport."Supplier No.");
                if GenericImportSettings."Create Subscriptions" then
                    CreateUsageDataSubscription(UsageDataGenericImport, UsageDataSupplierReference, UsageDataImport."Supplier No.");

                if UsageDataGenericImport."Processing Status" <> Enum::"Processing Status"::Error then
                    CheckServiceCommitment(UsageDataGenericImport, UsageDataImport, ServiceCommitment);
                if UsageDataGenericImport."Processing Status" <> Enum::"Processing Status"::Error then
                    CheckAndAssignServiceObject(UsageDataGenericImport, ServiceCommitment);

                if UsageDataGenericImport."Processing Status" = "Processing Status"::Error then
                    ErrorCount += 1
                else
                    UsageDataGenericImport."Processing Status" := Enum::"Processing Status"::Ok;
                UsageDataGenericImport.Modify(false);
            until UsageDataGenericImport.Next() = 0
        else begin
            UsageDataImport.SetErrorReason(StrSubstNo(NoDataFoundErr, UsageDataImport."Processing Step"));
            UsageDataImport.Modify(false);
        end;

        if ErrorCount <> 0 then
            SetError(UsageDataImport, UsageDataLinesProcessingErr);
    end;

    local procedure CreateUsageDataCustomer(UsageDataGenericImport: Record "Usage Data Generic Import"; UsageDataSupplierReference: Record "Usage Data Supplier Reference"; SupplierNo: Code[20])
    var
        UsageDataCustomer: Record "Usage Data Customer";
    begin
        UsageDataGenericImport.TestField("Customer ID");
        UsageDataCustomer.SetRange("Supplier No.", SupplierNo);
        UsageDataCustomer.SetRange("Supplier Reference", UsageDataGenericImport."Customer ID");
        if UsageDataCustomer.IsEmpty() then begin
            UsageDataCustomer.Init();
            UsageDataCustomer."Entry No." := 0;
            UsageDataCustomer.Validate("Supplier No.", SupplierNo);
            UsageDataCustomer.Validate("Supplier Reference", UsageDataGenericImport."Customer ID");
            UsageDataSupplierReference.CreateSupplierReference(UsageDataCustomer."Supplier No.", UsageDataCustomer."Supplier Reference", Enum::"Usage Data Reference Type"::Customer);
            UsageDataCustomer."Supplier Reference Entry No." := UsageDataSupplierReference."Entry No.";
            UsageDataCustomer.Insert(true);
        end;
    end;

    local procedure CreateUsageDataSubscription(UsageDataGenericImport: Record "Usage Data Generic Import"; UsageDataSupplierReference: Record "Usage Data Supplier Reference"; SupplierNo: Code[20])
    var
        UsageDataSubscription: Record "Usage Data Subscription";
    begin
        UsageDataSubscription.SetRange("Supplier No.", SupplierNo);
        UsageDataSubscription.SetRange("Supplier Reference", UsageDataGenericImport."Subscription ID");
        if UsageDataSubscription.IsEmpty() then begin
            UsageDataSubscription.Init();
            UsageDataSubscription."Entry No." := 0;
            UsageDataSubscription.Validate("Supplier No.", SupplierNo);
            UsageDataSubscription.Validate("Supplier Reference", UsageDataGenericImport."Subscription ID");
            UsageDataSubscription.Validate("Customer ID", UsageDataGenericImport."Customer ID");
            UsageDataSubscription.Validate("Product ID", UsageDataGenericImport."Product ID");
            UsageDataSubscription.Validate("Product Name", UsageDataGenericImport."Product Name");
            UsageDataSubscription.Validate("Unit Type", UsageDataGenericImport.Unit);
            UsageDataSubscription.Validate(Quantity, UsageDataGenericImport.Quantity);
            UsageDataSubscription.Validate("Start Date", UsageDataGenericImport."Subscription Start Date");
            UsageDataSubscription.Validate("End Date", UsageDataGenericImport."Subscription End Date");
            UsageDataSupplierReference.CreateSupplierReference(SupplierNo, UsageDataSubscription."Supplier Reference", Enum::"Usage Data Reference Type"::Subscription);
            UsageDataSubscription."Supplier Reference Entry No." := UsageDataSupplierReference."Entry No.";
            if UsageDataSubscription."Product ID" <> '' then
                UsageDataSupplierReference.CreateSupplierReference(SupplierNo, UsageDataSubscription."Product ID", Enum::"Usage Data Reference Type"::Product);
            UsageDataSubscription.Insert(true);
        end;
    end;

    internal procedure GetServiceCommitmentForSubscription(SupplierNo: Code[20]; SubscriptionReference: Text[80]; var ServiceCommitment: Record "Service Commitment"): Boolean
    var
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
    begin
        UsageDataSupplierReference.FilterUsageDataSupplierReference(SupplierNo, SubscriptionReference, Enum::"Usage Data Reference Type"::Subscription);
        if not UsageDataSupplierReference.FindFirst() then
            exit;

        ServiceCommitment.Reset();
        ServiceCommitment.SetCurrentKey(ServiceCommitment."Service Start Date");
        ServiceCommitment.SetRange("Supplier Reference Entry No.", UsageDataSupplierReference."Entry No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        ServiceCommitment.SetRange("Service End Date", 0D);

        if ServiceCommitment.IsEmpty() then
            ServiceCommitment.SetRange("Service End Date");

        if ServiceCommitment.IsEmpty() then
            ServiceCommitment.SetRange(Partner);
        exit(ServiceCommitment.FindLast());
    end;

    local procedure SetError(var UsageDataImport: Record "Usage Data Import"; Reason: Text)
    begin
        UsageDataImport."Processing Status" := UsageDataImport."Processing Status"::Error;
        UsageDataImport.SetReason(Reason);
    end;

    local procedure CheckServiceCommitment(var UsageDataGenericImport: Record "Usage Data Generic Import"; var UsageDataImport: Record "Usage Data Import"; var ServiceCommitment: Record "Service Commitment")
    begin
        if GetServiceCommitmentForSubscription(UsageDataImport."Supplier No.", UsageDataGenericImport."Subscription ID", ServiceCommitment) then
            CheckIfServiceCommitmentStartDateIsValid(UsageDataGenericImport, ServiceCommitment)
        else
            SetErrorIfServiceCommitmentDoesNotExist(UsageDataGenericImport, ServiceCommitment);
    end;

    local procedure CheckAndAssignServiceObject(var UsageDataGenericImport: Record "Usage Data Generic Import"; ServiceCommitment: Record "Service Commitment")
    var
        ServiceObject: Record "Service Object";
    begin
        if ServiceCommitment."Service Object No." = '' then begin
            UsageDataGenericImport."Processing Status" := UsageDataGenericImport."Processing Status"::Error;
            UsageDataGenericImport.SetReason(StrSubstNo(NoServiceObjectErr, ServiceCommitment.TableCaption, ServiceCommitment."Entry No.", ServiceObject.TableCaption));
        end else begin
            ServiceObject.Get(ServiceCommitment."Service Object No.");
            if ServiceObject."Provision End Date" <> 0D then begin
                UsageDataGenericImport."Processing Status" := UsageDataGenericImport."Processing Status"::Error;
                UsageDataGenericImport.SetReason(StrSubstNo(ServiceObjectProvisionEndDateErr, ServiceObject.TableCaption, ServiceObject."No."));
            end else
                UsageDataGenericImport."Service Object No." := ServiceCommitment."Service Object No.";
        end;
    end;

    local procedure SetErrorIfServiceCommitmentDoesNotExist(var UsageDataGenericImport: Record "Usage Data Generic Import"; ServiceCommitment: Record "Service Commitment")
    begin
        UsageDataGenericImport."Processing Status" := UsageDataGenericImport."Processing Status"::Error;
        UsageDataGenericImport.SetReason(StrSubstNo(ReferenceNotFoundErr, UsageDataGenericImport.FieldCaption(UsageDataGenericImport."Subscription ID"),
                                                    UsageDataGenericImport."Subscription ID", ServiceCommitment.TableCaption));
    end;

    local procedure CheckIfServiceCommitmentStartDateIsValid(var UsageDataGenericImport: Record "Usage Data Generic Import"; ServiceCommitment: Record "Service Commitment")
    begin
        if ServiceCommitment."Service Start Date" <= UsageDataGenericImport."Billing Period Start Date" then
            exit;
        UsageDataGenericImport."Processing Status" := UsageDataGenericImport."Processing Status"::Error;
        UsageDataGenericImport.SetReason(StrSubstNo(NotValidServiceCommitmentErr, ServiceCommitment."Service Object No.", ServiceCommitment."Entry No."));
    end;

    local procedure ErrorIfUsageDataGenericImportQuantityIsZero(var UsageDataGenericImport: Record "Usage Data Generic Import")
    begin
        if UsageDataGenericImport.Quantity <> 0 then
            exit;
        UsageDataGenericImport."Processing Status" := UsageDataGenericImport."Processing Status"::Error;
        UsageDataGenericImport.SetReason(UsageDataWithZeroQuantityCannotBeProcessedErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process Data Exch.", 'OnProcessColumnMappingOnBeforeDataExchFieldMappingFindSet', '', false, false)]
    local procedure SetNextEntryNoForUsageDataGenericImport(var RecordRef: RecordRef; LastKeyFieldId: Integer; CurrLineNo: Integer)
    var
        UsageDataGenericImport: Record "Usage Data Generic Import";
        ProcessDataExch: Codeunit "Process Data Exch.";
    begin
        if RecordRef.Number <> Database::"Usage Data Generic Import" then
            exit;
        ProcessDataExch.SetFieldValue(RecordRef, LastKeyFieldId, UsageDataGenericImport.GetNextEntryNo());
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterImportUsageDataBlobToUsageDataGenericImport(UsageDataBlob: Record "Usage Data Blob"; var UsageDataImport: Record "Usage Data Import")
    begin
    end;

    var
        ProcessingSetupErr: Label 'You must specify either a reading/writing XMLport or a reading/writing codeunit.';
        ReferenceNotFoundErr: Label 'For %1 ''%2'' no linked %3 was found.';
        NoServiceObjectErr: Label 'The %1 ''%2'' is not linked to an %3.';
        ServiceObjectProvisionEndDateErr: Label 'The %1 ''%2'' is deinstalled.';
        UsageDataLinesProcessingErr: Label 'Errors were found while processing the Usage Data Lines.';
        NoDataFoundErr: Label 'No data found for processing step %1.', Comment = '%1=Name of the processing step';
        NotValidServiceCommitmentErr: Label 'Service Commitment %2 found for Service Object %1 is not valid. Please check the Service Commitment and adjust the validity of the Service if necessary.';
        UsageDataWithZeroQuantityCannotBeProcessedErr: Label 'Usage data with Quantity 0 cannot be processed.';
}