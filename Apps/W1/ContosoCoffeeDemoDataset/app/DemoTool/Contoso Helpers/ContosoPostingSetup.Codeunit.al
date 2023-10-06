codeunit 5136 "Contoso Posting Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "General Posting Setup" = rim,
        tabledata "VAT Posting Setup" = rim,
        tabledata "Inventory Posting Setup" = rim;

    var
        VATSetupDescTok: Label 'Setup for %1 / %2', MaxLength = 100, Comment = '%1 is the VAT Bus. Posting Group Code, %2 is the VAT Prod. Posting Group Code';
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertGeneralPostingSetup(GenBusPostingGroupCode: Code[20]; GenProdPostingGroup: Code[20]; SalesAccount: Code[20]; PurchaseAccount: Code[20])
    begin
        InsertGeneralPostingSetup(GenBusPostingGroupCode, GenProdPostingGroup, SalesAccount, PurchaseAccount, '', '', '', '');
    end;

    procedure InsertGeneralPostingSetup(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; SalesAccount: Code[20]; PurchaseAccount: Code[20]; InventoryAdjustmentAccount: Code[20]; DirectedCostAppliedAcc: Code[20]; OverheadAppliedAcc: Code[20]; PurchaseVarianceAccount: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
        Exists: Boolean;
    begin
        if GeneralPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GeneralPostingSetup.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        GeneralPostingSetup.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);

        GeneralPostingSetup.Validate("Sales Account", SalesAccount);
        GeneralPostingSetup.Validate("Sales Credit Memo Account", SalesAccount);

        GeneralPostingSetup.Validate("Purch. Account", PurchaseAccount);
        GeneralPostingSetup.Validate("Purch. Credit Memo Account", PurchaseAccount);

        GeneralPostingSetup.Validate("Inventory Adjmt. Account", InventoryAdjustmentAccount);
        GeneralPostingSetup.Validate("Direct Cost Applied Account", DirectedCostAppliedAcc);
        GeneralPostingSetup.Validate("Overhead Applied Account", OverheadAppliedAcc);
        GeneralPostingSetup.Validate("Purchase Variance Account", PurchaseVarianceAccount);

        if Exists then
            GeneralPostingSetup.Modify(true)
        else
            GeneralPostingSetup.Insert(true);
    end;

    procedure InsertVATPostingSetup(VATBusinessGroupCode: Code[20]; VATProductGroupCode: Code[20]; SalesVATAccountNo: Code[20]; PurchaseVATAccountNo: Code[20]; VATIdentifier: Code[20]; VATPercentage: Decimal; VATCalculationType: Enum "Tax Calculation Type")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Exists: Boolean;
    begin
        if VATPostingSetup.Get(VATBusinessGroupCode, VATProductGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATPostingSetup.Validate("VAT Bus. Posting Group", VATBusinessGroupCode);
        VATPostingSetup.Validate("VAT Prod. Posting Group", VATProductGroupCode);
        VATPostingSetup.Validate(Description, StrSubstNo(VATSetupDescTok, VATBusinessGroupCode, VATProductGroupCode));

        // Need to check if we are changing the VAT Calculation Type before we validate it
        // The validation tries to find VAT Entry no matter we are changing the VAT Calculation Type or not
        if Exists then begin
            if VATPostingSetup."VAT Calculation Type" <> VATCalculationType then
                VATPostingSetup.Validate("VAT Calculation Type", VATCalculationType);
        end else
            VATPostingSetup.Validate("VAT Calculation Type", VATCalculationType);

        if not (VATPostingSetup."VAT Calculation Type" = Enum::"Tax Calculation Type"::"Sales Tax") then begin
            VATPostingSetup.Validate("Sales VAT Account", SalesVATAccountNo);
            VATPostingSetup.Validate("Purchase VAT Account", PurchaseVATAccountNo);
            VATPostingSetup.Validate("VAT Identifier", VATIdentifier);
            VATPostingSetup.Validate("VAT %", VATPercentage);
        end;

        if Exists then
            VATPostingSetup.Modify(true)
        else
            VATPostingSetup.Insert(true);
    end;

    procedure InsertInventoryPostingSetup(LocationCode: Code[10]; InventoryPostingGroupCode: Code[20]; InventoryAccount: Code[20]; InventoryAccountInterim: Code[20]; WIPAccount: Code[20]; MaterialVarianceAccount: Code[20]; CapacityVarianceAccount: Code[20]; SubcontractedVarianceAccount: Code[20]; CapOverheadVarianceAccount: Code[20]; MfgOverheadVarianceAccount: Code[20])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        Exists: Boolean;
    begin
        if InventoryPostingSetup.Get(LocationCode, InventoryPostingGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        InventoryPostingSetup.Validate("Location Code", LocationCode);
        InventoryPostingSetup.Validate("Invt. Posting Group Code", InventoryPostingGroupCode);
        InventoryPostingSetup.Validate("Inventory Account", InventoryAccount);
        InventoryPostingSetup.Validate("Inventory Account (Interim)", InventoryAccountInterim);
        InventoryPostingSetup.Validate("WIP Account", WIPAccount);
        InventoryPostingSetup.Validate("Material Variance Account", MaterialVarianceAccount);
        InventoryPostingSetup.Validate("Capacity Variance Account", CapacityVarianceAccount);
        InventoryPostingSetup.Validate("Subcontracted Variance Account", SubcontractedVarianceAccount);
        InventoryPostingSetup.Validate("Cap. Overhead Variance Account", CapOverheadVarianceAccount);
        InventoryPostingSetup.Validate("Mfg. Overhead Variance Account", MfgOverheadVarianceAccount);

        if Exists then
            InventoryPostingSetup.Modify(true)
        else
            InventoryPostingSetup.Insert(true);
    end;

    procedure InsertInventoryPostingSetup(LocationCode: Code[10]; InventoryPostingGroupCode: Code[20]; InventoryAccount: Code[20]; InventoryAccountInterim: Code[20])
    begin
        InsertInventoryPostingSetup(LocationCode, InventoryPostingGroupCode, InventoryAccount, InventoryAccountInterim, '', '', '', '', '', '');
    end;
}