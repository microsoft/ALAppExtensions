page 20040 "APIV1 - G/L Entry Attachments"
{
    APIVersion = 'v1.0';
    Caption = 'generalLedgerEntryAttachments', Locked = true;
    DelayedInsert = true;
    EntityName = 'generalLedgerEntryAttachments';
    EntitySetName = 'generalLedgerEntryAttachments';
    ODataKeyFields = "G/L Entry No.", Id;
    PageType = API;
    SourceTable = "Attachment Entity Buffer";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(generalLedgerEntryNumber; "G/L Entry No.")
                {
                    Caption = 'generalLedgerEntryNumber', Locked = true;
                    ShowMandatory = true;
                }
                field(id; Id)
                {
                    Caption = 'id', Locked = true;

                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(FIELDNO(Id), TempFieldBuffer);
                    end;
                }
                field(fileName; "File Name")
                {
                    Caption = 'fileName', Locked = true;

                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(FIELDNO("File Name"), TempFieldBuffer);
                    end;
                }
                field(byteSize; "Byte Size")
                {
                    Caption = 'byteSize', Locked = true;

                    trigger OnValidate()
                    begin
                        GraphMgtAttachmentBuffer.RegisterFieldSet(FIELDNO("Byte Size"), TempFieldBuffer);
                    end;
                }
                field(content; Content)
                {
                    Caption = 'content', Locked = true;

                    trigger OnValidate()
                    begin
                        IF AttachmentsLoaded THEN
                            MODIFY();
                        GraphMgtAttachmentBuffer.RegisterFieldSet(FIELDNO(Content), TempFieldBuffer);
                    end;
                }
                field(createdDateTime; "Created Date-Time")
                {
                    Caption = 'createdDateTime', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin
        GraphMgtAttachmentBuffer.PropagateDeleteAttachment(Rec);
        EXIT(FALSE);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        GLEntryNoFilter: Text;
        AttachmentIdFilter: Text;
        FilterView: Text;
    begin
        IF NOT AttachmentsLoaded THEN BEGIN
            FilterView := GETVIEW();
            GLEntryNoFilter := GETFILTER("G/L Entry No.");
            AttachmentIdFilter := GETFILTER(Id);
            IF GLEntryNoFilter = '' THEN
                ERROR(MissingGLEntryNoErr);

            GraphMgtAttachmentBuffer.LoadAttachments(Rec, GLEntryNoFilter, AttachmentIdFilter);
            SETVIEW(FilterView);
            AttachmentsFound := FINDFIRST();
            IF NOT AttachmentsFound THEN
                EXIT(FALSE);
            AttachmentsLoaded := TRUE;
        END;
        EXIT(AttachmentsFound);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        FileManagement: Codeunit "File Management";
        TypeHelper: Codeunit "Type Helper";
        Value: Variant;
        GLEntryNoFilter: Text;
        FilterView: Text;
    begin
        IF "G/L Entry No." = 0 THEN BEGIN
            FilterView := GETVIEW();
            GLEntryNoFilter := GETFILTER("G/L Entry No.");
            IF GLEntryNoFilter <> '' THEN BEGIN
                Value := "G/L Entry No.";
                TypeHelper.Evaluate(Value, GLEntryNoFilter, '', 'en-US');
                "G/L Entry No." := Value;
            END;
            SETVIEW(FilterView);
        END;
        IF "G/L Entry No." = 0 THEN
            ERROR(MissingGLEntryNoErr);

        IF NOT FileManagement.IsValidFileName("File Name") THEN
            VALIDATE("File Name", 'filename.txt');

        VALIDATE("Created Date-Time", ROUNDDATETIME(CURRENTDATETIME(), 1000));
        GraphMgtAttachmentBuffer.RegisterFieldSet(FIELDNO("Created Date-Time"), TempFieldBuffer);

        ByteSizeFromContent();

        GraphMgtAttachmentBuffer.PropagateInsertAttachment(Rec, TempFieldBuffer);

        EXIT(FALSE);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IF xRec.Id <> Id THEN
            ERROR(CannotModifyKeyFieldErr, 'id');
        IF xRec."G/L Entry No." <> "G/L Entry No." THEN
            ERROR(CannotModifyKeyFieldErr, 'generalLedgerEntryNumber');

        GraphMgtAttachmentBuffer.PropagateModifyAttachment(Rec, TempFieldBuffer);
        ByteSizeFromContent();
        EXIT(FALSE);
    end;

    var
        TempFieldBuffer: Record "Field Buffer" temporary;
        GraphMgtAttachmentBuffer: Codeunit "Graph Mgt - Attachment Buffer";
        AttachmentsLoaded: Boolean;
        AttachmentsFound: Boolean;
        MissingGLEntryNoErr: Label 'You must specify a generalLedgerEntryNumber in the request body.', Locked = true;
        CannotModifyKeyFieldErr: Label 'You cannot change the value of the key field %1.', Locked = true;

    local procedure ByteSizeFromContent()
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        TempBlob.FromRecord(Rec, FieldNo(Content));
        "Byte Size" := GraphMgtAttachmentBuffer.GetContentLength(TempBlob);
    end;
}







