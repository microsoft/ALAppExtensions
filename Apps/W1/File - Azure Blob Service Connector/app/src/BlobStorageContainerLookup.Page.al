// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

using System.Azure.Storage;

page 80102 "Blob Storage Container Lookup"
{
    Caption = 'Container Lookup';
    PageType = List;
    SourceTable = "ABS Container";
    Editable = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Name of the container.';
                }
            }
        }
    }
}
