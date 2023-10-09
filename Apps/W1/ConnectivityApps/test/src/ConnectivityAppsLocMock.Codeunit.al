codeunit 139535 "Connectivity Apps Loc. Mock"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Connectivity Apps Impl.", 'OnGetCurrentLocalizationCode', '', false, false)]
    local procedure OnGetCurrentLocalizationCode(var LocalizationCode: Text; var IsHandled: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        LocalizationCode := CompanyInformation."Country/Region Code";
        IsHandled := true;
    end;
}