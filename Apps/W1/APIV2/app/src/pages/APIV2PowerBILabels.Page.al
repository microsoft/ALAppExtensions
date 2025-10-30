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
    AboutText = 'Exposes read-only access to report label definitions, including label IDs and text values, from the Power BI Report Labels table. Enables external analytics platforms and reporting tools to retrieve and synchronize standardized or multilingual label terminology used in Business Central reports. Supports GET operations only, making it suitable for scenarios requiring consistent labeling and localization across integrated reporting environments without permitting direct modification of label data.';

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
