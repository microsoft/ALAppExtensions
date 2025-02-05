codeunit 11495 "Create FA Posting Grp. US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"FA Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertFAPostingGroups(var Rec: Record "FA Posting Group")
    var
        CreateFAPostingGrp: Codeunit "Create FA Posting Group";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
    begin
        case Rec.Code of
            CreateFAPostingGrp.Equipment():
                ValidateRecordFields(Rec, CreateUSGLAccounts.EquipmentsandTools(), CreateUSGLAccounts.EquipmentsandTools(), CreateUSGLAccounts.EquipmentsandTools(), CreateUSGLAccounts.EquipmentsandTools(), CreateUSGLAccounts.EquipmentsandTools(), CreateUSGLAccounts.EquipmentsandTools(), CreateUSGLAccounts.DepreciationFixedAssets(), CreateUSGLAccounts.DepreciationFixedAssets(), CreateUSGLAccounts.DepreciationFixedAssets());
            CreateFAPostingGrp.Goodwill():
                ValidateRecordFields(Rec, CreateUSGLAccounts.Goodwill(), CreateUSGLAccounts.Goodwill(), CreateUSGLAccounts.Goodwill(), CreateUSGLAccounts.Goodwill(), CreateUSGLAccounts.Goodwill(), CreateUSGLAccounts.Goodwill(), CreateUSGLAccounts.Goodwill(), CreateUSGLAccounts.Goodwill(), CreateUSGLAccounts.Goodwill());
            CreateFAPostingGrp.Plant():
                ValidateRecordFields(Rec, CreateUSGLAccounts.Building(), CreateUSGLAccounts.Building(), CreateUSGLAccounts.Building(), CreateUSGLAccounts.Building(), CreateUSGLAccounts.Building(), CreateUSGLAccounts.Building(), CreateUSGLAccounts.DepreciationLandandProperty(), CreateUSGLAccounts.DepreciationLandandProperty(), CreateUSGLAccounts.DepreciationLandandProperty());
            CreateFAPostingGrp.Property():
                ValidateRecordFields(Rec, CreateUSGLAccounts.Land(), CreateUSGLAccounts.Land(), CreateUSGLAccounts.Land(), CreateUSGLAccounts.Land(), CreateUSGLAccounts.Land(), CreateUSGLAccounts.Land(), CreateUSGLAccounts.DepreciationLandandProperty(), CreateUSGLAccounts.DepreciationLandandProperty(), CreateUSGLAccounts.DepreciationLandandProperty());
            CreateFAPostingGrp.Vehicles():
                ValidateRecordFields(Rec, CreateUSGLAccounts.CarsandOtherTransportEquipments(), CreateUSGLAccounts.CarsandOtherTransportEquipments(), CreateUSGLAccounts.CarsandOtherTransportEquipments(), CreateUSGLAccounts.CarsandOtherTransportEquipments(), CreateUSGLAccounts.CarsandOtherTransportEquipments(), CreateUSGLAccounts.CarsandOtherTransportEquipments(), CreateUSGLAccounts.DepreciationFixedAssets(), CreateUSGLAccounts.DepreciationFixedAssets(), CreateUSGLAccounts.DepreciationFixedAssets());
        end;
    end;

    local procedure ValidateRecordFields(var FAPostingGroup: Record "FA Posting Group"; AcquisitionCostAccount: Code[20]; AccumDepreciationAccount: Code[20]; AcqCostAcconDisposal: Code[20]; AccumDeprAcconDisposal: Code[20]; GainsAcconDisposal: Code[20]; LossesAcconDisposal: Code[20]; MaintenanceExpenseAccount: Code[20]; AcquisitionCostBalAcc: Code[20]; DepreciationExpenseAcc: Code[20])
    begin
        FAPostingGroup.Validate("Acquisition Cost Account", AcquisitionCostAccount);
        FAPostingGroup.Validate("Accum. Depreciation Account", AccumDepreciationAccount);
        FAPostingGroup.Validate("Acq. Cost Acc. on Disposal", AcqCostAcconDisposal);
        FAPostingGroup.Validate("Accum. Depr. Acc. on Disposal", AccumDeprAcconDisposal);
        FAPostingGroup.Validate("Gains Acc. on Disposal", GainsAcconDisposal);
        FAPostingGroup.Validate("Losses Acc. on Disposal", LossesAcconDisposal);
        FAPostingGroup.Validate("Maintenance Expense Account", MaintenanceExpenseAccount);
        FAPostingGroup.Validate("Acquisition Cost Bal. Acc.", AcquisitionCostBalAcc);
        FAPostingGroup.Validate("Depreciation Expense Acc.", DepreciationExpenseAcc);
    end;
}