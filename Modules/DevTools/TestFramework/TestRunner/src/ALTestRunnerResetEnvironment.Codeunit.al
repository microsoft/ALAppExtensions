codeunit 130453 "ALTestRunner Reset Environment"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    procedure Initialize()
    begin
        CurrentWorkDate := WorkDate();
    end;

#if not CLEAN22
#pragma warning disable AA0207
    [Obsolete('The procedure will be made local.', '22.0')]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", 'OnBeforeTestMethodRun', '', false, false)]
    procedure BeforeTestMethod(CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions; var CurrentTestMethodLine: Record "Test Method Line")
#pragma warning restore AA0207
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", 'OnBeforeTestMethodRun', '', false, false)]
    local procedure BeforeTestMethod(CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions; var CurrentTestMethodLine: Record "Test Method Line")
#endif
    begin
        ClearLastError();
        ApplicationArea('');
        if FunctionName = 'OnRun' then
            exit;

        ClearLegacyLibraries(FunctionTestPermissions);
        BindStopSystemTableChanges();
    end;

#if not CLEAN22
#pragma warning disable AA0207
    [Obsolete('The procedure will be made local.', '22.0')]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", 'OnAfterCodeunitRun', '', false, false)]
    procedure AfterTestMethod(var TestMethodLine: Record "Test Method Line")
#pragma warning restore AA0207
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", 'OnAfterCodeunitRun', '', false, false)]
    local procedure AfterTestMethod(var TestMethodLine: Record "Test Method Line")
#endif
    begin
        WorkDate(CurrentWorkDate);
        ApplicationArea('');
    end;

    local procedure ClearLegacyLibraries(FunctionTestPermissions: TestPermissions)
    var
        AllObj: Record AllObj;
        ResetStateCodeunit: Integer;
        SetPermissionsCodeunit: Integer;
    begin
        ResetStateCodeunit := 130301; // codeunit 130301 "Reset State Before Test Run"
        AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
        AllObj.SetRange("Object ID", ResetStateCodeunit);
        if not AllObj.IsEmpty() then
            Codeunit.Run(ResetStateCodeunit);

        if FunctionTestPermissions = TESTPERMISSIONS::Disabled then
            exit;

        Clear(AllObj);
        SetPermissionsCodeunit := 130302; // codeunit 130302 "Set Permissions State Before Test Run"
        AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
        AllObj.SetRange("Object ID", SetPermissionsCodeunit);
        if not AllObj.IsEmpty() then
            Codeunit.Run(SetPermissionsCodeunit);
    end;

    local procedure BindStopSystemTableChanges()
    var
        AllObj: Record AllObj;
        BlockChangestoSystemTables: Integer;
    begin
        BlockChangestoSystemTables := 132553; // codeunit 132553 "Block Changes to System Tables"
        AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
        AllObj.SetRange("Object ID", BlockChangestoSystemTables);
        if not AllObj.IsEmpty() then
            Codeunit.Run(BlockChangestoSystemTables);
    end;


    var
        CurrentWorkDate: Date;
}