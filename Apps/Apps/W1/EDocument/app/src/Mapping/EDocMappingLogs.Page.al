// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

page 6126 "E-Doc. Mapping Logs"
{
    ApplicationArea = Basic, Suite;
    SourceTable = "E-Doc. Mapping Log";
    PageType = ListPart;
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(Content)
        {
            group("E-Doc Mapping Log")
            {
                ShowCaption = false;
                repeater("E-Doc Mapping Line")
                {
                    ShowCaption = false;
                    field("Table ID Caption"; Rec."Table ID Caption")
                    {
                        Caption = 'Table';
                        ToolTip = 'Specifies the caption of the table of the mapping value.';
                    }
                    field("Field ID Caption"; Rec."Field ID Caption")
                    {
                        Caption = 'Field';
                        ToolTip = 'Specifies the caption of the field of the mapping value.';
                    }
                    field("Find Value"; Rec."Find Value")
                    {
                        Caption = 'Original Value';
                        ToolTip = 'Specifies the original field value of the mapping.';
                    }
                    field("Replace Value"; Rec."Replace Value")
                    {
                        Caption = 'New Value';
                        ToolTip = 'Specifies the replaced field value of the mapping.';
                    }
                }
            }
        }
    }
}
