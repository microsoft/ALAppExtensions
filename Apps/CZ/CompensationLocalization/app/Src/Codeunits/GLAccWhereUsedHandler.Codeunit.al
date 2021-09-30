codeunit 31371 "G/L Acc.Where-Used Handler CZC"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnAfterFillTableBuffer', '', false, false)]
    local procedure AddSetupTableOnAfterFillTableBuffer(var TableBuffer: Record "Integer")
    var
        CalcGLAccWhereUsed: Codeunit "Calc. G/L Acc. Where-Used";
    begin
        CalcGLAccWhereUsed.AddTable(TableBuffer, Database::"Compensations Setup CZC");
#if not CLEAN18
#pragma warning disable AL0432
        if TableBuffer.Get(Database::"Credits Setup") then
            if not IsTestingEnvironment() then
                TableBuffer.Delete();
#pragma warning restore AL0432
#endif
    end;

#if not CLEAN18
    local procedure IsTestingEnvironment(): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        exit(NAVAppInstalledApp.Get('fa3e2564-a39e-417f-9be6-c0dbe3d94069')); // application "Tests-ERM"
    end;

#endif
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnShowExtensionPage', '', false, false)]
    local procedure ShowSetupPageOnShowExtensionPage(GLAccountWhereUsed: Record "G/L Account Where-Used")
    begin
        if GLAccountWhereUsed."Table ID" = Database::"Compensations Setup CZC" then
            Page.Run(Page::"Compensations Setup CZC");
    end;
}
