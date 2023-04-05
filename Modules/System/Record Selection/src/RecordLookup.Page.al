// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Look up page for records.
/// </summary>
page 9555 "Record Lookup"
{
    Extensible = false;
    Editable = false;
    PageType = List;
    SourceTable = "Record Selection Buffer";
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;

                field(Field1; Rec."Field 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'The 1st value in the key of the record.';
                    Visible = FieldsVisible > 0;
                    CaptionClass = FieldCaptions[1];
                }

                field(Field2; Rec."Field 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'The 2nd value in the key of the record.';
                    Visible = FieldsVisible > 1;
                    CaptionClass = FieldCaptions[2];
                }

                field(Field3; Rec."Field 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'The 3rd value in the key of the record.';
                    Visible = FieldsVisible > 2;
                    CaptionClass = FieldCaptions[3];
                }

                field(Field4; Rec."Field 4")
                {
                    ApplicationArea = All;
                    ToolTip = 'The 4th value in the key of the record.';
                    Visible = FieldsVisible > 3;
                    CaptionClass = FieldCaptions[4];
                }

                field(Field5; Rec."Field 5")
                {
                    ApplicationArea = All;
                    ToolTip = 'The 5th value in the key of the record.';
                    Visible = FieldsVisible > 4;
                    CaptionClass = FieldCaptions[5];
                }

                field(Field6; Rec."Field 6")
                {
                    ApplicationArea = All;
                    ToolTip = 'The 6th value in the key of the record.';
                    Visible = FieldsVisible > 5;
                    CaptionClass = FieldCaptions[6];
                }

                field(Field7; Rec."Field 7")
                {
                    ApplicationArea = All;
                    ToolTip = 'The 7th value in the key of the record.';
                    Visible = FieldsVisible > 6;
                    CaptionClass = FieldCaptions[7];
                }

                field(Field8; Rec."Field 8")
                {
                    ApplicationArea = All;
                    ToolTip = 'The 8th value in the key of the record.';
                    Visible = FieldsVisible > 7;
                    CaptionClass = FieldCaptions[8];
                }

                field(Field9; Rec."Field 9")
                {
                    ApplicationArea = All;
                    ToolTip = 'The 9th value in the key of the record.';
                    Visible = FieldsVisible > 8;
                    CaptionClass = FieldCaptions[9];
                }

                field(Field10; Rec."Field 10")
                {
                    ApplicationArea = All;
                    ToolTip = 'The 10th value in the key of the record.';
                    Visible = FieldsVisible > 9;
                    CaptionClass = FieldCaptions[10];
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey("Field 1", "Field 2", "Field 3", "Field 4", "Field 5", "Field 6", "Field 7", "Field 8", "Field 9", "Field 10");
    end;

    var
        [InDataSet]
        FieldsVisible: Integer;
        FieldCaptions: Array[10] of Text;

    internal procedure SetTableId(TableId: Integer)
    var
        RecordSelectionImpl: Codeunit "Record Selection Impl.";
    begin
        FieldsVisible := RecordSelectionImpl.GetRecordsFromTableId(TableId, FieldCaptions, Rec);
    end;

    internal procedure GetSelectedRecords(var SelectedRecords: Record "Record Selection Buffer")
    begin
        CurrPage.SetSelectionFilter(Rec);
        SelectedRecords.Copy(Rec, true);
    end;
}

