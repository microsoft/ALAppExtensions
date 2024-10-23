namespace Microsoft.SubscriptionBilling;

codeunit 8013 "Process Price Update"
{
    TableNo = "Contract Price Update Line";
    Access = Internal;

    trigger OnRun()
    begin
        ContractPriceUpdateLine.Copy(Rec);
        UpdateServiceCommitmentPrices();
        Rec := ContractPriceUpdateLine;
    end;

    local procedure UpdateServiceCommitmentPrices()
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        ServiceCommitment.Get(ContractPriceUpdateLine."Service Commitment Entry No.");
        ServiceCommitment.CalcFields("Planned Serv. Comm. exists");
        if ServiceCommitment."Planned Serv. Comm. exists" then
            exit;
        if ShouldPlannedServiceCommitmentBeCreated(ServiceCommitment) then
            CreatePlannedServiceCommitment(ServiceCommitment)
        else
            ServiceCommitment.UpdateServiceCommitmentFromContractPriceUpdateLine(ContractPriceUpdateLine);
    end;

    local procedure CreatePlannedServiceCommitment(ServiceCommitment: Record "Service Commitment")
    var
        PlannedServiceCommitment: Record "Planned Service Commitment";
        PriceUpdateTemplate: Record "Price Update Template";
    begin
        PlannedServiceCommitment.TransferFields(ServiceCommitment);
        PlannedServiceCommitment.Validate("Calculation Base %", ContractPriceUpdateLine."New Calculation Base %");
        PlannedServiceCommitment.Validate("Calculation Base Amount", ContractPriceUpdateLine."New Calculation Base");
        PlannedServiceCommitment.Validate(Price, ContractPriceUpdateLine."New Price");
        PlannedServiceCommitment.Validate("Service Amount", ContractPriceUpdateLine."New Service Amount");
        PlannedServiceCommitment."Next Price Update" := ContractPriceUpdateLine."Next Price Update";
        PlannedServiceCommitment."Type Of Update" := Enum::"Type Of Price Update"::"Price Update";
        PlannedServiceCommitment."Perform Update On" := ContractPriceUpdateLine."Perform Update On";
        if PriceUpdateTemplate.Get(ContractPriceUpdateLine."Price Update Template Code") then
            PlannedServiceCommitment."Price Binding Period" := PriceUpdateTemplate."Price Binding Period";
        PlannedServiceCommitment.Insert(false);
    end;

    local procedure ShouldPlannedServiceCommitmentBeCreated(ServiceCommitment: Record "Service Commitment"): Boolean
    begin
        if ContractPriceUpdateLine."Perform Update On" > ServiceCommitment."Next Billing Date" then
            exit(true);
        if ServiceCommitment.UnpostedDocumentExists() then
            exit(true);
        if (ServiceCommitment."Next Price Update" <> 0D) and (ServiceCommitment."Next Billing Date" < ServiceCommitment."Next Price Update") then
            exit(true);
        exit(false);
    end;

    var
        ContractPriceUpdateLine: Record "Contract Price Update Line";
}
