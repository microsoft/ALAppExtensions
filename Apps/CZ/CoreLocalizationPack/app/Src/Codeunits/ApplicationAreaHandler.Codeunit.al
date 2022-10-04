codeunit 31441 "Application Area Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetBasicExperienceAppAreas', '', false, false)]
    local procedure SetCZOnGetBasicExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup")
    begin
        TempApplicationAreaSetup."Basic CZ" := true;
    end;
}