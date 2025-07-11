namespace Microsoft.API.V2;

using System.Environment;
using System.Apps;
using Microsoft.API;

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
                field(systemId; Rec.SystemId)
                {
                    Caption = 'System Id';
                    Editable = false;
                }
                field(schedule; Rec.Schedule)
                {
                    Caption = 'Schedule';
                }
                field(schemaSyncMode; Rec."Schema Sync Mode")
                {
                    Caption = 'Schema Sync Mode';
                }
                field(extensionContent; Rec.Content)
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
        Rec.Insert();
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
        if Rec.Content.HasValue() then begin
            Rec.Content.CreateInStream(FileInStream);
            ExtensionManagement.UploadExtensionToVersion(FileInStream, GlobalLanguage(), Rec.Schedule, Rec."Schema Sync Mode");
            Rec.Delete();
        end else
            Error(ExtensionContentEmptyErr);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Aut. Extension Upload");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
        ExtensionContentEmptyErr: Label 'Extension content is empty';
}