codeunit 27075 "CA Incoming Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure LocalizationContosoDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        EServiceDemoDataSetup: Record "EService Demo Data Setup";
    begin
        if (Module = Enum::"Contoso Demo Data Module"::"EService") and (ContosoDemoDataLevel = Enum::"Contoso Demo Data Level"::"Setup Data") then begin
            EServiceDemoDataSetup.InitRecord();

            EServiceDemoDataSetup.Validate("Invoice Field Name", IncomingDocDescriptionLbl);
            EServiceDemoDataSetup.Modify();
        end;
    end;

    var
        IncomingDocDescriptionLbl: Label 'Fabrikam Invoice CA D365F', Locked = true;
}