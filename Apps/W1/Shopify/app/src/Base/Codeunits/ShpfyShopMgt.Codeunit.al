codeunit 30211 "Shpfy Shop Mgt."
{

    internal procedure IsEnabled(): Boolean
    var
        Shop: Record "Shpfy Shop";
    begin
        if not Shop.ReadPermission() then
            exit(false);

        Shop.SetRange(Enabled, true);
        exit(not Shop.IsEmpty());
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure HandleOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        Shop: Record "Shpfy Shop";
    begin
        Shop.ChangeCompany(NewCompanyName);
        Shop.ModifyAll(Enabled, false);
    end;
}