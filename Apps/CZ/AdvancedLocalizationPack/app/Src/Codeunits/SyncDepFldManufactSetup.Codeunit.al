#if not CLEAN18
#pragma warning disable AL0432, AA0072
codeunit 31281 "Sync.Dep.Fld-ManufactSetup CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Manufacturing Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertManufacturingSetup(var Rec: Record "Manufacturing Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Manufacturing Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyManufacturingSetup(var Rec: Record "Manufacturing Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Manufacturing Setup")
    var
        PreviousRecord: Record "Manufacturing Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);

        DepFieldTxt := Rec."Default Gen.Bus. Posting Group";
        NewFieldTxt := Rec."Default Gen.Bus.Post. Grp. CZA";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Default Gen.Bus. Posting Group", PreviousRecord."Default Gen.Bus.Post. Grp. CZA");
        Rec."Default Gen.Bus. Posting Group" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Default Gen.Bus. Posting Group"));
        Rec."Default Gen.Bus.Post. Grp. CZA" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Default Gen.Bus.Post. Grp. CZA"));

        SyncDepFldUtilities.SyncFields(Rec."Exact Cost Rev.Manda. (Cons.)", Rec."Exact Cost Rev.Mand. Cons. CZA", PreviousRecord."Exact Cost Rev.Manda. (Cons.)", PreviousRecord."Exact Cost Rev.Mand. Cons. CZA");
    end;
}
#endif