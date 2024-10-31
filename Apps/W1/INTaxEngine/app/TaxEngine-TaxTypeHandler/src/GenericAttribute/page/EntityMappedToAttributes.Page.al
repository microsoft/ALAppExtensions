// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.TaxTypeHandler;

page 20232 "Entity Mapped To Attributes"
{
    PageType = ListPart;
    SourceTable = "Entity Attribute Mapping";
    RefreshOnActivate = true;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entity Name"; "Entity Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the table which will be mapped with the attribute.';
                }
                field("Mapping Field Name"; "Mapping Field Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the field which will be mapped with the attribute.';
                }
            }
        }
    }
}
