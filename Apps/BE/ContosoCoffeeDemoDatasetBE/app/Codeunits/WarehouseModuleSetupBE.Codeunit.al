codeunit 11349 "Warehouse Module Setup BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Warehouse Module Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure LocalDemoDataSetup(var Rec: Record "Warehouse Module Setup")
    begin
        // Vendor 10000 in BE from Evaluation is not domestic
        Rec."Vendor No." := '20000';
    end;
}