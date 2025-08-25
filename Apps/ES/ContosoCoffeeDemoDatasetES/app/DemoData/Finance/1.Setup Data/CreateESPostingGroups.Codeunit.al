// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.DemoTool.Helpers;

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

    local procedure InsertGenProdPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertGenProductPostingGroup(NoVat(), MiscellaneousWithoutVatLbl, NoVat());
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    local procedure InsertGenPostingSetup()
    var
        ContosoGenPostingSetup: Codeunit "Contoso Posting Setup";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateESGLAccounts: Codeunit "Create ES GL Accounts";
    begin
        ContosoGenPostingSetup.SetOverwriteData(true);
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', NoVat(), '', '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', '', '', '', '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.RetailPostingGroup(), '', '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', '', '', '', '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup('', CreatePostingGroups.ServicesPostingGroup(), '', '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', '', '', '', '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());

        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), NoVat(), '', '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateESGLAccounts.NationalGoodsSales(), CreateESGLAccounts.NationalPurchases(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateESGLAccounts.NationalServices(), CreateESGLAccounts.NationalPurchases(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateESGLAccounts.GoodsSalesEu(), CreateESGLAccounts.EuPurchases(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), NoVat(), '', '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateESGLAccounts.IntNonEuGoodsSales(), CreateESGLAccounts.IntNonEuPurch(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.InsertGeneralPostingSetup(CreatePostingGroups.ExportPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateESGLAccounts.IntServicesNonEu(), '', CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.ChangesInStockPosting(), '', '', CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.GoodsSalesReturnAllow(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ReturnAndAllowOnGoods(), CreateESGLAccounts.ChangesInStockPosting(), CreateESGLAccounts.BillOfMaterTradeCred(), CreateESGLAccounts.ChangesInRawMaterials());
        ContosoGenPostingSetup.SetOverwriteData(false);

        UpdateJobSalesAdjAcc('', NoVat(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
        UpdateJobSalesAdjAcc('', CreatePostingGroups.RetailPostingGroup(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
        UpdateJobSalesAdjAcc('', CreatePostingGroups.ServicesPostingGroup(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());

        UpdateJobSalesAdjAcc(CreatePostingGroups.DomesticPostingGroup(), NoVat(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
        UpdateJobSalesAdjAcc(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
        UpdateJobSalesAdjAcc(CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ServicesPostingGroup(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
        UpdateJobSalesAdjAcc(CreatePostingGroups.EUPostingGroup(), CreatePostingGroups.RetailPostingGroup(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
        UpdateJobSalesAdjAcc(CreatePostingGroups.ExportPostingGroup(), NoVat(), CreateESGLAccounts.ProjectsSales(), CreateESGLAccounts.ProjectCostsRetail());
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

    procedure NoVAT(): Code[20]
    begin
        exit(NoVatTok);
    end;

    var
        NoVatTok: Label 'NO VAT', MaxLength = 20;
        MiscellaneousWithoutVatLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
}
