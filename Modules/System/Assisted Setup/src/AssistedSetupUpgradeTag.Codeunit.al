codeunit 1808 "Assisted Setup Upgrade Tag"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetDeleteAssistedSetupTag());
    end;

    procedure GetDeleteAssistedSetupTag(): Code[250]
    begin
        exit('MS-309177-DeleteAssistedSetupToRecreateRecords-20190808');
    end;
}