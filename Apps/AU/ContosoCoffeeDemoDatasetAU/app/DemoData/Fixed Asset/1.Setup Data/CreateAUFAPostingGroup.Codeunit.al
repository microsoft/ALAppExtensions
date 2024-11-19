codeunit 17147 "Create AU FA Posting Group"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoFixedAsset.SetOverwriteData(true);
        ContosoFixedAsset.InsertFAPostingGroup(Building(), CreateGLAccount.LandAndBuildings(), CreateGLAccount.AccumDepreciationBuildings(), CreateGLAccount.LandAndBuildings(), CreateGLAccount.AccumDepreciationBuildings(), CreateGLAccount.GainsAndLosses(), CreateGLAccount.GainsAndLosses(), CreateGLAccount.RepairsAndMaintenance(), CreateGLAccount.DepreciationBuildings(), CreateGLAccount.LandAndBuildings());
        ContosoFixedAsset.SetOverwriteData(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertFAPostingGroups(var Rec: Record "FA Posting Group")
    var
        CreateFAPostingGrp: Codeunit "Create FA Posting Group";
        CreateAUGLAccounts: Codeunit "Create AU GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateFAPostingGrp.Equipment(),
            CreateFAPostingGrp.Goodwill(),
            CreateFAPostingGrp.Plant(),
            CreateFAPostingGrp.Property():
                // CreateFAPostingGrp.IP(),
                // CreateFAPostingGrp.LeaseHold(),
                // CreateFAPostingGrp.Patents(),
                // CreateFAPostingGrp.Furniture():
                ValidateRecordFields(Rec, CreateAUGLAccounts.OfficeEquipment(), CreateGLAccount.AccumDeprOperEquip(), CreateAUGLAccounts.OfficeEquipment(), CreateGLAccount.AccumDeprOperEquip(), CreateGLAccount.GainsAndLosses(), CreateGLAccount.GainsAndLosses(), CreateGLAccount.RepairsAndMaintenance(), CreateGLAccount.DepreciationEquipment(), CreateAUGLAccounts.OfficeEquipment());
            CreateFAPostingGrp.Vehicles():
                ValidateRecordFields(Rec, CreateGLAccount.Vehicles(), CreateGLAccount.AccumDepreciationVehicles(), CreateGLAccount.Vehicles(), CreateGLAccount.AccumDepreciationVehicles(), CreateGLAccount.GainsAndLosses(), CreateGLAccount.GainsAndLosses(), CreateGLAccount.RepairsAndMaintenance(), CreateGLAccount.DepreciationVehicles(), CreateGLAccount.Vehicles());
        end;
    end;

    local procedure ValidateRecordFields(var FAPostingGroup: Record "FA Posting Group"; AcquisitionCostAccount: Code[20]; AccumDepreciationAccount: Code[20]; AcqCostAccOnDisposal: Code[20]; AccumDeprAccOnDisposal: Code[20]; GainsAccOnDisposal: Code[20]; LossesAccOnDisposal: Code[20]; MaintenanceExpenseAccount: Code[20]; DepreciationExpenseAcc: Code[20]; AcquisitionCostBalAcc: Code[20])
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

    procedure Building(): Code[20]
    begin
        exit(BuildingTok);
    end;

    var
        BuildingTok: Label 'BUILDING', MaxLength = 20;
}