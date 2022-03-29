page 30006 "APIV2 - Aut. Extension Upload"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Extension Upload';
    EntitySetCaption = 'Extension Upload';
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityName = 'extensionUpload';
    EntitySetName = 'extensionUpload';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "API Extension Upload";
    Extensible = false;
    Permissions = TableData "API Extension Upload" = rimd;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(systemId; SystemId)
                {
                    Caption = 'System Id';
                    Editable = false;
                }
                field(schedule; Schedule)
                {
                    Caption = 'Schedule';
                }
                field(extensionContent; Content)
                {
                    Caption = 'Content';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Insert();
    end;

    trigger OnOpenPage()
    begin
        BindSubscription(AutomationAPIManagement);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Upload(var ActionContext: WebServiceActionContext)
    var
        ExtensionManagement: Codeunit "Extension Management";
        FileInStream: InStream;
    begin
        if Content.HasValue() then begin
            Content.CreateInStream(FileInStream);
            ExtensionManagement.UploadExtensionToVersion(FileInStream, GlobalLanguage(), Rec.Schedule);
            Delete();
        end else
            Error(ExtensionContentEmptyErr);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Aut. Extension Upload");
        ActionContext.AddEntityKey(FieldNo(SystemId), SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
        ExtensionContentEmptyErr: Label 'Extension content is empty';
}