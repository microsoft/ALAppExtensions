codeunit 5675 "Create Team"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertTeam(Administration(), AdministrationLbl);
        ContosoCRM.InsertTeam(Canvas(), CanvasLbl);
        ContosoCRM.InsertTeam(Marketing(), MarketingLbl);
        ContosoCRM.InsertTeam(Sale(), SaleLbl);
        ContosoCRM.InsertTeam(Service(), ServiceLbl);
        ContosoCRM.InsertTeam(Support(), SupportLbl);
    end;

    procedure Administration(): Code[10]
    begin
        exit(AdministrationTok);
    end;

    procedure Canvas(): Code[10]
    begin
        exit(CanvasTok);
    end;

    procedure Marketing(): Code[10]
    begin
        exit(MarketingTok);
    end;

    procedure Sale(): Code[10]
    begin
        exit(SaleTok);
    end;

    procedure Service(): Code[10]
    begin
        exit(ServiceTok);
    end;

    procedure Support(): Code[10]
    begin
        exit(SupportTok);
    end;

    var
        AdministrationLbl: Label 'Administration', MaxLength = 50;
        CanvasLbl: Label 'Canvas team', MaxLength = 50;
        MarketingLbl: Label 'Marketing Group', MaxLength = 50;
        SaleLbl: Label 'Sales', MaxLength = 50;
        ServiceLbl: Label 'Field Service', MaxLength = 50;
        SupportLbl: Label 'Product support', MaxLength = 50;
        AdministrationTok: Label 'ADM', MaxLength = 10;
        CanvasTok: Label 'CANVAS', MaxLength = 10;
        MarketingTok: Label 'MARKETING', MaxLength = 10;
        SaleTok: Label 'SALE', MaxLength = 10;
        ServiceTok: Label 'SERVICE', MaxLength = 10;
        SupportTok: Label 'SUPPORT', MaxLength = 10;

}