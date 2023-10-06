codeunit 11496 "Warehouse Module Setup NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Warehouse Module Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure LocalDemoDataSetup(var Rec: Record "Warehouse Module Setup")
    begin
        // Vendor 10000 in NL from Evaluation is not domestic
        Rec."Vendor No." := '20000';
    end;
}