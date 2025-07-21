#pragma warning disable AA0247
codeunit 12194 "E-Document Module IT"
{
    SingleInstance = true;

    var
        PreventPostedDocDeletionLocal: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoDataSetItalySpecificFields(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        if Module <> Module::"E-Document Contoso Module" then
            exit;
        if ContosoDemoDataLevel <> ContosoDemoDataLevel::"Transactional Data" then
            exit;

        SalesReceivablesSetup.Get();
        PreventPostedDocDeletionLocal := SalesReceivablesSetup."Prevent Posted Doc. Deletion";
        SalesReceivablesSetup."Prevent Posted Doc. Deletion" := false;
        SalesReceivablesSetup.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoDataSetItalySpecificFields(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        if Module <> Module::"E-Document Contoso Module" then
            exit;
        if ContosoDemoDataLevel <> ContosoDemoDataLevel::"Transactional Data" then
            exit;

        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Prevent Posted Doc. Deletion" := PreventPostedDocDeletionLocal;
        SalesReceivablesSetup.Modify();
    end;



}
