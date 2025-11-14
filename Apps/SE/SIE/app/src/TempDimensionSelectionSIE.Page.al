// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

page 5316 "Temp Dimension Selection SIE"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Select Dimensions for SIE Export';
    PageType = StandardDialog;
    SourceTable = "Dimension SIE";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                ShowCaption = false;
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies a dimension code.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies a descriptive name for the dimension.';
                }
                field(Selected; Rec.Selected)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if this dimension should be used when importing or exporting G/L data.';
                }
                field("SIE Dimension"; Rec."SIE Dimension")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number you want to assign to the dimension.';
                }
            }
        }
    }

    actions
    {
    }

    procedure SetTempRecords(var TempDimensionSIE: Record "Dimension SIE" temporary)
    begin
        if TempDimensionSIE.FindSet() then
            repeat
                Rec.TransferFields(TempDimensionSIE);
                Rec.Insert();
            until TempDimensionSIE.Next() = 0;
    end;

    procedure GetTempRecords(var TempDimensionSIE: Record "Dimension SIE" temporary)
    begin
        TempDimensionSIE.Reset();
        TempDimensionSIE.DeleteAll();

        if Rec.FindSet() then
            repeat
                TempDimensionSIE.TransferFields(Rec);
                TempDimensionSIE.Insert();
            until Rec.Next() = 0;
    end;
}