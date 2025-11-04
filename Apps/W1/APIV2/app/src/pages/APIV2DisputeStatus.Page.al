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
    AboutText = 'Manages dispute status definitions including code, description, and on-hold update settings, supporting full CRUD operations for tracking and resolving payment or delivery disputes. Enables integration with external CRM, case management, and support systems to standardize dispute workflows and ensure transparent resolution processes.';

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