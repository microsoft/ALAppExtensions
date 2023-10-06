namespace Microsoft.API.V2;

using Microsoft.Projects.Project.Job;

page 30050 "APIV2 - Jobs"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Project';
    EntitySetCaption = 'Projects';
    DelayedInsert = true;
    EntityName = 'project';
    EntitySetName = 'projects';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Job;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'Display Name';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                part(documentAttachments; "APIV2 - Document Attachments")
                {
                    Caption = 'Document Attachments';
                    EntityName = 'documentAttachment';
                    EntitySetName = 'documentAttachments';
                    SubPageLink = "Document Id" = field(SystemId), "Document Type" = const(Job);
                }
            }
        }
    }
}