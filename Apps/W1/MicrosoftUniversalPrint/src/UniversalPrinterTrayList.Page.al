// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to lookup paper trays of universal Printers.
/// </summary>
page 2754 "Universal Printer Tray List"
{
    Caption = 'Universal Printer Trays';
    Editable = false;
    PageType = List;
    SourceTable = "Name/Value Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(PaperTray; Rec."Value Long")
                {
                    ApplicationArea = All;
                    Caption = 'Paper Tray';
                    ToolTip = 'Specifies the paper tray.';
                }
            }
        }
    }

    procedure SetPaperTrayBuffer(var TempStarRowCellNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        Rec.Reset();
        Rec.DeleteAll();
        Rec.Copy(TempStarRowCellNameValueBuffer, true);
        If Rec.FindFirst() then;
    end;

}