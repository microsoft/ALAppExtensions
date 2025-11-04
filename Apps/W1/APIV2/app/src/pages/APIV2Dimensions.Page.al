namespace Microsoft.API.V2;

using Microsoft.Finance.Dimension;

page 30021 "APIV2 - Dimensions"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Dimension';
    EntitySetCaption = 'Dimensions';
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'dimension';
    EntitySetName = 'dimensions';
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Dimension;
    Extensible = false;
    AboutText = 'Exposes dimension master data including codes, names, consolidation codes, status, and last modified timestamps for categorizing and analyzing financial transactions in Business Central. Supports read-only (GET) operations, enabling external systems and business intelligence platforms to retrieve and synchronize dimension definitions for advanced financial reporting, analytics, and segment-based analysis. Ideal for integrations requiring up-to-date dimension structures without direct modification from external sources.';

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
                part(dimensionValues; "APIV2 Dimension Values Entity")
                {
                    Caption = 'Dimension Values';
                    EntityName = 'dimensionValue';
                    EntitySetName = 'dimensionValues';
                    SubPageLink = "Dimension Id" = field(SystemId);
                }
            }
        }
    }

    actions
    {
    }
}

