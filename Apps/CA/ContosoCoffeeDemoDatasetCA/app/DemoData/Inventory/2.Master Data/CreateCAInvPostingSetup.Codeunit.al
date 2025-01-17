codeunit 27060 "Create CA Inv. Posting Setup"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateLocation: Codeunit "Create Location";
        CreateCAInvPostingGroup: Codeunit "Create CA Inv. Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateCAGLAccounts: Codeunit "Create CA GL Accounts";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
    begin
        ContosoPostingSetup.InsertInventoryPostingSetup('', CreateCAInvPostingGroup.Finished(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsInterim(), CreateCAGLAccounts.WipAccountFinishedGoods(), CreateCAGLAccounts.MaterialVariance(), CreateCAGLAccounts.CapacityVariance(), CreateCAGLAccounts.SubcontractedVariance(), CreateCAGLAccounts.CapOverheadVariance(), CreateCAGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.EastLocation(), CreateCAInvPostingGroup.Finished(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsInterim(), CreateCAGLAccounts.WipAccountFinishedGoods(), CreateCAGLAccounts.MaterialVariance(), CreateCAGLAccounts.CapacityVariance(), CreateCAGLAccounts.SubcontractedVariance(), CreateCAGLAccounts.CapOverheadVariance(), CreateCAGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.WestLocation(), CreateCAInvPostingGroup.Finished(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsInterim(), CreateCAGLAccounts.WipAccountFinishedGoods(), CreateCAGLAccounts.MaterialVariance(), CreateCAGLAccounts.CapacityVariance(), CreateCAGLAccounts.SubcontractedVariance(), CreateCAGLAccounts.CapOverheadVariance(), CreateCAGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.MainLocation(), CreateCAInvPostingGroup.Finished(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsInterim(), CreateCAGLAccounts.WipAccountFinishedGoods(), CreateCAGLAccounts.MaterialVariance(), CreateCAGLAccounts.CapacityVariance(), CreateCAGLAccounts.SubcontractedVariance(), CreateCAGLAccounts.CapOverheadVariance(), CreateCAGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OutLogLocation(), CreateCAInvPostingGroup.Finished(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsInterim(), '', '', '', '', '', '');
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OwnLogLocation(), CreateCAInvPostingGroup.Finished(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsInterim(), '', '', '', '', '', '');

        ContosoPostingSetup.InsertInventoryPostingSetup('', CreateCAInvPostingGroup.RawMaterial(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsInterim(), CreateCAGLAccounts.WipAccountFinishedGoods(), CreateCAGLAccounts.MaterialVariance(), CreateCAGLAccounts.CapacityVariance(), CreateCAGLAccounts.SubcontractedVariance(), CreateCAGLAccounts.CapOverheadVariance(), CreateCAGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.EastLocation(), CreateCAInvPostingGroup.RawMaterial(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsInterim(), CreateCAGLAccounts.WipAccountFinishedGoods(), CreateCAGLAccounts.MaterialVariance(), CreateCAGLAccounts.CapacityVariance(), CreateCAGLAccounts.SubcontractedVariance(), CreateCAGLAccounts.CapOverheadVariance(), CreateCAGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.WestLocation(), CreateCAInvPostingGroup.RawMaterial(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsInterim(), CreateCAGLAccounts.WipAccountFinishedGoods(), CreateCAGLAccounts.MaterialVariance(), CreateCAGLAccounts.CapacityVariance(), CreateCAGLAccounts.SubcontractedVariance(), CreateCAGLAccounts.CapOverheadVariance(), CreateCAGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.MainLocation(), CreateCAInvPostingGroup.RawMaterial(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsInterim(), CreateCAGLAccounts.WipAccountFinishedGoods(), CreateCAGLAccounts.MaterialVariance(), CreateCAGLAccounts.CapacityVariance(), CreateCAGLAccounts.SubcontractedVariance(), CreateCAGLAccounts.CapOverheadVariance(), CreateCAGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OutLogLocation(), CreateCAInvPostingGroup.RawMaterial(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsInterim(), '', '', '', '', '', '');
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OwnLogLocation(), CreateCAInvPostingGroup.RawMaterial(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsInterim(), '', '', '', '', '', '');

    end;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Inventory Posting Setup")
    var
        CreateLocation: Codeunit "Create Location";
        CreateInventoryPostingGroup: Codeunit "Create Inventory Posting Group";
        CreateCAGLAccounts: Codeunit "Create CA GL Accounts";
    begin
        if Rec."Invt. Posting Group Code" = CreateInventoryPostingGroup.Resale() then
            case Rec."Location Code" of
                BlankLocationLbl:
                    ValidateRecordFields(Rec, CreateCAGLAccounts.WipAccountFinishedGoods(), CreateCAGLAccounts.MaterialVariance(), CreateCAGLAccounts.CapacityVariance(), CreateCAGLAccounts.SubcontractedVariance(), CreateCAGLAccounts.CapOverheadVariance(), CreateCAGLAccounts.MfgOverheadVariance());
                CreateLocation.EastLocation():
                    ValidateRecordFields(Rec, CreateCAGLAccounts.WipAccountFinishedGoods(), CreateCAGLAccounts.MaterialVariance(), CreateCAGLAccounts.CapacityVariance(), CreateCAGLAccounts.SubcontractedVariance(), CreateCAGLAccounts.CapOverheadVariance(), CreateCAGLAccounts.MfgOverheadVariance());
                CreateLocation.MainLocation():
                    ValidateRecordFields(Rec, CreateCAGLAccounts.WipAccountFinishedGoods(), CreateCAGLAccounts.MaterialVariance(), CreateCAGLAccounts.CapacityVariance(), CreateCAGLAccounts.SubcontractedVariance(), CreateCAGLAccounts.CapOverheadVariance(), CreateCAGLAccounts.MfgOverheadVariance());
                CreateLocation.WestLocation():
                    ValidateRecordFields(Rec, CreateCAGLAccounts.WipAccountFinishedGoods(), CreateCAGLAccounts.MaterialVariance(), CreateCAGLAccounts.CapacityVariance(), CreateCAGLAccounts.SubcontractedVariance(), CreateCAGLAccounts.CapOverheadVariance(), CreateCAGLAccounts.MfgOverheadVariance());
            end;
    end;

    local procedure ValidateRecordFields(var InventoryPostingSetup: Record "Inventory Posting Setup"; WIPAccount: Code[20]; MaterialVarianceAccount: Code[20]; CapacityVarianceAccount: Code[20]; SubcontractedVarianceAccount: Code[20]; CapOverheadVarianceAccount: Code[20]; MfgOverheadVarianceAccount: Code[20])
    begin
        InventoryPostingSetup.Validate("WIP Account", WIPAccount);
        InventoryPostingSetup.Validate("Material Variance Account", MaterialVarianceAccount);
        InventoryPostingSetup.Validate("Capacity Variance Account", CapacityVarianceAccount);
        InventoryPostingSetup.Validate("Subcontracted Variance Account", SubcontractedVarianceAccount);
        InventoryPostingSetup.Validate("Cap. Overhead Variance Account", CapOverheadVarianceAccount);
        InventoryPostingSetup.Validate("Mfg. Overhead Variance Account", MfgOverheadVarianceAccount);
    end;

    var
        BlankLocationLbl: Label '', MaxLength = 20;
}