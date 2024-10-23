namespace Microsoft.SubscriptionBilling;

codeunit 8010 "Calculation Base By Perc" implements "Contract Price Update"
{
    Access = Internal;

    var
        PriceUpdateTemplate: Record "Price Update Template";
        ServiceCommitment: Record "Service Commitment";
        ContractPriceUpdateLine: Record "Contract Price Update Line";
        PriceUpdateManagement: Codeunit "Price Update Management";
        IncludeServiceCommitmentUpToDate: Date;
        PerformUpdateOnDate: Date;

    procedure SetPriceUpdateParameters(NewPriceUpdateTemplate: Record "Price Update Template"; NewIncludeServiceCommitmentUpToDate: Date; NewPerformUpdateOnDate: Date)
    begin
        PriceUpdateTemplate := NewPriceUpdateTemplate;
        IncludeServiceCommitmentUpToDate := NewIncludeServiceCommitmentUpToDate;
        PerformUpdateOnDate := NewPerformUpdateOnDate;
    end;

    procedure ApplyFilterOnServiceCommitments()
    begin
        PriceUpdateManagement.TestIncludeServiceCommitmentUpToDate(IncludeServiceCommitmentUpToDate);
        PriceUpdateManagement.GetAndApplyFiltersOnServiceCommitment(ServiceCommitment, PriceUpdateTemplate, IncludeServiceCommitmentUpToDate);
    end;

    procedure CreatePriceUpdateProposal()
    begin
        if ServiceCommitment.FindSet() then
            repeat
                if not ContractPriceUpdateLine.PriceUpdateLineExists(ServiceCommitment) then begin
                    ContractPriceUpdateLine.InitNewLine();
                    ContractPriceUpdateLine."Price Update Template Code" := PriceUpdateTemplate.Code;
                    ContractPriceUpdateLine.UpdatePerformUpdateOn(ServiceCommitment, PerformUpdateOnDate);
                    ContractPriceUpdateLine.UpdateFromServiceCommitment(ServiceCommitment);
                    ContractPriceUpdateLine.UpdateFromContract(ServiceCommitment.Partner, ServiceCommitment."Contract No.");
                    CalculateNewPrice(PriceUpdateTemplate."Update Value %", ContractPriceUpdateLine);
                    ContractPriceUpdateLine."Next Price Update" := CalcDate(PriceUpdateTemplate."Price Binding Period", ContractPriceUpdateLine."Perform Update On");
                    if ContractPriceUpdateLine.ShouldContractPriceUpdateLineBeInserted() then
                        ContractPriceUpdateLine.Insert(false)
                    else
                        ContractPriceUpdateLine.ShowContractPriceUpdateLineNotInsertedNotification();
                end;
            until ServiceCommitment.Next() = 0;
    end;

    internal procedure CalculateNewPrice(UpdatePercentValue: Decimal; var NewContractPriceUpdateLine: Record "Contract Price Update Line")
    begin
        NewContractPriceUpdateLine."New Calculation Base %" := UpdatePercentValue;
        NewContractPriceUpdateLine."New Calculation Base" := NewContractPriceUpdateLine."Old Calculation Base";
        NewContractPriceUpdateLine.CalculateNewPrice();
    end;
}
