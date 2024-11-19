codeunit 11506 "Create GB FA Posting Group"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"FA Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "FA Posting Group"; RunTrigger: Boolean)
    var
        CreateFAPostingGroup: Codeunit "Create FA Posting Group";
        CreateGBGLAccounts: Codeunit "Create GB GL Accounts";
    begin
        case Rec.Code of
            CreateFAPostingGroup.Equipment(),
            CreateFAPostingGroup.Goodwill(),
            CreateFAPostingGroup.Plant(),
            CreateFAPostingGroup.Property(),
            CreateFAPostingGroup.Vehicles():
                ValidateRecordFields(Rec, CreateGBGLAccounts.EquipmentsAndTools());
        end;
    end;

    local procedure ValidateRecordFields(var FAPostingGroup: Record "FA Posting Group"; GLAccountNo: Code[20])
    begin
        FAPostingGroup.Validate("Acquisition Cost Account", GLAccountNo);
        FAPostingGroup.Validate("Accum. Depreciation Account", GLAccountNo);
        FAPostingGroup.Validate("Acq. Cost Acc. on Disposal", GLAccountNo);
        FAPostingGroup.Validate("Accum. Depr. Acc. on Disposal", GLAccountNo);
        FAPostingGroup.Validate("Gains Acc. on Disposal", GLAccountNo);
        FAPostingGroup.Validate("Losses Acc. on Disposal", GLAccountNo);
        FAPostingGroup.Validate("Maintenance Expense Account", GLAccountNo);
        FAPostingGroup.Validate("Acquisition Cost Bal. Acc.", GLAccountNo);
        FAPostingGroup.Validate("Depreciation Expense Acc.", GLAccountNo);
    end;
}