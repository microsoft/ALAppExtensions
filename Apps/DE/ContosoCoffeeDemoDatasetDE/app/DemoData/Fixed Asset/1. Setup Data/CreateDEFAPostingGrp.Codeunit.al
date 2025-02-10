codeunit 11115 "Create DE FA Posting Grp."
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"FA Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertFAPostingGroup(var Rec: Record "FA Posting Group")
    var
        CreateFAPostingGroup: Codeunit "Create FA Posting Group";
        CreateDEGlAccount: Codeunit "Create DE GL Acc.";
    begin
        case Rec.Code of
            CreateFAPostingGroup.Equipment():
                ValidateFAPostingGroup(Rec, CreateDEGlAccount.EquipmentsandTools(), CreateDEGlAccount.EquipmentsandTools(), CreateDEGlAccount.EquipmentsandTools(), CreateDEGlAccount.EquipmentsandTools(), CreateDEGlAccount.EquipmentsandTools(), CreateDEGlAccount.EquipmentsandTools(), CreateDEGlAccount.DepreciationFixedAssets(), CreateDEGlAccount.DepreciationFixedAssets(), CreateDEGlAccount.DepreciationFixedAssets());
            CreateFAPostingGroup.Goodwill():
                ValidateFAPostingGroup(Rec, CreateDEGlAccount.GoodWill(), CreateDEGlAccount.GoodWill(), CreateDEGlAccount.GoodWill(), CreateDEGlAccount.GoodWill(), CreateDEGlAccount.GoodWill(), CreateDEGlAccount.GoodWill(), CreateDEGlAccount.GoodWill(), CreateDEGlAccount.GoodWill(), CreateDEGlAccount.GoodWill());
            CreateFAPostingGroup.Plant():
                ValidateFAPostingGroup(Rec, CreateDEGlAccount.Building(), CreateDEGlAccount.Building(), CreateDEGlAccount.Building(), CreateDEGlAccount.Building(), CreateDEGlAccount.Building(), CreateDEGlAccount.Building(), CreateDEGlAccount.DepreciationFixedAssets(), CreateDEGlAccount.DepreciationFixedAssets(), CreateDEGlAccount.DepreciationFixedAssets());
            CreateFAPostingGroup.Property():
                ValidateFAPostingGroup(Rec, CreateDEGlAccount.Land(), CreateDEGlAccount.Land(), CreateDEGlAccount.Land(), CreateDEGlAccount.Land(), CreateDEGlAccount.Land(), CreateDEGlAccount.Land(), CreateDEGlAccount.DepreciationFixedAssets(), CreateDEGlAccount.DepreciationFixedAssets(), CreateDEGlAccount.DepreciationFixedAssets());
            CreateFAPostingGroup.Vehicles():
                ValidateFAPostingGroup(Rec, CreateDEGlAccount.CarsandotherTransportEquipments(), CreateDEGlAccount.CarsandotherTransportEquipments(), CreateDEGlAccount.CarsandotherTransportEquipments(), CreateDEGlAccount.CarsandotherTransportEquipments(), CreateDEGlAccount.CarsandotherTransportEquipments(), CreateDEGlAccount.CarsandotherTransportEquipments(), CreateDEGlAccount.DepreciationFixedAssets(), CreateDEGlAccount.DepreciationFixedAssets(), CreateDEGlAccount.DepreciationFixedAssets());
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