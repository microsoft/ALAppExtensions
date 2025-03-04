codeunit 19059 "Create IN Interac. Tmpl. Lang."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateInteractionTemplateLanguages();
    end;

    local procedure CreateInteractionTemplateLanguages()
    var
        ContosoCRM: Codeunit "Contoso CRM";
        CreateInteractionTemplate: Codeunit "Create Interaction Template";
        CreateLanguage: Codeunit "Create Language";
    begin
        ContosoCRM.InsertInteractionTmplLanguage(CreateInteractionTemplate.Abstract(), CreateLanguage.ENG());
        ContosoCRM.InsertInteractionTmplLanguage(CreateInteractionTemplate.Bus(), CreateLanguage.ENG());
    end;
}