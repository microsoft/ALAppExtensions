namespace Agent.SalesOrderTaker.Integration;

using System.Environment.Configuration;
using Agent.SalesOrderTaker;

codeunit 4590 "SOA Events"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure HandleOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        SOASetup: Record "SOA Setup";
    begin
        // Clear any setup information when copying a company
        SOASetup.ChangeCompany(NewCompanyName);
        SOASetup.DeleteAll();
    end;
}