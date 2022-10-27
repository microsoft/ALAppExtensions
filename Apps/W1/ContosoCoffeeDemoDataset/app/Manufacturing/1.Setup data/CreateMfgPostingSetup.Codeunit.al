codeunit 4768 "Create Mfg Posting Setup"
{
    Permissions = tabledata "General Posting Setup" = rim,
        tabledata "Gen. Business Posting Group" = ri,
        tabledata "Gen. Product Posting Group" = ri,
        tabledata "G/L Account" = ri,
        tabledata "Inventory Posting Group" = ri;

    trigger OnRun()
    begin
        ManufacturingDemoDataSetup.Get();

        CreateGenProdPostingGroup();
        CreateGenBusPostingGroup();
        CreateGLAccounts();
        CreateInventoryPostingSetup();
        CreateGeneralPostingSetup();
    end;

    var
        ManufacturingDemoDataSetup: Record "Manufacturing Demo Data Setup";
        ManufacturingDemoAccount: record "Manufacturing Demo Account";
        ManufacturingDemoAccounts: Codeunit "Manufacturing Demo Accounts";
        GLAccountIndent: Codeunit "G/L Account-Indent";
        XCapacitiesTok: Label 'Capacities', MaxLength = 50;
        XDomesticcustomersandvendorsTok: Label 'Domestic customers and vendors', MaxLength = 50;
        XFinishedItemsTxt: Label 'Finished items', MaxLength = 50;
        XRawMaterialsTxt: Label 'Raw materials', MaxLength = 50;


    local procedure CreateGenProdPostingGroup()
    var
        DefVATPostingGr: code[20];
    begin
        if ManufacturingDemoDataSetup."Company Type" = ManufacturingDemoDataSetup."Company Type"::VAT then
            DefVATPostingGr := ManufacturingDemoDataSetup."Base VAT Code";

        InsertGenProdPostingGroup(ManufacturingDemoDataSetup."Manufact Code", XCapacitiesTok, DefVATPostingGr);
        InsertGenProdPostingGroup(ManufacturingDemoDataSetup."Raw Mat Code", XRawMaterialsTxt, DefVATPostingGr);
    end;

    local procedure CreateGenBusPostingGroup()
    begin
        case ManufacturingDemoDataSetup."Company Type" of
            ManufacturingDemoDataSetup."Company Type"::"Sales Tax":
                InsertGenBusPostingGroup(ManufacturingDemoDataSetup."Domestic Code", XDomesticcustomersandvendorsTok, '');

            ManufacturingDemoDataSetup."Company Type"::VAT:
                InsertGenBusPostingGroup(ManufacturingDemoDataSetup."Domestic Code", XDomesticcustomersandvendorsTok, ManufacturingDemoDataSetup."Domestic Code");
        end;
    end;

    local procedure CreateGLAccounts()
    begin
        ManufacturingDemoAccount.ReturnAccountKey(true);

        InsertGLAccount(ManufacturingDemoAccount.DirectCostAppliedCap(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(ManufacturingDemoAccount.OverheadAppliedCap(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(ManufacturingDemoAccount.PurchaseVarianceCap(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(ManufacturingDemoAccount.DirectCostAppliedRawMat(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(ManufacturingDemoAccount.OverheadAppliedRawMat(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(ManufacturingDemoAccount.PurchaseVarianceRawMat(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(ManufacturingDemoAccount.DirectCostAppliedRetail(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(ManufacturingDemoAccount.OverheadAppliedRetail(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(ManufacturingDemoAccount.PurchaseVarianceRetail(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);

        InsertGLAccount(ManufacturingDemoAccount.PurchRawMatDom(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);

        InsertGLAccount(ManufacturingDemoAccount.InventoryAdjRawMat(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(ManufacturingDemoAccount.InventoryAdjRetail(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);

        InsertGLAccount(ManufacturingDemoAccount.WIPAccountFinishedgoods(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Balance Sheet", 0, '', 0, '', '', false);

        InsertGLAccount(ManufacturingDemoAccount.MaterialVariance(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(ManufacturingDemoAccount.CapacityVariance(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(ManufacturingDemoAccount.SubcontractedVariance(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(ManufacturingDemoAccount.CapOverheadVariance(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);
        InsertGLAccount(ManufacturingDemoAccount.MfgOverheadVariance(), Enum::"G/L Account Type"::Posting, Enum::"G/L Account Income/Balance"::"Income Statement", 0, '', 0, '', '', false);

        ManufacturingDemoAccount.ReturnAccountKey(false);

        GLAccountIndent.Indent();
    end;

    local procedure CreateInventoryPostingSetup()
    begin
        InsertInventoryPostingGroup(ManufacturingDemoDataSetup."Finished Code", XFinishedItemsTxt);
        InsertInventoryPostingGroup(ManufacturingDemoDataSetup."Raw Mat Code", XRawMaterialsTxt);

        InsertInventoryPostingSetup('', ManufacturingDemoDataSetup."Finished Code", ManufacturingDemoAccount.FinishedGoods(),
            '', ManufacturingDemoAccount.WIPAccountFinishedgoods(),
            ManufacturingDemoAccount.MaterialVariance(), ManufacturingDemoAccount.CapacityVariance(),
            ManufacturingDemoAccount.SubcontractedVariance(), ManufacturingDemoAccount.CapOverheadVariance(), ManufacturingDemoAccount.MfgOverheadVariance());

        InsertInventoryPostingSetup(ManufacturingDemoDataSetup."Manufacturing Location", ManufacturingDemoDataSetup."Finished Code",
            ManufacturingDemoAccount.FinishedGoods(), '',
            ManufacturingDemoAccount.WIPAccountFinishedgoods(), ManufacturingDemoAccount.MaterialVariance(),
            ManufacturingDemoAccount.CapacityVariance(), ManufacturingDemoAccount.SubcontractedVariance(),
            ManufacturingDemoAccount.CapOverheadVariance(), ManufacturingDemoAccount.MfgOverheadVariance());

        InsertInventoryPostingSetup('', ManufacturingDemoDataSetup."Raw Mat Code", ManufacturingDemoAccount.RawMaterials(),
            '', ManufacturingDemoAccount.WIPAccountFinishedgoods(), '', '', '', '', '');

        InsertInventoryPostingSetup(ManufacturingDemoDataSetup."Manufacturing Location", ManufacturingDemoDataSetup."Raw Mat Code",
            ManufacturingDemoAccount.RawMaterials(), '', ManufacturingDemoAccount.WIPAccountFinishedgoods(), '', '', '', '', '');
    end;

    local procedure CreateGeneralPostingSetup()
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        GeneralPostingSetup.get(ManufacturingDemoDataSetup."Domestic Code", ManufacturingDemoDataSetup."Retail Code");

        UpdateGeneralPostingSetup(ManufacturingDemoDataSetup."Domestic Code", ManufacturingDemoDataSetup."Retail Code", ManufacturingDemoAccount.InventoryAdjRetail(),
            '', ManufacturingDemoAccount.DirectCostAppliedRetail(), ManufacturingDemoAccount.OverheadAppliedRetail());

        UpdateGeneralPostingSetup('', ManufacturingDemoDataSetup."Retail Code", ManufacturingDemoAccount.InventoryAdjRetail(), '',
            ManufacturingDemoAccount.DirectCostAppliedRetail(), ManufacturingDemoAccount.OverheadAppliedRetail());

        InsertGeneralPostingSetup('', ManufacturingDemoDataSetup."Manufact Code", '', '', '', '',
            '', '', ManufacturingDemoAccount.DirectCostAppliedCap(), ManufacturingDemoAccount.OverheadAppliedCap(), ManufacturingDemoAccount.PurchaseVarianceCap());

        InsertGeneralPostingSetup('', ManufacturingDemoDataSetup."Raw Mat Code", '', '', '', '',
            ManufacturingDemoAccount.InventoryAdjRawMat(), '', ManufacturingDemoAccount.DirectCostAppliedRawMat(),
            ManufacturingDemoAccount.OverheadAppliedRawMat(), '');

        InsertGeneralPostingSetup(ManufacturingDemoDataSetup."Domestic Code", ManufacturingDemoDataSetup."Manufact Code",
            GeneralPostingSetup."Purch. Account", GeneralPostingSetup."Purch. Inv. Disc. Account", GeneralPostingSetup."Purch. Pmt. Disc. Credit Acc.", GeneralPostingSetup."Purch. Prepayments Account",
            ManufacturingDemoAccount.InventoryAdjRawMat(), '', ManufacturingDemoAccount.DirectCostAppliedRawMat(),
            ManufacturingDemoAccount.OverheadAppliedRawMat(), ManufacturingDemoAccount.PurchaseVarianceRawMat());

        InsertGeneralPostingSetup(ManufacturingDemoDataSetup."Domestic Code", ManufacturingDemoDataSetup."Raw Mat Code",
            ManufacturingDemoAccount.PurchRawMatDom(), GeneralPostingSetup."Purch. Inv. Disc. Account", GeneralPostingSetup."Purch. Pmt. Disc. Credit Acc.", GeneralPostingSetup."Purch. Prepayments Account",
            ManufacturingDemoAccount.InventoryAdjRawMat(), '', ManufacturingDemoAccount.DirectCostAppliedRawMat(),
            ManufacturingDemoAccount.OverheadAppliedRawMat(), ManufacturingDemoAccount.PurchaseVarianceRawMat());
    end;

    local procedure InsertGenProdPostingGroup(NewCode: Code[20]; NewDescription: Text[50]; DefVATProdPostingGroup: Code[20])
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
    begin
        if GenProductPostingGroup.Get(NewCode) then
            exit;

        GenProductPostingGroup.Init();
        GenProductPostingGroup.Validate(Code, NewCode);
        GenProductPostingGroup.Validate(Description, NewDescription);

        if ManufacturingDemoDataSetup."Company Type" = ManufacturingDemoDataSetup."Company Type"::VAT then
            GenProductPostingGroup."Def. VAT Prod. Posting Group" := DefVATProdPostingGroup;

        OnBeforeGenProductPostingGroupInsert(GenProductPostingGroup);

        GenProductPostingGroup.Insert();
    end;

    local procedure InsertGenBusPostingGroup("Code": Code[20]; Description: Text[50]; DefVATBusPostingGroup: Code[20])
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
    begin
        if GenBusinessPostingGroup.Get("Code") then
            exit;

        GenBusinessPostingGroup.Init();
        GenBusinessPostingGroup.Validate(Code, Code);
        GenBusinessPostingGroup.Validate(Description, Description);
        GenBusinessPostingGroup."Def. VAT Bus. Posting Group" := DefVATBusPostingGroup;
        if DefVATBusPostingGroup <> '' then
            GenBusinessPostingGroup."Auto Insert Default" := true;

        OnBeforeGenBusinessPostingGroupInsert(GenBusinessPostingGroup);

        GenBusinessPostingGroup.Insert();
    end;

    local procedure InsertGLAccount("No.": Code[20]; AccountType: Enum "G/L Account Type"; "Income/Balance": Enum "G/L Account Income/Balance"; NoOfBlankLines: Integer; Totaling: Text[30]; GenPostingType: Option; GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; "Direct Posting": Boolean)
    var
        GLAccount: Record "G/L Account";
    begin
        ManufacturingDemoAccount := ManufacturingDemoAccounts.GetDemoAccount("No.");

        if GLAccount.Get(ManufacturingDemoAccount."Account Value") then
            exit;

        GLAccount.Init();
        GLAccount.Validate("No.", ManufacturingDemoAccount."Account Value");
        GLAccount.Validate(Name, ManufacturingDemoAccount."Account Description");
        GLAccount.Validate("Account Type", AccountType);
        if GLAccount."Account Type" = GLAccount."Account Type"::Posting then
            GLAccount.Validate("Direct Posting", "Direct Posting");
        GLAccount.Validate("Income/Balance", "Income/Balance");
        GLAccount.Validate("No. of Blank Lines", NoOfBlankLines);
        if Totaling <> '' then
            GLAccount.Validate(Totaling, Totaling);
        GLAccount.Validate("Gen. Posting Type", GenPostingType);
        GLAccount.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        GLAccount.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);
        GLAccount.Insert();
    end;

    local procedure InsertInventoryPostingGroup("Code": Code[20]; PostingGroupDescription: Text[50])
    var
        InventoryPostingGroup: Record "Inventory Posting Group";
    begin
        if InventoryPostingGroup.Get("Code") then
            exit;

        InventoryPostingGroup.Init();
        InventoryPostingGroup.Validate(Code, Code);
        InventoryPostingGroup.Validate(Description, PostingGroupDescription);
        InventoryPostingGroup.Insert();
    end;

    local procedure InsertInventoryPostingSetup(LocationCode: Code[10]; InventoryPostingGroup: Code[20]; InventoryAccount: Code[20]; InventoryAccountInterim: Code[20];
                                        WIPAccount: Code[20]; MaterialVarianceAccount: Code[20]; CapacityVarianceAccount: Code[20]; SubcontractedVarianceAccount: Code[20];
                                        CapOverheadVarianceAccount: Code[20]; MfgOverheadVarianceAccount: Code[20])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        if InventoryPostingSetup.Get(LocationCode, InventoryPostingGroup) then
            exit;

        InventoryPostingSetup.Init();
        InventoryPostingSetup.Validate("Location Code", LocationCode);
        InventoryPostingSetup.Validate("Invt. Posting Group Code", InventoryPostingGroup);
        InventoryPostingSetup.Validate("Inventory Account", InventoryAccount);
        InventoryPostingSetup.Validate("Inventory Account (Interim)", InventoryAccountInterim);
        InventoryPostingSetup.Validate("WIP Account", WIPAccount);
        InventoryPostingSetup.Validate("Material Variance Account", MaterialVarianceAccount);
        InventoryPostingSetup.Validate("Capacity Variance Account", CapacityVarianceAccount);
        InventoryPostingSetup.Validate("Subcontracted Variance Account", SubcontractedVarianceAccount);
        InventoryPostingSetup.Validate("Cap. Overhead Variance Account", CapOverheadVarianceAccount);
        InventoryPostingSetup.Validate("Mfg. Overhead Variance Account", MfgOverheadVarianceAccount);

        InventoryPostingSetup.Insert();
    end;

    local procedure InsertGeneralPostingSetup(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20];
                                        PurchaseAcc: Code[20]; PurchDiscAcc: Code[20]; PurchPmtDiscTolAcc: Code[20]; PurchPrepAcc: Code[20];
                                        InvAdjAcc: Code[20]; InvtAccrualAccInterim: Code[20]; DirectedCostAppliedAcc: Code[20]; OverheadAppliedAcc: Code[20]; PuchVarianceAcc: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if GeneralPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup) then
            exit;

        GeneralPostingSetup.Init();
        GeneralPostingSetup.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        GeneralPostingSetup.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);

        if PurchaseAcc <> '' then begin
            GeneralPostingSetup.Validate("Purch. Account", PurchaseAcc);
            GeneralPostingSetup.Validate("Purch. Credit Memo Account", PurchaseAcc);
            GeneralPostingSetup.Validate("Purch. Line Disc. Account", PurchDiscAcc);
            GeneralPostingSetup.Validate("Purch. Inv. Disc. Account", PurchDiscAcc);
            GeneralPostingSetup.Validate("Purch. Pmt. Disc. Credit Acc.", PurchPmtDiscTolAcc);
            GeneralPostingSetup.Validate("Purch. Pmt. Disc. Debit Acc.", PurchPmtDiscTolAcc);
            GeneralPostingSetup.Validate("Purch. Pmt. Tol. Credit Acc.", PurchPmtDiscTolAcc);
            GeneralPostingSetup.Validate("Purch. Pmt. Tol. Debit Acc.", PurchPmtDiscTolAcc);
            GeneralPostingSetup.Validate("Purch. Prepayments Account", PurchPrepAcc);
            GeneralPostingSetup.Validate("Purchase Variance Account", PuchVarianceAcc);
        end;

        GeneralPostingSetup.Validate("Direct Cost Applied Account", DirectedCostAppliedAcc);
        GeneralPostingSetup.Validate("Overhead Applied Account", OverheadAppliedAcc);

        GeneralPostingSetup.Validate("Inventory Adjmt. Account", InvAdjAcc);
        GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", InvtAccrualAccInterim);

        OnBeforeGeneralPostingSetupInsert(GeneralPostingSetup);

        GeneralPostingSetup.Insert();
        UpdateGeneralPostingSetup(GenBusPostingGroup, GenProdPostingGroup, InvAdjAcc, InvtAccrualAccInterim, DirectedCostAppliedAcc, OverheadAppliedAcc)
    end;

    local procedure UpdateGeneralPostingSetup(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; InvAdjAcc: Code[20]; InvtAccrualAccInterim: Code[20];
                                        DirectedCostAppliedAcc: Code[20]; OverheadAppliedAcc: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if GeneralPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup) then begin
            if GeneralPostingSetup."Direct Cost Applied Account" = '' then
                GeneralPostingSetup.Validate("Direct Cost Applied Account", DirectedCostAppliedAcc);
            if GeneralPostingSetup."Overhead Applied Account" = '' then
                GeneralPostingSetup.Validate("Overhead Applied Account", OverheadAppliedAcc);

            if GeneralPostingSetup."Inventory Adjmt. Account" = '' then
                GeneralPostingSetup.Validate("Inventory Adjmt. Account", InvAdjAcc);
            if GeneralPostingSetup."Invt. Accrual Acc. (Interim)" = '' then
                GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", InvtAccrualAccInterim);

            GeneralPostingSetup.Modify();
        end;
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeGenProductPostingGroupInsert(var GenProductPostingGroup: Record "Gen. Product Posting Group")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGeneralPostingSetupInsert(var GeneralPostingSetup: Record "General Posting Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGenBusinessPostingGroupInsert(var GenBusinessPostingGroup: Record "Gen. Business Posting Group")
    begin
    end;
}