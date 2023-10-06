codeunit 10507 "Contoso Demo Data Setup GB"
{
    InherentPermissions = X;
    InherentEntitlements = X;

    [EventSubscriber(ObjectType::Table, Database::"Contoso Coffee Demo Data Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure LocalDemoDataSetup(var Rec: Record "Contoso Coffee Demo Data Setup")
    begin
        Rec."Country/Region Code" := 'GB';
    end;
}