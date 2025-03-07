namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.Dimension;

codeunit 139693 "Contract Dimensions Test"
{
    Subtype = Test;
    Access = Internal;

    var
        CustomerContract: Record "Customer Subscription Contract";
        ServiceContractSetup: Record "Subscription Contract Setup";
        ContractTestLibrary: Codeunit "Contract Test Library";
        DimensionManagement: Codeunit DimensionManagement;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        IsInitialized: Boolean;

    #region Tests

    [Test]
    procedure CheckCustomerContractDimensionValueCreatedAndAssigned()
    var
        DimensionValue: Record "Dimension Value";
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
    begin
        Initialize();

        // [WHEN] Auto Insert Customer Subscription Contract Dimension Value is enabled
        ContractTestLibrary.SetAutomaticDimensions(true);

        // [WHEN] Customer Subscription Contract dimension value is created
        ContractTestLibrary.InsertCustomerContractDimensionCode();

        ContractTestLibrary.CreateCustomerContract(CustomerContract, '');

        ServiceContractSetup.Get();
        ServiceContractSetup.TestField("Dimension Code Cust. Contr.");

        // check Dimension Value created
        DimensionValue.Get(ServiceContractSetup."Dimension Code Cust. Contr.", CustomerContract."No.");

        // check Dimension Value assigned
        CustomerContract.TestField("Dimension Set ID");
        DimensionManagement.GetDimensionSet(TempDimensionSetEntry, CustomerContract."Dimension Set ID");
        TempDimensionSetEntry.Get(CustomerContract."Dimension Set ID", ServiceContractSetup."Dimension Code Cust. Contr.");
        TempDimensionSetEntry.TestField("Dimension Value Code", CustomerContract."No.");
    end;

    #endregion Tests

    #region Procedures

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Contract Dimensions Test");
        ClearAll();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Contract Dimensions Test");
        ContractTestLibrary.InitContractsApp();
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Contract Dimensions Test");
    end;

    #endregion Procedures
}
