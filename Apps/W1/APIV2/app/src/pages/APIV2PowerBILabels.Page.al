namespace Microsoft.API.V2;

using Microsoft.Integration.PowerBI;

page 30078 "APIV2 - Power BI Labels"
{

    APIVersion = 'v2.0';
    APIPublisher = 'microsoft';
    APIGroup = 'powerbi';
    EntityCaption = 'Report Label';
    EntitySetCaption = 'Report Labels';
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'reportLabel';
    EntitySetName = 'reportLabels';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "Power BI Report Labels";
    SourceTableTemporary = true;
    Extensible = false;
    ODataKeyFields = "Label ID";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(labelId; Rec."Label ID")
                {
                    Caption = 'Label Id';
                }
                field(displayName; Rec."Text Value")
                {
                    Caption = 'Text Value';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        PowerBILabelMgt: Codeunit "Power BI Label Mgt.";
    begin
        PowerBILabelMgt.GetReportLabelsForUserLanguage(Rec, UserSecurityId());
    end;
}
