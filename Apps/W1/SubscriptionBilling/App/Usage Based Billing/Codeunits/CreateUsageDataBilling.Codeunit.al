namespace Microsoft.SubscriptionBilling;

using System.Utilities;

codeunit 8023 "Create Usage Data Billing"
{
    TableNo = "Usage Data Import";

    var
        UsageDataProcessing: Interface "Usage Data Processing";

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
                if not RetryFailedUsageDataImport then
                    TestUsageDataImport();
                if not (UsageDataImport."Processing Status" = "Processing Status"::Error) then
                    FindAndProcessUsageDataImport();
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
                if ConfirmManagement.GetResponse(StrSubstNo(RetryFailedUsageDataImportTxt, UsageDataImport."Entry No."), false) then
                    RetryFailedUsageDataImport := true;
    end;

    local procedure FindAndProcessUsageDataImport()
    var
        UsageDataSupplier: Record "Usage Data Supplier";
    begin
        UsageDataSupplier.Get(UsageDataImport."Supplier No.");
        UsageDataProcessing := UsageDataSupplier.Type;
        UsageDataProcessing.FindAndProcessUsageDataImport(UsageDataImport);
    end;

    internal procedure CollectServiceCommitments(var TempServiceCommitment: Record "Subscription Line" temporary; ServiceObjectNo: Code[20]; SubscriptionEndDate: Date)
    begin
        FillTempServiceCommitment(TempServiceCommitment, ServiceObjectNo, SubscriptionEndDate);
        OnAfterCollectServiceCommitments(TempServiceCommitment, ServiceObjectNo, SubscriptionEndDate);
    end;

    internal procedure CreateUsageDataBillingFromTempServiceCommitments(var TempServiceCommitment: Record "Subscription Line"; SupplierNo: Code[20]; UsageDataImportEntryNo: Integer; ServiceObjectNo: Code[20]; BillingPeriodStartDate: Date;
                        BillingPeriodEndDate: Date; UnitCost: Decimal; NewQuantity: Decimal; CostAmount: Decimal; UnitPrice: Decimal; NewAmount: Decimal; CurrencyCode: Code[10])
    begin
        repeat
            CreateUsageDataBillingFromTempServiceCommitment(TempServiceCommitment, SupplierNo, UsageDataImportEntryNo, ServiceObjectNo, BillingPeriodStartDate, BillingPeriodEndDate, UnitCost, NewQuantity, CostAmount, UnitPrice, NewAmount, CurrencyCode);
        until TempServiceCommitment.Next() = 0;
        OnAfterCreateUsageDataBillingFromTempSubscriptionLines(TempServiceCommitment);
    end;

    local procedure CreateUsageDataBillingFromTempServiceCommitment(var TempServiceCommitment: Record "Subscription Line"; SupplierNo: Code[20]; UsageDataImportEntryNo: Integer; ServiceObjectNo: Code[20]; BillingPeriodStartDate: Date;
                        BillingPeriodEndDate: Date; UnitCost: Decimal; NewQuantity: Decimal; CostAmount: Decimal; UnitPrice: Decimal; NewAmount: Decimal; CurrencyCode: Code[10])
    var
        UsageDataBilling: Record "Usage Data Billing";
        UsageDataSupplier: Record "Usage Data Supplier";
    begin
        UsageDataSupplier.Get(SupplierNo);

        UsageDataBilling.InitFrom(UsageDataImportEntryNo, ServiceObjectNo, BillingPeriodStartDate, BillingPeriodEndDate, UnitCost, NewQuantity, CostAmount, UnitPrice, NewAmount, CurrencyCode);
        UsageDataBilling."Supplier No." := SupplierNo;
        UsageDataBilling."Subscription Header No." := TempServiceCommitment."Subscription Header No.";
        UsageDataBilling.Partner := TempServiceCommitment.Partner;
        UsageDataBilling."Subscription Contract No." := TempServiceCommitment."Subscription Contract No.";
        UsageDataBilling."Subscription Contract Line No." := TempServiceCommitment."Subscription Contract Line No.";
        UsageDataBilling."Subscription Header No." := TempServiceCommitment."Subscription Header No.";
        UsageDataBilling."Subscription Line Entry No." := TempServiceCommitment."Entry No.";
        UsageDataBilling."Subscription Line Description" := TempServiceCommitment.Description;
        UsageDataBilling."Usage Base Pricing" := TempServiceCommitment."Usage Based Pricing";
        UsageDataBilling."Pricing Unit Cost Surcharge %" := TempServiceCommitment."Pricing Unit Cost Surcharge %";
        if UsageDataBilling.IsPartnerVendor() or not UsageDataSupplier."Unit Price from Import" then begin
            UsageDataBilling."Unit Price" := 0;
            UsageDataBilling.Amount := 0;
        end;
        UsageDataBilling.UpdateRebilling();
        UsageDataBilling."Entry No." := 0;
        UsageDataBilling.Insert(true);
        UsageDataBilling.InsertMetadata();

        OnAfterCreateUsageDataBillingFromTempSubscriptionLine(TempServiceCommitment, UsageDataBilling);
    end;

    local procedure FillTempServiceCommitment(var TempServiceCommitment: Record "Subscription Line" temporary; ServiceObjectNo: Code[20]; SubscriptionEndDate: Date)
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        TempServiceCommitment.Reset();
        TempServiceCommitment.DeleteAll(false);
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObjectNo);
        ServiceCommitment.SetFilter("Subscription Line End Date", '>=%1|%2', SubscriptionEndDate, 0D);
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
        UsageDataSupplier: Record "Usage Data Supplier";
    begin
        UsageDataSupplier.Get(UsageDataImport."Supplier No.");
        UsageDataProcessing := UsageDataSupplier.Type;
        UsageDataProcessing.TestUsageDataImport(UsageDataImport);
    end;

    local procedure SetUsageDataImportError()
    begin
        UsageDataProcessing.SetUsageDataImportError(UsageDataImport);
    end;

    internal procedure GetRetryFailedUsageDataImport(): Boolean
    begin
        exit(RetryFailedUsageDataImport);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateUsageDataBillingFromTempSubscriptionLine(var TempSubscriptionLine: Record "Subscription Line"; var UsageDataBilling: Record "Usage Data Billing")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateUsageDataBillingFromTempSubscriptionLines(var TempSubscriptionLine: Record "Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCollectServiceCommitments(var TempSubscriptionLine: Record "Subscription Line" temporary; SubscriptionHeaderNo: Code[20]; SubscriptionLineEndDate: Date)
    begin
    end;

    var
        UsageDataImport: Record "Usage Data Import";
        ConfirmManagement: Codeunit "Confirm Management";
        RetryFailedUsageDataImportTxt: Label 'Usage Data Billing for Import %1 already exist. Do you want to try to create new entries for the failed Usage Data Generic Import only?', Comment = '%1=Usage Data Import Entry No.';
        RetryFailedUsageDataImport: Boolean;
}
