codeunit 31371 "G/L Acc.Where-Used Handler CZC"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnAfterFillTableBuffer', '', false, false)]
    local procedure AddSetupTableOnAfterFillTableBuffer(var TableBuffer: Record "Integer")
    var
        CalcGLAccWhereUsed: Codeunit "Calc. G/L Acc. Where-Used";
    begin
        CalcGLAccWhereUsed.AddTable(TableBuffer, Database::"Compensations Setup CZC");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnShowExtensionPage', '', false, false)]
    local procedure ShowSetupPageOnShowExtensionPage(GLAccountWhereUsed: Record "G/L Account Where-Used")
    begin
        if GLAccountWhereUsed."Table ID" = Database::"Compensations Setup CZC" then
            Page.Run(Page::"Compensations Setup CZC");
    end;
}