
codeunit 4762 "Create Mfg GL Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        GLAccountIndent: Codeunit "G/L Account-Indent";
    begin
        AddGLAccountsForLocalization();

        ContosoGLAccount.InsertGLAccount(FinishedGoods(), FinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(WIPAccountFinishedGoods(), WIPAccountFinishedGoodsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Enum::"G/L Account Type"::Posting);

        ContosoGLAccount.InsertGLAccount(MaterialVariance(), MaterialVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(CapacityVariance(), CapacityVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(SubcontractedVariance(), SubcontractedVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(CapOverheadVariance(), CapOverheadVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(MfgOverheadVariance(), MfgOverheadVarianceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);

        ContosoGLAccount.InsertGLAccount(DirectCostAppliedCap(), DirectCostAppliedCapName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(OverheadAppliedCap(), OverheadAppliedCapName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);
        ContosoGLAccount.InsertGLAccount(PurchaseVarianceCap(), PurchaseVarianceCapName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::"Cost of Goods Sold", Enum::"G/L Account Type"::Posting);

        GLAccountIndent.Indent();
    end;

    local procedure AddGLAccountsForLocalization()
    begin
        ContosoGLAccount.AddAccountForLocalization(FinishedGoodsName(), '2120');
        ContosoGLAccount.AddAccountForLocalization(WIPAccountFinishedGoodsName(), '2140');

        ContosoGLAccount.AddAccountForLocalization(MaterialVarianceName(), '7890');
        ContosoGLAccount.AddAccountForLocalization(CapacityVarianceName(), '7891');
        ContosoGLAccount.AddAccountForLocalization(SubcontractedVarianceName(), '7892');
        ContosoGLAccount.AddAccountForLocalization(CapOverheadVarianceName(), '7893');
        ContosoGLAccount.AddAccountForLocalization(MfgOverheadVarianceName(), '7894');

        ContosoGLAccount.AddAccountForLocalization(DirectCostAppliedCapName(), '7791');
        ContosoGLAccount.AddAccountForLocalization(OverheadAppliedCapName(), '7792');
        ContosoGLAccount.AddAccountForLocalization(PurchaseVarianceCapName(), '7793');

        OnAfterAddGLAccountsForLocalization();
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        FinishedGoodsTok: Label 'Finished Goods', MaxLength = 100;
        WIPAccountFinishedGoodsLbl: Label 'WIP Account, Finished Goods', MaxLength = 100;
        DirectCostAppliedCapTok: Label 'Direct Cost Applied, Capacity', MaxLength = 100;
        OverheadAppliedCapTok: Label 'Overhead Applied, Capacity', MaxLength = 100;
        PurchaseVarianceCapTok: Label 'Purchase Variance, Capacity', MaxLength = 100;
        MaterialVarianceTok: Label 'Material Variance', MaxLength = 100;
        CapacityVarianceTok: Label 'Capacity Variance', MaxLength = 100;
        SubcontractedVarianceTok: Label 'Subcontracted Variance', MaxLength = 100;
        CapOverheadVarianceTok: Label 'Capacity Overhead Variance', MaxLength = 100;
        MfgOverheadVarianceTok: Label 'Manufacturing Overhead Variance', MaxLength = 100;

    procedure FinishedGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FinishedGoodsName()));
    end;

    procedure FinishedGoodsName(): Text[100]
    begin
        exit(FinishedGoodsTok);
    end;

    procedure WIPAccountFinishedGoods(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(WIPAccountFinishedGoodsName()));
    end;

    procedure WIPAccountFinishedGoodsName(): Text[100]
    begin
        exit(WIPAccountFinishedGoodsLbl);
    end;

    procedure MaterialVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MaterialVarianceName()));
    end;

    procedure MaterialVarianceName(): Text[100]
    begin
        exit(MaterialVarianceTok);
    end;

    procedure CapacityVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapacityVarianceName()));
    end;

    procedure CapacityVarianceName(): Text[100]
    begin
        exit(CapacityVarianceTok);
    end;

    procedure SubcontractedVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SubcontractedVarianceName()));
    end;

    procedure SubcontractedVarianceName(): Text[100]
    begin
        exit(SubcontractedVarianceTok);
    end;

    procedure CapOverheadVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CapOverheadVarianceName()));
    end;

    procedure CapOverheadVarianceName(): Text[100]
    begin
        exit(CapOverheadVarianceTok);
    end;

    procedure MfgOverheadVariance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(MfgOverheadVarianceName()));
    end;

    procedure MfgOverheadVarianceName(): Text[100]
    begin
        exit(MfgOverheadVarianceTok);
    end;

    procedure DirectCostAppliedCap(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(DirectCostAppliedCapName()));
    end;

    procedure DirectCostAppliedCapName(): Text[100]
    begin
        exit(DirectCostAppliedCapTok);
    end;

    procedure OverheadAppliedCap(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OverheadAppliedCapName()));
    end;

    procedure OverheadAppliedCapName(): Text[100]
    begin
        exit(OverheadAppliedCapTok);
    end;

    procedure PurchaseVarianceCap(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PurchaseVarianceCapName()));
    end;

    procedure PurchaseVarianceCapName(): Text[100]
    begin
        exit(PurchaseVarianceCapTok);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddGLAccountsForLocalization()
    begin
    end;
}