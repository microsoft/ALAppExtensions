codeunit 20600 "App Area Mgmt BF"
{
    // It is not possible to get the Essential Experience Application Areas, but when the function 'IsEssentialExperienceEnabled' is called, the event trigger OnGetEssentialExperienceAppAreas() is trigged, 
    // and then it is possible to "save" the Essential Experience Application Areas by setting this codeunit as a SingleInstance codeunit.

    SingleInstance = true;
    Access = Internal;

    var
        TempEssentialApplicationAreaSetup: Record "Application Area Setup" temporary;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetEssentialExperienceAppAreas', '', true, true)]
    local procedure OnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
    begin
        Clear(TempEssentialApplicationAreaSetup);
        TempEssentialApplicationAreaSetup := TempApplicationAreaSetup;
    end;

    internal procedure GetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        Clear(TempEssentialApplicationAreaSetup);
        ApplicationAreaMgmtFacade.IsEssentialExperienceEnabled();
        TempApplicationAreaSetup := TempEssentialApplicationAreaSetup;
    end;
}