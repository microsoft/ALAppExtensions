codeunit 30211 "Shpfy Shop Mgt."
{
    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure HandleOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        ShpfyShop: Record "Shpfy Shop";
    begin
        ShpfyShop.ChangeCompany(NewCompanyName);
        ShpfyShop.ModifyAll(Enabled, false);
    end;
}