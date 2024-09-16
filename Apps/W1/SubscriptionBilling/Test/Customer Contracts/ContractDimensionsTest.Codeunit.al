namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 139693 "Contract Dimensions Test"
{
    Subtype = Test;
    Access = Internal;

    var
        CustomerContract: Record "Customer Contract";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ContractTestLibrary: Codeunit "Contract Test Library";
        DimensionManagement: Codeunit DimensionManagement;

    [Test]
    procedure CheckCustomerContractDimensionValueCreatedAndAssigned()
    var
        DimensionValue: Record "Dimension Value";
        ServiceContractSetup: Record "Service Contract Setup";
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
    begin
        ClearAll();
        ContractTestLibrary.InitContractsApp();
        ServiceContractSetup.Get();
        if not ServiceContractSetup."Aut. Insert C. Contr. DimValue" then begin
            ServiceContractSetup."Aut. Insert C. Contr. DimValue" := true;
            ServiceContractSetup.Modify(false);
        end;

        ContractTestLibrary.CreateCustomerContract(CustomerContract, '');

        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Dimension Code Cust. Contr.");

        // check Dimension Value created
        DimensionValue.Get(GeneralLedgerSetup."Dimension Code Cust. Contr.", CustomerContract."No.");

        // check Dimension Value assigned
        CustomerContract.TestField("Dimension Set ID");
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, CustomerContract."Dimension Set ID");
        TempDimensionSetEntry.Get(CustomerContract."Dimension Set ID", GeneralLedgerSetup."Dimension Code Cust. Contr.");
        TempDimensionSetEntry.TestField("Dimension Value Code", CustomerContract."No.");
    end;
}