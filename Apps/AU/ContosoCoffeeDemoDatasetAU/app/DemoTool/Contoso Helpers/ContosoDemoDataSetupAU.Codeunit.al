codeunit 17108 "Contoso Demo Data Setup AU"
{
    InherentPermissions = X;
    InherentEntitlements = X;

    [EventSubscriber(ObjectType::Table, Database::"Contoso Coffee Demo Data Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure LocalDemoDataSetup(var Rec: Record "Contoso Coffee Demo Data Setup")
    begin
        Rec."Country/Region Code" := 'AU';
    end;
}