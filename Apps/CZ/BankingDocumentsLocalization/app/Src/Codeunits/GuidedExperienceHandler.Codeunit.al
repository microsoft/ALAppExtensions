codeunit 31334 "Guided Experience Handler CZB"
{
    Access = Internal;

    var
        GuidedExperience: Codeunit "Guided Experience";
        ManualSetupCategory: Enum "Manual Setup Category";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure OnRegisterManualSetup()
    begin
        RegisterSearchRules();
    end;

    local procedure RegisterSearchRules()
    var
        SearchRuleNameTxt: Label 'Search Rules';
        SearchRuleDescriptionTxt: Label 'Set up rules for automatically matching payments on bank statements.';
        SearchRuleKeywordsTxt: Label 'Search Rules, Bank Statement, Apply, Match';
    begin
        GuidedExperience.InsertManualSetup(SearchRuleNameTxt, SearchRuleNameTxt, SearchRuleDescriptionTxt,
          10, ObjectType::Page, Page::"Search Rule List CZB", ManualSetupCategory::"Banking Documents CZZ", SearchRuleKeywordsTxt);
    end;
}
