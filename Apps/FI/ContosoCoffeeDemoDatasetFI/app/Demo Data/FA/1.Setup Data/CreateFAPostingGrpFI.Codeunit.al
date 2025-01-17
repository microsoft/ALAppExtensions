codeunit 13445 "Create FA Posting Grp. FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"FA Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertFAPostingGroups(var Rec: Record "FA Posting Group")
    var
        CreateFAPostingGrp: Codeunit "Create FA Posting Group";
        CreateGLAccountFI: Codeunit "Create FI GL Accounts";
    begin
        case Rec.Code of
            CreateFAPostingGrp.Equipment(),
            CreateFAPostingGrp.Goodwill(),
            CreateFAPostingGrp.Plant(),
            CreateFAPostingGrp.Property(),
            CreateFAPostingGrp.Vehicles():
                ValidateRecordFields(Rec, CreateGLAccountFI.Changeindepreciationreserve4(), CreateGLAccountFI.Depreciationdifference3());
        end;
    end;

    local procedure ValidateRecordFields(var FAPostingGroup: Record "FA Posting Group"; DeprDifferenceAcc: Code[20]; DeprDifferenceBalAcc: Code[20])
    begin
        FAPostingGroup.Validate("Depr. Difference Acc.", DeprDifferenceAcc);
        FAPostingGroup.Validate("Depr. Difference Bal. Acc.", DeprDifferenceBalAcc);
    end;
}