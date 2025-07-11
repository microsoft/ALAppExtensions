namespace Microsoft.API.V2;
using Microsoft.Sales.Customer;


page 30088 "APIV2 - Dispute Status"
{
    DelayedInsert = true;
    APIVersion = 'v2.0';
    EntityCaption = 'Dispute Status';
    EntitySetCaption = 'Dispute Status';
    PageType = API;
    ODataKeyFields = SystemId;
    EntityName = 'disputeStatus';
    EntitySetName = 'disputeStatus';
    SourceTable = "Dispute Status";
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
                field(displayName; Rec.Description)
                {
                    Caption = 'Description';
                }
            }
        }
    }
}