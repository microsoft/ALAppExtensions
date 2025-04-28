#pragma warning disable AA0247
codeunit 31187 "Create FA Posting Group CZF"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"FA Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertFAPostingGroup(var Rec: Record "FA Posting Group")
    var
        CreateFAPostingGroup: Codeunit "Create FA Posting Group";
        CreateFAPostingGroupCZ: Codeunit "Create FA Posting Group CZ";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
    begin
        case Rec.Code of
            CreateFAPostingGroup.Equipment():
                ValidateFAPostingGroup(Rec, CreateGLAccountCZ.AccumulatedDepreciationToMachinery(), CreateGLAccountCZ.AccumulatedDepreciationToMachinery());
            CreateFAPostingGroup.Goodwill():
                ValidateFAPostingGroup(Rec, CreateGLAccountCZ.Accumulateddepreciationtogoodwill(), CreateGLAccountCZ.Accumulateddepreciationtogoodwill());
            CreateFAPostingGroup.Plant():
                ValidateFAPostingGroup(Rec, CreateGLAccountCZ.AccumulatedDepreciationToBuildings(), CreateGLAccountCZ.AccumulatedDepreciationToBuildings());
            CreateFAPostingGroup.Property():
                ValidateFAPostingGroup(Rec, CreateGLAccountCZ.AccumulatedDepreciationToBuildings(), CreateGLAccountCZ.AccumulatedDepreciationToBuildings());
            CreateFAPostingGroup.Vehicles():
                ValidateFAPostingGroup(Rec, CreateGLAccountCZ.AccumulatedDepreciationToVehicles(), CreateGLAccountCZ.AccumulatedDepreciationToVehicles());
            CreateFAPostingGroupCZ.Furniture():
                ValidateFAPostingGroup(Rec, CreateGLAccountCZ.AccumulatedDepreciationToMachinery(), CreateGLAccountCZ.AccumulatedDepreciationToMachinery());
            CreateFAPostingGroupCZ.Patents():
                ValidateFAPostingGroup(Rec, CreateGLAccountCZ.Accumulateddepreciationtointangibleresultsofresearchanddevelopment(), CreateGLAccountCZ.Accumulateddepreciationtointangibleresultsofresearchanddevelopment());
            CreateFAPostingGroupCZ.Software():
                ValidateFAPostingGroup(Rec, CreateGLAccountCZ.Accumulateddepreciationtosoftware(), CreateGLAccountCZ.Accumulateddepreciationtosoftware());
        end;
    end;

    local procedure ValidateFAPostingGroup(var FAPostingGroup: Record "FA Posting Group"; AcqCostBalAccDispCZF: Code[20]; BookValueBalAccOnDisposal: Code[20])
    begin
        FAPostingGroup.Validate("Acq. Cost Bal. Acc. Disp. CZF", AcqCostBalAccDispCZF);
        FAPostingGroup.Validate("Book Value Bal. Acc. Disp. CZF", BookValueBalAccOnDisposal);
    end;
}
