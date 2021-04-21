// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
                field(TableNo; TableNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the table number.';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID number of the field in the table.';
                }
                field(TableName; TableName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the table.';
                }
                field(FieldName; FieldName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the field in the table.';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the field in the table, which indicates the type of data it contains.';
                }
                field(Class; Class)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of class. Normal is data entry, FlowFields calculate and display results immediately, and FlowFilters display results based on user-defined filter values that affect the calculation of a FlowField.';
                }
                field("Type Name"; "Type Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of data.';
                }
                field(RelationTableNo; RelationTableNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID number of a table from which the field on the current table gets data. For example, the field can provide a lookup into another table.';
                }
                field(OptionString; OptionString)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the option string.';
                }
                field(DataClassification; DataClassification)
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

