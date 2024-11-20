codeunit 10793 "Create ES Posting Groups"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertGenProdPostingGroup();
        InsertGenPostingSetup();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Product Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateGenProductPostingGroup(var Rec: Record "Gen. Product Posting Group")
    var
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateESVATPostingGroups: Codeunit "Create ES VAT Posting Groups";
    begin
        case Rec.Code of
            CreatePostingGroups.MiscPostingGroup(),
            CreatePostingGroups.RawMatPostingGroup(),
            CreatePostingGroups.RetailPostingGroup(),
            CreatePostingGroups.FreightPostingGroup():
                ValidateRecordFields(Rec, CreateESVATPostingGroups.Vat21());
            CreatePostingGroups.ServicesPostingGroup():
                ValidateRecordFields(Rec, CreateESVATPostingGroups.Vat7());
        end;
    end;

    local procedure ValidateRecordFields(var GenProductPostingGroup: Record "Gen. Product Posting Group"; DefVATProdPostingGroup: Code[20])
    begin
        GenProductPostingGroup.Validate("Def. VAT Prod. Posting Group", DefVATProdPostingGroup);
    end;

    local procedure InsertGenProdPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateESVATPostingGroups: Codeunit "Create ES VAT Posting Groups";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertGenProductPostingGroup(CreateESVATPostingGroups.NoVat(), MiscellaneousWithoutVatLbl, CreateESVATPostingGroups.NoVat());
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    local procedure InsertGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateESVATPostingGroups: Codeunit "Create ES VAT Posting Groups";
        CreateESGLAccounts: Codeunit "Create ES GL Accounts";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreateESVATPostingGroups.NoVat(), '', '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', '', '', '', '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), '', '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', '', '', '', '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreateESVATPostingGroups.NoVat(), '', '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateESGLAccounts.NationalGoodsSales(), CreateESGLAccounts.NationalPurchases(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateESGLAccounts.NationalServices(), CreateESGLAccounts.NationalPurchases(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateESGLAccounts.GoodsSalesEu(), CreateESGLAccounts.EuPurchases(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreateESVATPostingGroups.NoVat(), '', '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateESGLAccounts.IntNonEuGoodsSales(), CreateESGLAccounts.IntNonEuPurch(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateESGLAccounts.IntServicesNonEu(), '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.SetOverwriteData(false);
        UpdateJobSalesAdjAcc('', CreateESVATPostingGroups.NoVat(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
        UpdateJobSalesAdjAcc('', CreatePostingGroups.RetailPostingGroup(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
        UpdateJobSalesAdjAcc(CreatePostingGroups.DomesticPostingGroup(), CreateESVATPostingGroups.NoVat(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
        UpdateJobSalesAdjAcc(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
        UpdateJobSalesAdjAcc(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
        UpdateJobSalesAdjAcc(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
        UpdateJobSalesAdjAcc(CreatePostingGroups.ExportPostingGroup(), CreateESVATPostingGroups.NoVat(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
        UpdateJobSalesAdjAcc(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
        UpdateJobSalesAdjAcc(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
    end;

    local procedure UpdateJobSalesAdjAcc(GenBusProdGrp: Code[20]; GenProdPostingGrp: Code[20]; JobSalesAdjAcc: Code[20]; JobCostAdjmtAcc: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if not GeneralPostingSetup.Get(GenBusProdGrp, GenProdPostingGrp) then
            exit;

        GeneralPostingSetup.Validate("Job Sales Adjmt. Account", JobSalesAdjAcc);
        GeneralPostingSetup.Validate("Job Cost Adjmt. Account", JobCostAdjmtAcc);
        GeneralPostingSetup.Modify(true);
    end;

    var
        MiscellaneousWithoutVatLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
}