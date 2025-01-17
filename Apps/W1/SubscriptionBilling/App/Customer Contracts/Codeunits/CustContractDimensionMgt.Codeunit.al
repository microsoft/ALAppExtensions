namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.GeneralLedger.Setup;

codeunit 8054 "Cust. Contract Dimension Mgt."
{
    Access = Internal;

    var
        NoDimCodeForCustContractErr: Label 'Before Customer is selected you must set Dimension Code for Customer Contract in General Ledger Setup.';

    procedure AutomaticInsertCustomerContractDimensionValue(var CustomerContract: Record "Customer Contract")
    var
        ServiceContractSetup: Record "Service Contract Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimensionMgt: Codeunit "Dimension Mgt.";
    begin
        ServiceContractSetup.Get();
        if ServiceContractSetup."Aut. Insert C. Contr. DimValue" then begin
            GeneralLedgerSetup.Get();
            if GeneralLedgerSetup."Dimension Code Cust. Contr." = '' then
                Error(NoDimCodeForCustContractErr);
            DimensionMgt.CreateDimValue(
              GeneralLedgerSetup."Dimension Code Cust. Contr.",
              CustomerContract."No.",
              CustomerContract.GetDescription());
            DimensionMgt.AppendDimValue(GeneralLedgerSetup."Dimension Code Cust. Contr.", CustomerContract."No.", CustomerContract."Dimension Set ID");
        end;
    end;
}