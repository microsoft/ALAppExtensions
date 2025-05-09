namespace Microsoft.SubscriptionBilling;

codeunit 8054 "Cust. Sub. Contr. Dim. Mgt."
{
    Access = Internal;

    var
        NoDimCodeForCustContractErr: Label 'Before Customer is selected you must set Dimension Code for Customer Contract in Subscription Contract Setup.';

    internal procedure AutomaticInsertCustomerContractDimensionValue(var CustomerContract: Record "Customer Subscription Contract")
    var
        ServiceContractSetup: Record "Subscription Contract Setup";
        DimensionMgt: Codeunit "Dimension Mgt.";
    begin
        ServiceContractSetup.Get();
        if ServiceContractSetup."Aut. Insert C. Contr. DimValue" then begin
            if ServiceContractSetup."Dimension Code Cust. Contr." = '' then
                Error(NoDimCodeForCustContractErr);
            DimensionMgt.CreateDimValue(
              ServiceContractSetup."Dimension Code Cust. Contr.",
              CustomerContract."No.",
              CustomerContract.GetDescription());
            DimensionMgt.AppendDimValue(ServiceContractSetup."Dimension Code Cust. Contr.", CustomerContract."No.", CustomerContract."Dimension Set ID");
        end;
    end;
}