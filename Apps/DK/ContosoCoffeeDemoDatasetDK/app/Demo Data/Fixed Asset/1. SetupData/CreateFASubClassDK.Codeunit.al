codeunit 13706 "Create FA SubClass DK"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateFAClass: Codeunit "Create FA Class";
        CreateFAPostingGrpDK: Codeunit "Create FA Posting Grp. DK";
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
    begin
        ContosoFixedAsset.InsertFASubClass(FurnitureSubClass(), FurnitureLbl, CreateFAClass.TangibleClass(), CreateFAPostingGrpDK.Furniture());
        ContosoFixedAsset.InsertFASubClass(IPSubClass(), IPLbl, CreateFAClass.InTangibleClass(), CreateFAPostingGrpDK.IP());
        ContosoFixedAsset.InsertFASubClass(LeaseholdSubClass(), LeaseholdLbl, CreateFAClass.FinancialClass(), CreateFAPostingGrpDK.Leasehold());
        ContosoFixedAsset.InsertFASubClass(PatentsSubClass(), PatentsLbl, CreateFAClass.InTangibleClass(), CreateFAPostingGrpDK.Patents());
    end;

    procedure FurnitureSubClass(): Code[10]
    begin
        exit(FurnitureTok);
    end;

    procedure IPSubClass(): Code[10]
    begin
        exit(IPTok);
    end;

    procedure LeaseholdSubClass(): Code[10]
    begin
        exit(LeaseholdTok);
    end;

    procedure PatentsSubClass(): Code[10]
    begin
        exit(PatentsTok);
    end;

    var
        FurnitureTok: Label 'FURNITURE', Locked = true;
        FurnitureLbl: Label 'Furniture & Fixtures', MaxLength = 50;
        IPTok: Label 'IP', Locked = true;
        IPLbl: Label 'Intellectual Property', MaxLength = 50;
        LeaseHoldTok: Label 'LEASEHOLD', Locked = true;
        LeaseholdLbl: Label 'Leasehold', MaxLength = 50;
        PatentsTok: Label 'PATENTS', Locked = true;
        PatentsLbl: Label 'Patents', MaxLength = 50;
}