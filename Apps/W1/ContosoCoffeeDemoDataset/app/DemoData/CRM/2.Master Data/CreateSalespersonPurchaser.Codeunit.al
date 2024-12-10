codeunit 5416 "Create Salesperson/Purchaser"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        ContosoCRM.InsertSalespersonPurchaser(BenjaminChiu(), BenjaminChiuLbl, 0, ContosoUtilities.EmptyPicture(), 'BC@contoso.com');
        ContosoCRM.InsertSalespersonPurchaser(EsterHenderson(), EsterHendersonLbl, 0, ContosoUtilities.EmptyPicture(), 'EH@contoso.com');
        ContosoCRM.InsertSalespersonPurchaser(HelenaRay(), HelenaRayLbl, 0, ContosoUtilities.EmptyPicture(), 'HR@contoso.com');
        ContosoCRM.InsertSalespersonPurchaser(JimOlive(), JimOliveLbl, 5, ContosoUtilities.EmptyPicture(), 'JO@contoso.com');
        ContosoCRM.InsertSalespersonPurchaser(LinaTownsend(), LinaTownsendLbl, 5, ContosoUtilities.EmptyPicture(), 'LT@contoso.com');
        ContosoCRM.InsertSalespersonPurchaser(OtisFalls(), OtisFallsLbl, 5, ContosoUtilities.EmptyPicture(), 'OF@contoso.com');
        ContosoCRM.InsertSalespersonPurchaser(RobinBettencourt(), RobinBettencourtLbl, 0, ContosoUtilities.EmptyPicture(), 'RB@contoso.com');
    end;

    procedure BenjaminChiu(): Code[20]
    begin
        exit(BenjaminChiuTok);
    end;

    procedure EsterHenderson(): Code[20]
    begin
        exit(EsterHendersonTok);
    end;

    procedure HelenaRay(): Code[20]
    begin
        exit(HelenaRayTok);
    end;

    procedure JimOlive(): Code[20]
    begin
        exit(JimOliveTok);
    end;

    procedure LinaTownsend(): Code[20]
    begin
        exit(LinaTownsendTok);
    end;

    procedure OtisFalls(): Code[20]
    begin
        exit(OtisFallsTok);
    end;

    procedure RobinBettencourt(): Code[20]
    begin
        exit(RobinBettencourtTok);
    end;

    var
        BenjaminChiuTok: Label 'BC', MaxLength = 20;
        EsterHendersonTok: Label 'EH', MaxLength = 20;
        HelenaRayTok: Label 'HR', MaxLength = 20;
        JimOliveTok: Label 'JO', MaxLength = 20;
        LinaTownsendTok: Label 'LT', MaxLength = 20;
        OtisFallsTok: Label 'OF', MaxLength = 20;
        RobinBettencourtTok: Label 'RB', MaxLength = 20;
        BenjaminChiuLbl: Label 'Benjamin Chiu', MaxLength = 50;
        EsterHendersonLbl: Label 'Ester Henderson', MaxLength = 50;
        HelenaRayLbl: Label 'Helena Ray', MaxLength = 50;
        JimOliveLbl: Label 'Jim Olive', MaxLength = 50;
        LinaTownsendLbl: Label 'Lina Townsend', MaxLength = 50;
        OtisFallsLbl: Label 'Otis Falls', MaxLength = 50;
        RobinBettencourtLbl: Label 'Robin Bettencourt', MaxLength = 50;
}