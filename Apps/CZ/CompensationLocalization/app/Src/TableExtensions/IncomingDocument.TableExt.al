tableextension 31275 "Incoming Document CZC" extends "Incoming Document"
{
    procedure SetCompensationCZC(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        if CompensationHeaderCZC."Incoming Document Entry No." = 0 then
            exit;
        Get(CompensationHeaderCZC."Incoming Document Entry No.");
        TestReadyForProcessing();
        TestIfAlreadyExistsCZC();
        "Document Type" := "Document Type"::"Compensation CZC";
        Modify();
        if not DocLinkExistsCZC(CompensationHeaderCZC) then
            CompensationHeaderCZC.AddLink(GetURL(), Description);
    end;

    local procedure TestIfAlreadyExistsCZC()
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        AlreadyUsedInDocHdrErr: Label 'The incoming document has already been assigned to %1 %2 (%3).', Comment = '%1 = Document Type, %2 = Document No., %3 = Table Name.';
    begin
        case "Document Type" of
            "Document Type"::"Compensation CZC":
                begin
                    CompensationHeaderCZC.SetRange("Incoming Document Entry No.", "Entry No.");
                    if CompensationHeaderCZC.FindFirst() then
                        Error(AlreadyUsedInDocHdrErr, '', CompensationHeaderCZC."No.", CompensationHeaderCZC.TableCaption);
                end;
        end;
    end;

    local procedure DocLinkExistsCZC(RecVariant: Variant): Boolean
    var
        RecordLink: Record "Record Link";
        RecordRef: RecordRef;
    begin
        if GetURL() = '' then
            exit(true);
        RecordRef.GetTable(RecVariant);
        RecordLink.SetRange("Record ID", RecordRef.RecordId);
        RecordLink.SetRange(URL1, URL);
        RecordLink.SetRange(Description, Description);
        exit(not RecordLink.IsEmpty());
    end;
}
