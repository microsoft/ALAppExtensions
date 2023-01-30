codeunit 30211 "Shpfy Shop Mgt."
{
    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure HandleOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        Shop: Record "Shpfy Shop";
    begin
        Shop.ChangeCompany(NewCompanyName);
        Shop.ModifyAll(Enabled, false);
    end;
}