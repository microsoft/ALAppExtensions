codeunit 31262 "Posting Group Mgt. Handler CZC"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Group Management CZL", 'OnCheckPostingGroupChange', '', false, false)]
    local procedure CheckCompensationLineCZCOnCheckPostingGroupChange(NewPostingGroup: Code[20]; OldPostingGroup: Code[20]; SourceRecordRef: RecordRef)
    var
        CompensationLineCZC: Record "Compensation Line CZC";
    begin
        if SourceRecordRef.Number <> Database::"Compensation Line CZC" then
            exit;

        SourceRecordRef.SetTable(CompensationLineCZC);
        CheckPostingGroupChangeInCompensationLineCZC(NewPostingGroup, OldPostingGroup, CompensationLineCZC);
    end;

    local procedure CheckPostingGroupChangeInCompensationLineCZC(NewPostingGroup: Code[20]; OldPostingGroup: Code[20]; CompensationLineCZC: Record "Compensation Line CZC")
    var
        PostingGroupManagementCZL: Codeunit "Posting Group Management CZL";
    begin
        case CompensationLineCZC."Source Type" of
            CompensationLineCZC."Source Type"::Customer:
                PostingGroupManagementCZL.CheckCustomerPostingGroupChange(NewPostingGroup, OldPostingGroup);
            CompensationLineCZC."Source Type"::Vendor:
                PostingGroupManagementCZL.CheckVendorPostingGroupChange(NewPostingGroup, OldPostingGroup);
            else
                CompensationLineCZC.FieldError(CompensationLineCZC."Source Type");
        end;
    end;
}
