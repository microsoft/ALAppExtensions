codeunit 13708 "Create FA Posting Grp. DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        CreateGLAccountDK: Codeunit "Create GL Acc. DK";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoFixedAsset.InsertFAPostingGroup(Furniture(), CreateGLAccountDK.AcquisitioncostLandBuildings(), CreateGLAccountDK.AccdepreciationLandBuildings(), CreateGLAccountDK.OutputLandBuildings(), CreateGLAccountDK.AccdepreciationLandBuildings(), CreateGLAccountDK.Chargeexsalestax(), CreateGLAccountDK.Chargebeforesalestax(), CreateGLAccount.RepairsandMaintenance(), CreateGLAccountDK.AcquisitioncostLandBuildings(), CreateGLAccount.LandandBuildings());
        ContosoFixedAsset.InsertFAPostingGroup(IP(), CreateGLAccountDK.AcquisitioncostLandBuildings(), CreateGLAccountDK.AccdepreciationLandBuildings(), CreateGLAccountDK.OutputLandBuildings(), CreateGLAccountDK.AccdepreciationLandBuildings(), CreateGLAccountDK.Chargeexsalestax(), CreateGLAccountDK.Chargebeforesalestax(), CreateGLAccount.RepairsandMaintenance(), CreateGLAccountDK.AcquisitioncostLandBuildings(), CreateGLAccount.LandandBuildings());
        ContosoFixedAsset.InsertFAPostingGroup(Leasehold(), CreateGLAccountDK.AcquisitioncostLandBuildings(), CreateGLAccountDK.AccdepreciationLandBuildings(), CreateGLAccountDK.OutputLandBuildings(), CreateGLAccountDK.AccdepreciationLandBuildings(), CreateGLAccountDK.Chargeexsalestax(), CreateGLAccountDK.Chargebeforesalestax(), CreateGLAccount.RepairsandMaintenance(), CreateGLAccountDK.AcquisitioncostLandBuildings(), CreateGLAccount.LandandBuildings());
        ContosoFixedAsset.InsertFAPostingGroup(Patents(), CreateGLAccountDK.AcquisitioncostLandBuildings(), CreateGLAccountDK.AccdepreciationLandBuildings(), CreateGLAccountDK.OutputLandBuildings(), CreateGLAccountDK.AccdepreciationLandBuildings(), CreateGLAccountDK.Chargeexsalestax(), CreateGLAccountDK.Chargebeforesalestax(), CreateGLAccount.RepairsandMaintenance(), CreateGLAccountDK.AcquisitioncostLandBuildings(), CreateGLAccount.LandandBuildings());
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertFAPostingGroups(var Rec: Record "FA Posting Group")
    var
        CreateFAPostingGrp: Codeunit "Create FA Posting Group";
        CreateGLAccountDK: Codeunit "Create GL Acc. DK";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateFAPostingGrp.Equipment(),
            CreateFAPostingGrp.Goodwill(),
            CreateFAPostingGrp.Plant(),
            CreateFAPostingGrp.Property(),
            CreateFAPostingGrp.Vehicles():
                ValidateRecordFields(Rec, CreateGLAccountDK.AcquisitioncostLandBuildings(), CreateGLAccountDK.AccdepreciationLandBuildings(), CreateGLAccountDK.OutputLandBuildings(), CreateGLAccountDK.AccdepreciationLandBuildings(), CreateGLAccountDK.Chargeexsalestax(), CreateGLAccountDK.Chargebeforesalestax(), CreateGLAccount.RepairsandMaintenance(), CreateGLAccountDK.AcquisitioncostLandBuildings(), CreateGLAccount.LandandBuildings());
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

    procedure Furniture(): Code[20]
    begin
        exit(FurnitureTok);
    end;

    procedure IP(): Code[20]
    begin
        exit(IPTok);
    end;

    procedure Leasehold(): Code[20]
    begin
        exit(LeaseholdTok);
    end;

    procedure Patents(): Code[20]
    begin
        exit(PatentsTok);
    end;

    var
        FurnitureTok: Label 'FURNITURE', Locked = true;
        IPTok: Label 'IP', Locked = true;
        LeaseHoldTok: Label 'LEASEHOLD', Locked = true;
        PatentsTok: Label 'PATENTS', Locked = true;
}