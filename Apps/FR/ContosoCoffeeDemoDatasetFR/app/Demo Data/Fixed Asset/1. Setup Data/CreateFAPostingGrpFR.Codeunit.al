codeunit 10876 "Create FA Posting Grp. FR"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"FA Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertFAPostingGroup(var Rec: Record "FA Posting Group")
    var
        CreateFAPostingGroup: Codeunit "Create FA Posting Group";
        CreateFRGlAccount: Codeunit "Create GL Account FR";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateFAPostingGroup.Equipment(), CreateFAPostingGroup.Goodwill(), CreateFAPostingGroup.Plant(), CreateFAPostingGroup.Property(), CreateFAPostingGroup.Vehicles():
                ValidateFAPostingGroup(Rec, CreateGLAccount.IncreasesduringtheYearOperEquip(), CreateGLAccount.AccumDeprOperEquip(), CreateGLAccount.DecreasesduringtheYearOperEquip(), CreateGLAccount.AccumDeprOperEquip(), '', '', CreateFRGlAccount.BookValueOfAssetsSold(), CreateFRGlAccount.AssetsSoldGains(), CreateGLAccount.RepairsandMaintenance(), CreateGLAccount.DepreciationEquipment(), CreateGLAccount.IncreasesduringtheYearOperEquip(), CreateFRGlAccount.AssetsSoldGains(), CreateFRGlAccount.BookValueOfAssetsSold(), CreateFRGlAccount.DerogatoryAccount(), CreateFRGlAccount.DerogatoryAccount(), CreateFRGlAccount.DerogExpenseAccForCredit(), CreateFRGlAccount.DerogExpenseAccForDebit());
        end;
    end;

    local procedure ValidateFAPostingGroup(var FAPostingGroup: Record "FA Posting Group"; AcquisitionCostAccount: Code[20]; AccumDepreciationAccount: Code[20]; AcqCostAccOnDisposal: Code[20]; AccumDeprAccOnDisposal: Code[20]; GainsAccOnDisposal: Code[20]; LossesAccOnDisposal: Code[20]; BookValueGainAcc: Code[20]; SaleAccDisposalGain: Code[20]; MaintenanceExpenseAccount: Code[20]; DepreciationExpenseAcc: Code[20]; AcquisitionCostBalAcc: Code[20]; SalesAccDisposalLoss: Code[20]; BookValueLossAcc: Code[20]; DerogatoryAccount: Code[20]; DerogatoryAccountDecrease: Code[20]; DerogatoryBalDecreaseAcc: Code[20]; DerogatoryExpenseAcc: Code[20])
    begin
        FAPostingGroup.Validate("Acquisition Cost Account", AcquisitionCostAccount);
        FAPostingGroup.Validate("Accum. Depreciation Account", AccumDepreciationAccount);
        FAPostingGroup.Validate("Acq. Cost Acc. on Disposal", AcqCostAccOnDisposal);
        FAPostingGroup.Validate("Accum. Depr. Acc. on Disposal", AccumDeprAccOnDisposal);
        FAPostingGroup.Validate("Gains Acc. on Disposal", GainsAccOnDisposal);
        FAPostingGroup.Validate("Losses Acc. on Disposal", LossesAccOnDisposal);
        FAPostingGroup.Validate("Maintenance Expense Account", MaintenanceExpenseAccount);
        FAPostingGroup.Validate("Depreciation Expense Acc.", DepreciationExpenseAcc);
        FAPostingGroup.Validate("Sales Acc. on Disp. (Gain)", SaleAccDisposalGain);
        FAPostingGroup.Validate("Book Val. Acc. on Disp. (Gain)", BookValueGainAcc);
        FAPostingGroup.Validate("Sales Acc. on Disp. (Loss)", SalesAccDisposalLoss);
        FAPostingGroup.Validate("Book Val. Acc. on Disp. (Loss)", BookValueLossAcc);
        FAPostingGroup.Validate("Derogatory Account", DerogatoryAccount);
        FAPostingGroup.Validate("Derogatory Acc. (Decrease)", DerogatoryAccountDecrease);
        FAPostingGroup.Validate("Derog. Bal. Acc. (Decrease)", DerogatoryBalDecreaseAcc);
        FAPostingGroup.Validate("Derogatory Expense Account", DerogatoryExpenseAcc);
        FAPostingGroup.Validate("Acquisition Cost Bal. Acc.", AcquisitionCostBalAcc);
    end;
}