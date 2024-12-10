codeunit 17121 "Create NZ Posting Groups"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnRun()
    begin
        InsertGenProdPostingGroup();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Business Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateGenBusinessPostingGroup(var Rec: Record "Gen. Business Posting Group")
    var
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateNZVATPostingGroups: Codeunit "Create NZ VAT Posting Group";
    begin
        case Rec.Code of
            CreatePostingGroups.EUPostingGroup():
                Rec.Validate("Def. VAT Bus. Posting Group", CreateNZVATPostingGroups.MISC());
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Product Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateGenProductPostingGroup(var Rec: Record "Gen. Product Posting Group")
    var
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateESVATPostingGroups: Codeunit "Create NZ VAT Posting Group";
    begin
        case Rec.Code of
            CreatePostingGroups.MiscPostingGroup(),
            CreatePostingGroups.RawMatPostingGroup(),
            CreatePostingGroups.RetailPostingGroup(),
            CreatePostingGroups.FreightPostingGroup():
                ValidateRecordFields(Rec, CreateESVATPostingGroups.VAT15());
            CreatePostingGroups.ServicesPostingGroup():
                ValidateRecordFields(Rec, CreateESVATPostingGroups.VAT9());
        end;
    end;

    local procedure ValidateRecordFields(var GenProductPostingGroup: Record "Gen. Product Posting Group"; DefVATProdPostingGroup: Code[20])
    begin
        GenProductPostingGroup.Validate("Def. VAT Prod. Posting Group", DefVATProdPostingGroup);
    end;

    local procedure InsertGenProdPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateNZVATPostingGroups: Codeunit "Create NZ VAT Posting Group";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertGenProductPostingGroup(CreateNZVATPostingGroups.NoVAT(), MiscellaneousWithoutVatLbl, CreateNZVATPostingGroups.NoVAT());
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    procedure InsertGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateNZVATPostingGroups: Codeunit "Create NZ VAT Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreateNZVATPostingGroups.NoVat(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', '', '', '', '', CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreateNZVATPostingGroups.NoVat(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreateNZVATPostingGroups.NoVat(), '', '', CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateGLAccount.SalesRetailDom(), CreateGLAccount.PurchRetailDom(), CreateGLAccount.InventoryAdjmtRetail(), CreateGLAccount.InventoryAdjmtRetail(), '', '', CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscountGranted(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.DiscReceivedRetail(), CreateGLAccount.CostofRetailSold(), CreateGLAccount.CostofResaleSoldInterim(), CreateGLAccount.InvAdjmtInterimRetail());
        ContosoGenPostingSetup.SetOverwriteData(false);
    end;

    var
        MiscellaneousWithoutVatLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
}