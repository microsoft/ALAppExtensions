// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Privacy;

using System.Reflection;

/// <summary>
/// Displays a list of fields and their corresponding data classifications.
/// </summary>
page 1750 "Field Data Classification"
{
    Extensible = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Field";
    ContextSensitiveHelpPage = 'admin-classifying-data-sensitivity';
    Permissions = tabledata Field = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(TableNo; Rec.TableNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the table number.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID number of the field in the table.';
                }
                field(TableName; Rec.TableName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the table.';
                }
                field(FieldName; Rec.FieldName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the field in the table.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the field in the table, which indicates the type of data it contains.';
                }
                field(Class; Rec.Class)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of class. Normal is data entry, FlowFields calculate and display results immediately, and FlowFilters display results based on user-defined filter values that affect the calculation of a FlowField.';
                }
                field("Type Name"; Rec."Type Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of data.';
                }
                field(RelationTableNo; Rec.RelationTableNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID number of a table from which the field on the current table gets data. For example, the field can provide a lookup into another table.';
                }
                field(OptionString; Rec.OptionString)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the option string.';
                }
                field(DataClassification; Rec.DataClassification)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the data classification.';
                }
            }
        }
    }

    actions
    {
    }
}


