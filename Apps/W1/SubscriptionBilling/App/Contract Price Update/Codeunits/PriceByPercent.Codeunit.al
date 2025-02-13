namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Currency;

codeunit 8012 "Price By Percent" implements "Contract Price Update"
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
    var
        Currency: Record Currency;
    begin
        Currency.InitRoundingPrecision();
        NewContractPriceUpdateLine."New Calculation Base" := Round(NewContractPriceUpdateLine."Old Calculation Base" + NewContractPriceUpdateLine."Old Calculation Base" * UpdatePercentValue / 100, Currency."Amount Rounding Precision");
        NewContractPriceUpdateLine."New Price" := Round(NewContractPriceUpdateLine."Old Price" + NewContractPriceUpdateLine."Old Price" * UpdatePercentValue / 100, Currency."Unit-Amount Rounding Precision");
        NewContractPriceUpdateLine."New Service Amount" := Round(NewContractPriceUpdateLine."New Price" * NewContractPriceUpdateLine.Quantity, Currency."Amount Rounding Precision");
        NewContractPriceUpdateLine."New Calculation Base %" := NewContractPriceUpdateLine."Old Calculation Base %";
        NewContractPriceUpdateLine."Additional Service Amount" := NewContractPriceUpdateLine."New Service Amount" - NewContractPriceUpdateLine."Old Service Amount";
    end;
}
