namespace Microsoft.SubscriptionBilling;

using System.Utilities;

codeunit 8023 "Create Usage Data Billing"
{
    Access = Internal;
    TableNo = "Usage Data Import";

    trigger OnRun()
    begin
        UsageDataImport.Copy(Rec);
        Code();
        Rec := UsageDataImport;
    end;

    local procedure Code()
    begin
        UsageDataImport.SetFilter("Processing Status", '<>%1', Enum::"Processing Status"::Closed);
        if UsageDataImport.FindSet() then
            repeat
                CheckRetryFailedUsageLines();
                if not RetryFailedUsageDataGenericImportLines then
                    TestUsageDataImport();
                if not (UsageDataImport."Processing Status" = "Processing Status"::Error) then
                    FindAndProcessUsageDataGenericImport();
                if not (UsageDataImport."Processing Status" = "Processing Status"::Error) then
                    SetUsageDataImportError();
            until UsageDataImport.Next() = 0;
    end;

    local procedure CheckRetryFailedUsageLines()
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        UsageDataBilling.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        if not UsageDataBilling.IsEmpty() then
            if GuiAllowed then
                if ConfirmManagement.GetResponse(StrSubstNo(RetryFailedUsageDataGenericImportTxt, UsageDataImport."Entry No."), false) then
                    RetryFailedUsageDataGenericImportLines := true;
    end;

    local procedure FindAndProcessUsageDataGenericImport()
    var
        TempServiceCommitment: Record "Service Commitment" temporary;
    begin
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        if RetryFailedUsageDataGenericImportLines then
            UsageDataGenericImport.SetFilter("Processing Status", '<>%1', "Processing Status"::Ok);

        if UsageDataGenericImport.FindSet() then
            repeat
                CollectServiceCommitments(TempServiceCommitment);
                SetUsageDataGenericImportError('');
                if not CheckServiceCommitments(TempServiceCommitment) then
                    exit;
                CreateUsageDataBillingFromTempServiceCommitments(UsageDataGenericImport, TempServiceCommitment);
            until UsageDataGenericImport.Next() = 0
        else begin
            UsageDataImport.SetErrorReason(StrSubstNo(NoDataFoundErr, UsageDataImport."Processing Step"));
            UsageDataImport.Modify(false);
        end;
    end;

    local procedure CollectServiceCommitments(var TempServiceCommitment: Record "Service Commitment" temporary)
    begin
        FillTempServiceCommitment(TempServiceCommitment, UsageDataGenericImport."Service Object No.", UsageDataGenericImport."Subscription End Date");
    end;

    local procedure CreateUsageDataBillingFromTempServiceCommitments(SourceUsageDataGenericImport: Record "Usage Data Generic Import"; var TempServiceCommitment: Record "Service Commitment")
    begin
        repeat
            CreateUsageDataBillingFromTempServiceCommitment(SourceUsageDataGenericImport, TempServiceCommitment);
        until TempServiceCommitment.Next() = 0;
        OnAfterCreateUsageDataBillingFromTempServiceCommitments(SourceUsageDataGenericImport, TempServiceCommitment);
    end;

    local procedure CreateUsageDataBillingFromTempServiceCommitment(SourceUsageDataGenericImport: Record "Usage Data Generic Import"; var TempServiceCommitment: Record "Service Commitment")
    var
        UsageDataBilling: Record "Usage Data Billing";
        UsageDataSupplier: Record "Usage Data Supplier";
    begin
        OnBeforeCreateUsageDataBillingFromTempServiceCommitment(SourceUsageDataGenericImport, TempServiceCommitment);

        UsageDataSupplier.Get(UsageDataImport."Supplier No.");

        UsageDataBilling.InitFromUsageDataGenericImport(SourceUsageDataGenericImport);
        UsageDataBilling."Supplier No." := UsageDataImport."Supplier No.";
        UsageDataBilling."Service Object No." := TempServiceCommitment."Service Object No.";
        UsageDataBilling.Partner := TempServiceCommitment.Partner;
        UsageDataBilling."Contract No." := TempServiceCommitment."Contract No.";
        UsageDataBilling."Contract Line No." := TempServiceCommitment."Contract Line No.";
        UsageDataBilling."Service Object No." := TempServiceCommitment."Service Object No.";
        UsageDataBilling."Service Commitment Entry No." := TempServiceCommitment."Entry No.";
        UsageDataBilling."Service Commitment Description" := TempServiceCommitment.Description;
        UsageDataBilling."Usage Base Pricing" := TempServiceCommitment."Usage Based Pricing";
        UsageDataBilling."Pricing Unit Cost Surcharge %" := TempServiceCommitment."Pricing Unit Cost Surcharge %";
        if UsageDataBilling.IsPartnerVendor() or not UsageDataSupplier."Unit Price from Import" then begin
            UsageDataBilling."Unit Price" := 0;
            UsageDataBilling.Amount := 0;
        end;
        UsageDataBilling."Entry No." := 0;
        UsageDataBilling.Insert(true);

        OnAfterCreateUsageDataBillingFromTempServiceCommitment(SourceUsageDataGenericImport, TempServiceCommitment, UsageDataBilling);
    end;

    local procedure SetUsageDataGenericImportError(Reason: Text)
    begin
        if Reason = '' then
            UsageDataGenericImport."Processing Status" := UsageDataGenericImport."Processing Status"::Ok
        else
            UsageDataGenericImport."Processing Status" := UsageDataGenericImport."Processing Status"::Error;
        UsageDataGenericImport.SetReason(Reason);
        UsageDataGenericImport.Modify(false);
    end;

    local procedure CheckServiceCommitments(var TempServiceCommitment: Record "Service Commitment" temporary): Boolean
    var
        ServiceObject: Record "Service Object";
    begin
        TempServiceCommitment.Reset();
        TempServiceCommitment.SetRange("Contract No.", '');
        if TempServiceCommitment.FindFirst() then begin
            SetUsageDataGenericImportError(StrSubstNo(NoContractErr, TempServiceCommitment.TableCaption, TempServiceCommitment."Entry No.",
                                             ServiceObject.TableCaption, UsageDataGenericImport."Service Object No."));
            exit(false);
        end;

        TempServiceCommitment.Reset();
        if not TempServiceCommitment.FindSet() then begin
            SetUsageDataGenericImportError(StrSubstNo(NoServiceCommitmentWithUsageBasedFlagInServiceObjectErr, ServiceObject.TableCaption, UsageDataGenericImport."Service Object No.",
                                             TempServiceCommitment.TableCaption, TempServiceCommitment.FieldCaption("Usage Based Billing")));
            exit(false);
        end;

        exit(true);
    end;

    local procedure FillTempServiceCommitment(var TempServiceCommitment: Record "Service Commitment" temporary; ServiceObjectNo: Code[20]; SubscriptionEndDate: Date)
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        TempServiceCommitment.Reset();
        TempServiceCommitment.DeleteAll(false);
        ServiceCommitment.SetRange("Service Object No.", ServiceObjectNo);
        ServiceCommitment.SetFilter("Service End Date", '>=%1|%2', SubscriptionEndDate, 0D);
        ServiceCommitment.SetRange("Usage Based Billing", true);
        if ServiceCommitment.FindSet() then
            repeat
                if not TempServiceCommitment.Get(ServiceCommitment."Entry No.") then begin
                    TempServiceCommitment := ServiceCommitment;
                    TempServiceCommitment.Insert(false);
                end;
            until ServiceCommitment.Next() = 0;
    end;

    local procedure TestUsageDataImport()
    var
        UsageDataGenImport: Record "Usage Data Generic Import";
    begin
        UsageDataGenImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenImport.SetFilter("Processing Status", '<>%1', UsageDataGenImport."Processing Status"::Ok);
        if not UsageDataGenImport.IsEmpty() then begin
            UsageDataImport.SetErrorReason(StrSubstNo(UsageDataGenericImportWithErrorExistErr, UsageDataImport."Entry No."));
            UsageDataImport.Modify(false);
        end;
        UsageDataGenImport.SetRange("Processing Status");
        if UsageDataGenImport.IsEmpty() then begin
            UsageDataImport.SetErrorReason(StrSubstNo(NoDataFoundErr, UsageDataImport."Processing Step"));
            UsageDataImport.Modify(false);
        end;
    end;

    local procedure SetUsageDataImportError()
    begin
        UsageDataGenericImport.Reset();
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataGenericImport.SetRange("Processing Status", UsageDataGenericImport."Processing Status"::Error);
        if UsageDataGenericImport.IsEmpty() then begin
            UsageDataImport."Processing Status" := UsageDataImport."Processing Status"::Ok;
            UsageDataImport.SetReason('');
        end else
            UsageDataImport.SetErrorReason(UsageDataGenericImportProcessingErr);
        UsageDataImport.Modify(false);
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCreateUsageDataBillingFromTempServiceCommitment(SourceUsageDataGenericImport: Record "Usage Data Generic Import"; var TempServiceCommitment: Record "Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCreateUsageDataBillingFromTempServiceCommitment(SourceUsageDataGenericImport: Record "Usage Data Generic Import"; var TempServiceCommitment: Record "Service Commitment"; var UsageDataBilling: Record "Usage Data Billing")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCreateUsageDataBillingFromTempServiceCommitments(SourceUsageDataGenericImport: Record "Usage Data Generic Import"; var TempServiceCommitment: Record "Service Commitment")
    begin
    end;

    var
        UsageDataImport: Record "Usage Data Import";
        UsageDataGenericImport: Record "Usage Data Generic Import";
        ConfirmManagement: Codeunit "Confirm Management";
        UsageDataGenericImportProcessingErr: Label 'Errors were found while processing the Usage Data Generic Import.';
        NoServiceCommitmentWithUsageBasedFlagInServiceObjectErr: Label '%1 "%2" has no valid %3 with property "%4": Yes', Comment = '%1 = Service Object, %2 = Service Object No., %3 = Service Commitment, %4 = Usage Based Billing';
        NoContractErr: Label 'The %1 %2 in %3 "%4" has not been assigned to a Contract yet.', Comment = '%1 = Service Commitment, %2 = Service Commitment Entry No., %3 = Service Object, %4 = Service Object No.';
        RetryFailedUsageDataGenericImportTxt: Label 'Usage Data Billing for Import %1 already exist. Do you want to try to create new entries for the failed Usage Data Generic Import only?';
        UsageDataGenericImportWithErrorExistErr: Label 'Usage Data Billing for Import %1 already exist. They must be deleted before new Billing can be created.';
        NoDataFoundErr: Label 'No data found for processing step %1.', Comment = '%1=Name of the processing step';
        RetryFailedUsageDataGenericImportLines: Boolean;
}
