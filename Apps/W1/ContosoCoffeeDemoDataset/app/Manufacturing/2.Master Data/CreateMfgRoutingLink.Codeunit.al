codeunit 4773 "Create Mfg Routing Link"
{
    Permissions = tabledata "Routing Link" = ri;

    trigger OnRun()
    begin
        InsertData('100', XAssemblingTok);
        InsertData('300', XInspectionTok);
    end;

    var
        XAssemblingTok: Label 'Assembling', MaxLength = 50;
        XInspectionTok: Label 'Inspection', MaxLength = 50;

    local procedure InsertData("Code": Code[10]; Description: Text[50])
    var
        RoutingLink: Record "Routing Link";
    begin
        RoutingLink.Validate(Code, Code);
        RoutingLink.Validate(Description, Description);
        RoutingLink.Insert();
    end;
}