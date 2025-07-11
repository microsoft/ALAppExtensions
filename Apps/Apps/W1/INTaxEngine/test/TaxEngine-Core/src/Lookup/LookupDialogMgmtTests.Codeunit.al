codeunit 136706 "Lookup Dialog Mgmt Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;
    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Lookup Dialog Mgmt] [UT]
    end;

    [Test]
    [HandlerFunctions('TableFilterDialogPageHandler')]
    procedure TestOpenTableFilterDialog()
    var
        LookupDialogMgmt: Codeunit "Lookup Dialog Mgmt.";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        CaseID, ScriptID, TableFilterID : Guid;
    begin
        // [SCENARIO] To check if the Table Filter Dialog is opening for Table G/L Account.

        // [GIVEN] There should be a table exist with the name of G/L Account.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        TableFilterID := LookupEntityMgmt.CreateTableFilters(CaseID, ScriptID, Database::"G/L Account");

        // [WHEN] The function OpenTableFilterDialog is called.
        LookupDialogMgmt.OpenTableFilterDialog(CaseID, ScriptID, TableFilterID);
        // [THEN] it should open the Filter dialog page withour any error.
    end;

    [Test]
    [HandlerFunctions('TableSortingDialogPageHandler')]
    procedure TestOpenTableSortingDialog()
    var
        LookupDialogMgmt: Codeunit "Lookup Dialog Mgmt.";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        CaseID, ScriptID, TableSortingID : Guid;
    begin
        // [SCENARIO] To check if the Table Sorting Dialog is opening for Table G/L Account.

        // [GIVEN] There should be a table exist with the name of G/L Account.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        TableSortingID := LookupEntityMgmt.CreateTableSorting(CaseID, ScriptID, Database::"G/L Account");

        // [WHEN] The function OpenTableSortingDialog is called.
        LookupDialogMgmt.OpenTableSortingDialog(CaseID, ScriptID, TableSortingID);
        // [THEN] it should open the Sorting dialog page withour any error.
    end;

    [ModalPageHandler]
    procedure TableFilterDialogPageHandler(var LookupFieldFilterDialog: TestPage "Lookup Field Filter Dialog")
    begin
        LookupFieldFilterDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure TableSortingDialogPageHandler(var LookupFieldSortingDialog: TestPage "Lookup Field Sorting Dialog")
    begin
        LookupFieldSortingDialog.OK().Invoke();
    end;
}