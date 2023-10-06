codeunit 10495 "Contoso Demo Data Setup US"
{
    InherentPermissions = X;
    InherentEntitlements = X;

    [EventSubscriber(ObjectType::Table, Database::"Contoso Coffee Demo Data Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure LocalDemoDataSetup(var Rec: Record "Contoso Coffee Demo Data Setup")
    begin
        Rec."Country/Region Code" := 'US';
        Rec."Company Type" := Rec."Company Type"::"Sales Tax";
    end;
}