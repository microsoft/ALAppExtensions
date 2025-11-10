namespace Microsoft.API.V2;

using Microsoft.Finance.Dimension;

page 30040 "APIV2 Dimension Values Entity"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Dimension Value';
    EntitySetCaption = 'Dimension Values';
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Dimension Value";
    ODataKeyFields = SystemId;
    PageType = API;
    EntityName = 'dimensionValue';
    EntitySetName = 'dimensionValues';
    AboutText = 'Exposes read-only access to dimension value records, including codes, names, types, consolidation mappings, and status indicators for analytical structures such as departments, cost centers, and projects. Enables external systems and reporting tools to retrieve and synchronize dimension values for financial analysis, transaction categorization, and business intelligence integration. Supports GET operations only, ensuring secure and consistent access to the latest dimension configurations in Business Central.';

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
                field("code"; Rec.Code)
                {
                    Caption = 'Code';
                }
                field("dimensionId"; Rec."Dimension Id")
                {
                    Caption = 'Dimension Id';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name';
                }
                field(consolidationCode; Rec."Consolidation Code")
                {
                    Caption = 'Consolidation Code';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
            }
        }
    }

    actions
    {
    }
}