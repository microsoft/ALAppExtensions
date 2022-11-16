page 20006 "APIV1 - Aut. Extension Upload"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    Caption = 'extensionUpload', Locked = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityName = 'extensionUpload';
    EntitySetName = 'extensionUpload';
    ODataKeyFields = ID;
    PageType = API;
    SourceTable = "API Extension Upload";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Id)
                {
                    Caption = 'id', Locked = true;
                }
#pragma warning disable AL0273
                field(content; Content)
#pragma warning restore
                {
                    Caption = 'content', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        IF NOT loaded THEN BEGIN
            INSERT(true);
            loaded := TRUE;
        END;
        EXIT(TRUE);
    end;

    trigger OnOpenPage()
    begin
        BINDSUBSCRIPTION(AutomationAPIManagement);
    end;

    trigger OnModifyRecord(): Boolean
    var
        ExtensionManagement: Codeunit "Extension Management";
        FileInStream: InStream;
    begin
        IF Content.HasValue() THEN begin
            Content.CreateInStream(FileInStream);
            ExtensionManagement.UploadExtension(FileInStream, GLOBALLANGUAGE());
        end;
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
        loaded: Boolean;
}


