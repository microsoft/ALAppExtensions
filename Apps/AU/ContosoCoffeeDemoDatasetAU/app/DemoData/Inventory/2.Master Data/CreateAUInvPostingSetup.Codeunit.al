codeunit 17119 "Create AU Inv Posting Setup"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateAUInvPostingGroup: Codeunit "Create AU Inv Posting Group";
        CreateAUGLAccounts: Codeunit "Create AU GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateLocation: Codeunit "Create Location";
        CreateInventoryPostingGroup: Codeunit "Create Inventory Posting Group";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertInventoryPostingSetup(BlankLocationLbl, CreateAUInvPostingGroup.Finished(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsInterim(), CreateAUGLAccounts.WipAccountFinishedGoods(), CreateAUGLAccounts.MaterialVariance(), CreateAUGLAccounts.CapacityVariance(), CreateAUGLAccounts.SubcontractedVariance(), CreateAUGLAccounts.CapOverheadVariance(), CreateAUGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(BlankLocationLbl, CreateAUInvPostingGroup.RAWMAT(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsInterim(), CreateAUGLAccounts.WipAccountFinishedGoods(), CreateAUGLAccounts.MaterialVariance(), CreateAUGLAccounts.CapacityVariance(), CreateAUGLAccounts.SubcontractedVariance(), CreateAUGLAccounts.CapOverheadVariance(), CreateAUGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.EastLocation(), CreateAUInvPostingGroup.Finished(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsInterim(), CreateAUGLAccounts.WipAccountFinishedGoods(), CreateAUGLAccounts.MaterialVariance(), CreateAUGLAccounts.CapacityVariance(), CreateAUGLAccounts.SubcontractedVariance(), CreateAUGLAccounts.CapOverheadVariance(), CreateAUGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.EastLocation(), CreateAUInvPostingGroup.RAWMAT(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsInterim(), CreateAUGLAccounts.WipAccountFinishedGoods(), CreateAUGLAccounts.MaterialVariance(), CreateAUGLAccounts.CapacityVariance(), CreateAUGLAccounts.SubcontractedVariance(), CreateAUGLAccounts.CapOverheadVariance(), CreateAUGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.MainLocation(), CreateAUInvPostingGroup.Finished(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsInterim(), CreateAUGLAccounts.WipAccountFinishedGoods(), CreateAUGLAccounts.MaterialVariance(), CreateAUGLAccounts.CapacityVariance(), CreateAUGLAccounts.SubcontractedVariance(), CreateAUGLAccounts.CapOverheadVariance(), CreateAUGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.MainLocation(), CreateAUInvPostingGroup.RAWMAT(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsInterim(), CreateAUGLAccounts.WipAccountFinishedGoods(), CreateAUGLAccounts.MaterialVariance(), CreateAUGLAccounts.CapacityVariance(), CreateAUGLAccounts.SubcontractedVariance(), CreateAUGLAccounts.CapOverheadVariance(), CreateAUGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.WestLocation(), CreateAUInvPostingGroup.Finished(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsInterim(), CreateAUGLAccounts.WipAccountFinishedGoods(), CreateAUGLAccounts.MaterialVariance(), CreateAUGLAccounts.CapacityVariance(), CreateAUGLAccounts.SubcontractedVariance(), CreateAUGLAccounts.CapOverheadVariance(), CreateAUGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.WestLocation(), CreateAUInvPostingGroup.RAWMAT(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsInterim(), CreateAUGLAccounts.WipAccountFinishedGoods(), CreateAUGLAccounts.MaterialVariance(), CreateAUGLAccounts.CapacityVariance(), CreateAUGLAccounts.SubcontractedVariance(), CreateAUGLAccounts.CapOverheadVariance(), CreateAUGLAccounts.MfgOverheadVariance());
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OutLogLocation(), CreateAUInvPostingGroup.Finished(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsInterim(), '', '', '', '', '', '');
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OutLogLocation(), CreateAUInvPostingGroup.RAWMAT(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsInterim(), '', '', '', '', '', '');
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OwnLogLocation(), CreateAUInvPostingGroup.Finished(), CreateGLAccount.FinishedGoods(), CreateGLAccount.FinishedGoodsInterim(), '', '', '', '', '', '');
        ContosoPostingSetup.InsertInventoryPostingSetup(CreateLocation.OwnLogLocation(), CreateAUInvPostingGroup.RAWMAT(), CreateGLAccount.RawMaterials(), CreateGLAccount.RawMaterialsInterim(), '', '', '', '', '', '');

        ContosoPostingSetup.SetOverwriteData(false);
        UpdateInventoryPostingSetupGLAccounts(CreateLocation.OwnLogLocation(), CreateInventoryPostingGroup.Resale());
        UpdateInventoryPostingSetupGLAccounts(CreateLocation.OutLogLocation(), CreateInventoryPostingGroup.Resale());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Inventory Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Inventory Posting Setup"; RunTrigger: Boolean)
    var
        CreateInventoryPostingGroup: Codeunit "Create Inventory Posting Group";
        CreateAUGLAccounts: Codeunit "Create AU GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateLocation: Codeunit "Create Location";
    begin
        case Rec."Location Code" of
            BlankLocationLbl,
            CreateLocation.EastLocation(),
            CreateLocation.MainLocation(),
            CreateLocation.OutLogLocation(),
            CreateLocation.OwnLogLocation(),
            CreateLocation.WestLocation():
                if Rec."Invt. Posting Group Code" = CreateInventoryPostingGroup.Resale() then
                    ValidateRecordFields(Rec, CreateGLAccount.ResaleItems(), CreateGLAccount.ResaleItemsInterim(), CreateAUGLAccounts.WipAccountFinishedGoods(), CreateAUGLAccounts.MaterialVariance(), CreateAUGLAccounts.CapacityVariance(), CreateAUGLAccounts.MfgOverheadVariance(), CreateAUGLAccounts.CapOverheadVariance(), CreateAUGLAccounts.SubcontractedVariance());
        end;
    end;

    local procedure UpdateInventoryPostingSetupGLAccounts(LocationCode: Code[20]; InvtPostingGroupCode: code[20])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        InventoryPostingSetup.Get(LocationCode, InvtPostingGroupCode);
        InventoryPostingSetup.Validate("WIP Account", '');
        InventoryPostingSetup.Validate("Material Variance Account", '');
        InventoryPostingSetup.Validate("Capacity Variance Account", '');
        InventoryPostingSetup.Validate("Mfg. Overhead Variance Account", '');
        InventoryPostingSetup.Validate("Cap. Overhead Variance Account", '');
        InventoryPostingSetup.Validate("Subcontracted Variance Account", '');
        InventoryPostingSetup.Modify(true);
    end;

    local procedure ValidateRecordFields(var InventoryPostingSetup: Record "Inventory Posting Setup"; InventoryAccount: Code[20]; InventoryAccountInterim: Code[20]; WIPAccount: Code[20]; MaterialVarianceAccount: Code[20]; CapacityVarianceAccount: Code[20]; MfgOverheadVarianceAccount: Code[20]; CapOverheadVarianceAccount: Code[20]; SubcontractedVarianceAccount: Code[20])
    begin
        InventoryPostingSetup.Validate("Inventory Account", InventoryAccount);
        InventoryPostingSetup.Validate("Inventory Account (Interim)", InventoryAccountInterim);
        InventoryPostingSetup.Validate("WIP Account", WIPAccount);
        InventoryPostingSetup.Validate("Material Variance Account", MaterialVarianceAccount);
        InventoryPostingSetup.Validate("Capacity Variance Account", CapacityVarianceAccount);
        InventoryPostingSetup.Validate("Mfg. Overhead Variance Account", MfgOverheadVarianceAccount);
        InventoryPostingSetup.Validate("Cap. Overhead Variance Account", CapOverheadVarianceAccount);
        InventoryPostingSetup.Validate("Subcontracted Variance Account", SubcontractedVarianceAccount);
    end;

    var
        BlankLocationLbl: Label '', MaxLength = 10;
}