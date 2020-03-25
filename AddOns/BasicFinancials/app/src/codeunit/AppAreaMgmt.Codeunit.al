codeunit 20600 "App Area Mgmt BF"
{
    // Workaround, Unfortunately it's pretty ugly AL-coding solution, but the user Experience is working as intended.
    // It is not possible to get the Essential Experience Application Areas, but when the function 'IsEssentialExperienceEnabled' is called, the event trigger OnGetEssentialExperienceAppAreas() is trigged, 
    // and then it is possible to "save" the Essential Experience Application Areas by setting this codeunit as a SingleInstance codeunit.

    SingleInstance = true;
    Access = Internal;

    var
        EssentialTempApplicationAreaSetup: Record "Application Area Setup" temporary;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetEssentialExperienceAppAreas', '', true, true)]
    local procedure OnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
    begin
        Clear(EssentialTempApplicationAreaSetup);
        EssentialTempApplicationAreaSetup := TempApplicationAreaSetup;
    end;

    internal procedure GetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        Clear(EssentialTempApplicationAreaSetup);
        ApplicationAreaMgmtFacade.IsEssentialExperienceEnabled();
        TempApplicationAreaSetup := EssentialTempApplicationAreaSetup;
    end;
}