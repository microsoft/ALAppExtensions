codeunit 20140 "Lookup Dialog Mgmt."
{
    procedure OpenTableFilterDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        LookupTableFilter: Record "Lookup Table Filter";
        LookupFieldFilterDialog: Page "Lookup Field Filter Dialog";
    begin
        LookupTableFilter.GET(CaseID, ScriptID, ID);
        LookupFieldFilterDialog.SetCurrentRecord(LookupTableFilter);
        LookupFieldFilterDialog.RunModal();
    end;

    procedure OpenTableSortingDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        LookupTableSorting: Record "Lookup Table Sorting";
        LookupFieldSortingDialog: Page "Lookup Field Sorting Dialog";
    begin
        LookupTableSorting.GET(CaseID, ScriptID, ID);
        LookupFieldSortingDialog.SetCurrentRecord(LookupTableSorting);
        LookupFieldSortingDialog.RunModal();
    end;
}