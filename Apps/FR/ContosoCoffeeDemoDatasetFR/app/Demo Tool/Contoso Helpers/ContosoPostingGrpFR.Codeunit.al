codeunit 10870 "Contoso Posting Grp FR"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "General Posting Setup" = rim;

    procedure validatePostingAccount(GeneralBusPostingGrp: Code[20]; GeneralProdPostingGrp: Code[20]; SalesAccount: Code[20]; PurchaseAccount: Code[20]; InventoryAdjustmentAccount: Code[20]; DirectedCostAppliedAcc: Code[20]; OverheadAppliedAcc: Code[20]; PurchaseVarianceAccount: Code[20]; SalesLineDiscAccount: Code[20]; SalesInvDiscAccount: Code[20]; PurchaselineDiscountAccount: Code[20]; PurchInvDiscAccount: Code[20]; COGSAccount: Code[20]; COGSAccountInterim: Code[20]; InvtAccrualAccInterim: Code[20]; SalesCreditMemoAcc: Code[20]; PurchCreditMemoAcc: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if not GeneralPostingSetup.Get(GeneralBusPostingGrp, GeneralProdPostingGrp) then
            exit;

        GeneralPostingSetup.Validate("Sales Account", SalesAccount);
        GeneralPostingSetup.Validate("Sales Line Disc. Account", SalesLineDiscAccount);
        GeneralPostingSetup.Validate("Sales Inv. Disc. Account", SalesInvDiscAccount);
        GeneralPostingSetup.Validate("Sales Credit Memo Account", SalesAccount);

        GeneralPostingSetup.Validate("Purch. Account", PurchaseAccount);
        GeneralPostingSetup.Validate("Purch. Line Disc. Account", PurchaselineDiscountAccount);
        GeneralPostingSetup.Validate("Purch. Inv. Disc. Account", PurchInvDiscAccount);
        GeneralPostingSetup.Validate("Purch. Credit Memo Account", PurchaseAccount);

        GeneralPostingSetup.Validate("COGS Account", COGSAccount);
        GeneralPostingSetup.Validate("COGS Account (Interim)", COGSAccountInterim);

        GeneralPostingSetup.Validate("Inventory Adjmt. Account", InventoryAdjustmentAccount);
        GeneralPostingSetup.Validate("Invt. Accrual Acc. (Interim)", InvtAccrualAccInterim);

        GeneralPostingSetup.Validate("Direct Cost Applied Account", DirectedCostAppliedAcc);
        GeneralPostingSetup.Validate("Overhead Applied Account", OverheadAppliedAcc);
        GeneralPostingSetup.Validate("Purchase Variance Account", PurchaseVarianceAccount);
        GeneralPostingSetup.Validate("Sales Credit Memo Account", SalesCreditMemoAcc);
        GeneralPostingSetup.Validate("Purch. Credit Memo Account", PurchCreditMemoAcc);
        GeneralPostingSetup.Modify(true);
    end;

    procedure ValidateVATPostingSetup(VatBusPostingGrp: Code[20]; VatProdPostingGrp: Code[20]; SalesVATAccount: Code[20]; PurchaseVATAccount: Code[20]; ReverseChargeVatAcc: Code[20]; VatPercent: Decimal)
    var
        VatPostingSetup: Record "VAT Posting Setup";
    begin
        if not VatPostingSetup.Get(VatBusPostingGrp, VatProdPostingGrp) then
            exit;

        VatPostingSetup.Validate("Sales VAT Account", SalesVATAccount);
        VatPostingSetup.Validate("Purchase VAT Account", PurchaseVATAccount);
        VatPostingSetup.Validate("Reverse Chrg. VAT Acc.", ReverseChargeVatAcc);
        VatPostingSetup.Validate("VAT %", VatPercent);
        VatPostingSetup.Modify(true);
    end;
}