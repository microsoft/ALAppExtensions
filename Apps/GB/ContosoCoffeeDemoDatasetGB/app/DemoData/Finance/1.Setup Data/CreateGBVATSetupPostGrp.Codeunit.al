codeunit 11491 "Create GB VAT Setup Post. Grp."
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"VAT Setup Posting Groups", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record "VAT Setup Posting Groups"; RunTrigger: Boolean)
    var
        CreateGBGLAccounts: Codeunit "Create GB GL Accounts";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        if (Rec."VAT Prod. Posting Group" = CreateVATPostingGroups.FullNormal()) and (Rec.Default) then
            ValidateRecordFields(Rec, 100, CreateGBGLAccounts.SalesVATNormal(), CreateGBGLAccounts.PurchaseVATNormal(), FullNormalDescLbl, 1);

        if (Rec."VAT Prod. Posting Group" = CreateVATPostingGroups.FullRed()) and (Rec.Default) then
            ValidateRecordFields(Rec, 100, CreateGBGLAccounts.SalesVATReduced(), CreateGBGLAccounts.PurchaseVATReduced(), FullReducedDescLbl, 1);

        if (Rec."VAT Prod. Posting Group" = CreateVATPostingGroups.Reduced()) and (Rec.Default) then
            ValidateRecordFields(Rec, 5, CreateGBGLAccounts.SalesVATReduced(), CreateGBGLAccounts.PurchaseVATReduced(), ReducedDescLbl, 1);

        if (Rec."VAT Prod. Posting Group" = CreateVATPostingGroups.ServNormal()) and (Rec.Default) then
            ValidateRecordFields(Rec, 20, CreateGBGLAccounts.SalesVATNormal(), CreateGBGLAccounts.PurchaseVATNormal(), ServNormalDescLbl, 2);

        if (Rec."VAT Prod. Posting Group" = CreateVATPostingGroups.ServRed()) and (Rec.Default) then
            ValidateRecordFields(Rec, 5, CreateGBGLAccounts.SalesVATReduced(), CreateGBGLAccounts.PurchaseVATReduced(), ServReducedDescLbl, 2);

        if (Rec."VAT Prod. Posting Group" = CreateVATPostingGroups.Standard()) and (Rec.Default) then
            ValidateRecordFields(Rec, 20, CreateGBGLAccounts.SalesVATNormal(), CreateGBGLAccounts.PurchaseVATNormal(), StandardDescLbl, 1);

        if (Rec."VAT Prod. Posting Group" = CreateVATPostingGroups.Zero()) and (Rec.Default) then
            ValidateRecordFields(Rec, 0, CreateGBGLAccounts.SalesVATNormal(), CreateGBGLAccounts.PurchaseVATReduced(), ZeroDescLbl, 1);
    end;

    local procedure ValidateRecordFields(var VATSetupPostingGroups: Record "VAT Setup Posting Groups"; VATPercent: Decimal; SalesVATAccount: Code[20]; PurchaseVATAccount: Code[20]; VATProdPostingGrpDesc: Text[100]; ApplicationType: Integer)
    begin
        VATSetupPostingGroups.Validate("VAT %", VATPercent);
        VATSetupPostingGroups.Validate("Sales VAT Account", SalesVATAccount);
        VATSetupPostingGroups.Validate("Purchase VAT Account", PurchaseVATAccount);
        VATSetupPostingGroups.Validate("VAT Prod. Posting Grp Desc.", VATProdPostingGrpDesc);
        VATSetupPostingGroups.Validate("Application Type", ApplicationType);
    end;

    var
        FullNormalDescLbl: Label ' Setup for DOMESTIC / FULL NORM', MaxLength = 100;
        FullReducedDescLbl: Label ' Setup for DOMESTIC / FULL RED', MaxLength = 100;
        ReducedDescLbl: Label ' Setup for EXPORT / REDUCED', MaxLength = 100;
        ServNormalDescLbl: Label ' Setup for EU / SERV NORM', MaxLength = 100;
        ServReducedDescLbl: Label ' Setup for EU / SERV RED', MaxLength = 100;
        StandardDescLbl: Label ' Setup for EXPORT / STANDARD', MaxLength = 100;
        ZeroDescLbl: Label ' Setup for EXPORT / ZERO', MaxLength = 100;
}