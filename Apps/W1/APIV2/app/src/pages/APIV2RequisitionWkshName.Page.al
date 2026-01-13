// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.API.V2;

using Microsoft.Inventory.Requisition;

page 30099 "APIV2 - Requisition Wksh. Name"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Requisition Worksheet Name';
    EntitySetCaption = 'Requisition Worksheet Names';
    DelayedInsert = true;
    EntityName = 'requisitionWorksheetName';
    EntitySetName = 'requisitionWorksheetNames';
    SourceTable = "Requisition Wksh. Name";
    PageType = API;
    Extensible = false;
    APIGroup = 'automate';
    APIPublisher = 'microsoft';
    ODataKeyFields = SystemId;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Id';
                }
                field(worksheetTemplateName; Rec."Worksheet Template Name")
                {
                    ApplicationArea = All;
                    Caption = 'Worksheet Template Name';
                }
                field(name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                }
                field(description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                }
                field(templateType; Rec."Template Type")
                {
                    ApplicationArea = All;
                    Caption = 'Template Type';
                }
                field(recurring; Rec.Recurring)
                {
                    ApplicationArea = All;
                    Caption = 'Recurring';
                }
            }
        }
    }
}