codeunit 139535 "Connectivity Apps Loc. Mock"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Connectivity Apps Impl.", 'OnGetCurrentCountryCode', '', false, false)]
    local procedure OnGetCurrentCountryCode(var CountryCode: Text; var Handled: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CountryCode := CompanyInformation."Country/Region Code";
        Handled := true;
    end;
}