codeunit 5250 "Create Requisition Wksh. Name"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateRequisitionWorksheetTemplate();
        CreateRequisitionWorksheetName();
    end;

    local procedure CreateRequisitionWorksheetName()
    var
        ContosoInventory: Codeunit "Contoso Inventory";
    begin
        ContosoInventory.InsertRequisitionWkshName(Planning(), Default(), DefaultJournalLbl);
        ContosoInventory.InsertRequisitionWkshName(Req(), Default(), DefaultJournalLbl);
    end;

    local procedure CreateRequisitionWorksheetTemplate()
    var
        ContosoInventory: Codeunit "Contoso Inventory";
    begin
        ContosoInventory.InsertReqWkshTemplate(Planning(), PlanningLbl, Page::"Planning Worksheet", Enum::"Req. Worksheet Template Type"::Planning);
        ContosoInventory.InsertReqWkshTemplate(Req(), ReqLbl, Page::"Req. Worksheet", Enum::"Req. Worksheet Template Type"::"Req.");
    end;

    procedure Planning(): Code[10]
    begin
        exit(PlanningTok);
    end;

    procedure Req(): Code[10]
    begin
        exit(ReqTok);
    end;

    procedure Default(): Code[10]
    begin
        exit(DefaultNameLbl);
    end;

    var
        DefaultNameLbl: Label 'DEFAULT', MaxLength = 10;
        DefaultJournalLbl: Label 'Default Journal Batch', MaxLength = 100;
        PlanningTok: Label 'PLANNING', MaxLength = 10;
        ReqTok: Label 'REQ', MaxLength = 10;
        PlanningLbl: Label 'Planning Worksheet', MaxLength = 80;
        ReqLbl: Label 'Req. Worksheet', MaxLength = 80;
}