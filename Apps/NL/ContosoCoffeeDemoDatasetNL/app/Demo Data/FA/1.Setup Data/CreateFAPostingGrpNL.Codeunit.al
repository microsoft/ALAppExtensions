codeunit 11541 "Create FA Posting Grp. NL"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"FA Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertFAPostingGroup(var Rec: Record "FA Posting Group")
    var
        CreateFAPostingGroup: Codeunit "Create FA Posting Group";
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
    begin
        case Rec.Code of
            CreateFAPostingGroup.Equipment():
                ValidateFAPostingGroup(Rec, CreateNLGLAccounts.EquipmentsandTools(), CreateNLGLAccounts.EquipmentsandTools(), CreateNLGLAccounts.EquipmentsandTools(), CreateNLGLAccounts.EquipmentsandTools(), CreateNLGLAccounts.EquipmentsandTools(), CreateNLGLAccounts.EquipmentsandTools(), CreateNLGLAccounts.DepreciationFixedAssets(), CreateNLGLAccounts.DepreciationFixedAssets(), CreateNLGLAccounts.DepreciationFixedAssets());
            CreateFAPostingGroup.Goodwill():
                ValidateFAPostingGroup(Rec, CreateNLGLAccounts.Goodwill(), CreateNLGLAccounts.Goodwill(), CreateNLGLAccounts.Goodwill(), CreateNLGLAccounts.Goodwill(), CreateNLGLAccounts.Goodwill(), CreateNLGLAccounts.Goodwill(), CreateNLGLAccounts.Goodwill(), CreateNLGLAccounts.Goodwill(), CreateNLGLAccounts.Goodwill());
            CreateFAPostingGroup.Plant():
                ValidateFAPostingGroup(Rec, CreateNLGLAccounts.Building(), CreateNLGLAccounts.Building(), CreateNLGLAccounts.Building(), CreateNLGLAccounts.Building(), CreateNLGLAccounts.Building(), CreateNLGLAccounts.Building(), CreateNLGLAccounts.DepreciationLandandProperty(), CreateNLGLAccounts.DepreciationLandandProperty(), CreateNLGLAccounts.DepreciationLandandProperty());
            CreateFAPostingGroup.Property():
                ValidateFAPostingGroup(Rec, CreateNLGLAccounts.Land(), CreateNLGLAccounts.Land(), CreateNLGLAccounts.Land(), CreateNLGLAccounts.Land(), CreateNLGLAccounts.Land(), CreateNLGLAccounts.Land(), CreateNLGLAccounts.DepreciationLandandProperty(), CreateNLGLAccounts.DepreciationLandandProperty(), CreateNLGLAccounts.DepreciationLandandProperty());
            CreateFAPostingGroup.Vehicles():
                ValidateFAPostingGroup(Rec, CreateNLGLAccounts.CarsandotherTransportEquipments(), CreateNLGLAccounts.CarsandotherTransportEquipments(), CreateNLGLAccounts.CarsandotherTransportEquipments(), CreateNLGLAccounts.CarsandotherTransportEquipments(), CreateNLGLAccounts.CarsandotherTransportEquipments(), CreateNLGLAccounts.CarsandotherTransportEquipments(), CreateNLGLAccounts.DepreciationFixedAssets(), CreateNLGLAccounts.DepreciationFixedAssets(), CreateNLGLAccounts.DepreciationFixedAssets());
        end;
    end;

    local procedure ValidateFAPostingGroup(var FAPostingGroup: Record "FA Posting Group"; AcquisitionCostAccount: Code[20]; AccumDepreciationAccount: Code[20]; AcqCostAccOnDisposal: Code[20]; AccumDeprAccOnDisposal: Code[20]; GainsAccOnDisposal: Code[20]; LossesAccOnDisposal: Code[20]; MaintenanceExpenseAccount: Code[20]; DepreciationExpenseAcc: Code[20]; AcquisitionCostBalAcc: Code[20])
    begin
        FAPostingGroup.Validate("Acquisition Cost Account", AcquisitionCostAccount);
        FAPostingGroup.Validate("Accum. Depreciation Account", AccumDepreciationAccount);
        FAPostingGroup.Validate("Acq. Cost Acc. on Disposal", AcqCostAccOnDisposal);
        FAPostingGroup.Validate("Accum. Depr. Acc. on Disposal", AccumDeprAccOnDisposal);
        FAPostingGroup.Validate("Gains Acc. on Disposal", GainsAccOnDisposal);
        FAPostingGroup.Validate("Losses Acc. on Disposal", LossesAccOnDisposal);
        FAPostingGroup.Validate("Maintenance Expense Account", MaintenanceExpenseAccount);
        FAPostingGroup.Validate("Depreciation Expense Acc.", DepreciationExpenseAcc);
        FAPostingGroup.Validate("Acquisition Cost Bal. Acc.", AcquisitionCostBalAcc);
    end;
}