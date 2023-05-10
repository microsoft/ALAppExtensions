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
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; "No.")
                {
                    Caption = 'No.';
                }
                field(displayName; Description)
                {
                    Caption = 'Display Name';
                }
            }
            part(documentAttachments; "APIV2 - Document Attachments")
            {
                Caption = 'Document Attachments';
                EntityName = 'documentAttachment';
                EntitySetName = 'documentAttachments';
                SubPageLink = "Document Id" = Field(SystemId), "Document Type" = const(Job);
            }
        }
    }
}