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
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(code; Code)
                {
                    Caption = 'Code';
                }
                field(description; Description)
                {
                    Caption = 'Description';
                }
            }
        }
    }
}