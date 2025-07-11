namespace Microsoft.API.V2;

using Microsoft.Foundation.AuditCodes;

page 30077 "APIV2 - Cust. Return Reasons"
{
    DelayedInsert = true;
    APIVersion = 'v2.0';
    EntityCaption = 'Customer Return Reason';
    EntitySetCaption = 'Customer Return Reasons';
    PageType = API;
    ODataKeyFields = SystemId;
    EntityName = 'customerReturnReason';
    EntitySetName = 'customerReturnReasons';
    SourceTable = "Reason Code";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(code; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
            }
        }
    }
}