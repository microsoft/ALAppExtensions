// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

pageextension 5314 "Audit Export Doc. Card SIE" extends "Audit File Export Doc. Card"
{
    layout
    {
        addafter(General)
        {
            group(SIE)
            {
                Enabled = SIEFormat;
                Visible = SIEFormat;

                field(FileType; Rec."File Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of SIE file to create.';
                }
                field(FiscalYear; Rec."Fiscal Year")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the tax year that the export process refers to.';
                }
                field(Dimensions; Rec.Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the dimensions covered by the export process.';

                    trigger OnAssistEdit()
                    var
                        DimensionSIE: Record "Dimension SIE";
                        TempDimensionSIE: Record "Dimension SIE" temporary;
                        SelectedDimensionsText: Text[2048];
                    begin
                        if DimensionSIE.IsEmpty() then
                            Error('No SIE dimensions are configured. Please configure dimensions in the "Dimensions SIE" page first.');

                        CreateTempDimensionsFromRecord(TempDimensionSIE, Rec.Dimensions);

                        if ShowDimensionSelectionDialog(TempDimensionSIE) then begin
                            SelectedDimensionsText := GetSelectedDimensionsFromTemp(TempDimensionSIE);
                            Rec.Dimensions := SelectedDimensionsText;
                            Rec.Modify();
                            CurrPage.Update();
                        end;
                    end;
                }
                field(GLAccountFilter; Rec."G/L Account Filter Expression")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the filter for G/L Account record.';
                }
            }
        }

        modify(SplitByMonth)
        {
            Enabled = not SIEFormat;
            Visible = not SIEFormat;
        }
        modify(SplitByDate)
        {
            Enabled = not SIEFormat;
            Visible = not SIEFormat;
        }
        modify(CreateMultipleZipFiles)
        {
            Enabled = not SIEFormat;
            Visible = not SIEFormat;
        }
        modify(LatestDataCheckDateTime)
        {
            Enabled = not SIEFormat;
            Visible = not SIEFormat;
        }
        modify(DataCheckStatus)
        {
            Enabled = not SIEFormat;
            Visible = not SIEFormat;
        }
    }
    actions
    {
        modify(DataCheck)
        {
            Enabled = not SIEFormat;
            Visible = not SIEFormat;
        }
    }

    var
        SIEFormat: Boolean;

    trigger OnOpenPage()
    begin
        SIEFormat := IsSIEFormat();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SIEFormat := IsSIEFormat();
    end;

    local procedure IsSIEFormat(): Boolean
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        AuditFileExportFormat: Enum "Audit File Export Format";
        IsSIEFormatSelected: Boolean;
    begin
        AuditFileExportFormat := Rec."Audit File Export Format";
        if AuditFileExportFormat = Enum::"Audit File Export Format"::None then begin
            AuditFileExportSetup.Get();
            AuditFileExportFormat := AuditFileExportSetup."Audit File Export Format";
        end;
        IsSIEFormatSelected := AuditFileExportFormat = AuditFileExportFormat::SIE;
        exit(IsSIEFormatSelected);
    end;

    local procedure CreateTempDimensionsFromRecord(var TempDimensionSIE: Record "Dimension SIE" temporary; DimensionsText: Text[2048])
    var
        DimensionSIE: Record "Dimension SIE";
        DimCodes: List of [Text];
        DimCode: Text;
        i: Integer;
    begin
        if DimensionSIE.FindSet() then
            repeat
                TempDimensionSIE.TransferFields(DimensionSIE);
                TempDimensionSIE.Selected := false;
                TempDimensionSIE.Insert();
            until DimensionSIE.Next() = 0;

        if DimensionsText <> '' then begin
            DimCodes := DimensionsText.Split(';');
            for i := 1 to DimCodes.Count do begin
                DimCode := DimCodes.Get(i).Trim();
                if (DimCode <> '') and (DimCode <> '...') then begin
                    TempDimensionSIE.Reset();
                    if TempDimensionSIE.Get(DimCode) then begin
                        TempDimensionSIE.Selected := true;
                        TempDimensionSIE.Modify();
                    end;
                end;
            end;
        end;
    end;

    local procedure ShowDimensionSelectionDialog(var TempDimensionSIE: Record "Dimension SIE" temporary): Boolean
    var
        TempDimensionSelectionPage: Page "Temp Dimension Selection SIE";
    begin
        TempDimensionSelectionPage.SetTempRecords(TempDimensionSIE);
        Commit();
        if TempDimensionSelectionPage.RunModal() = Action::OK then begin
            TempDimensionSelectionPage.GetTempRecords(TempDimensionSIE);
            exit(true);
        end;

        exit(false);
    end;

    local procedure GetSelectedDimensionsFromTemp(var TempDimensionSIE: Record "Dimension SIE" temporary): Text[2048]
    var
        SelectedDimText: Text[2048];
        DimCodesTxt: Label '%1; %2', Comment = '%1 - existing string with dimensions codes, %2 - dimension code to add';
        DimCodesThreeDotsTxt: Label '%1;...', Comment = '%1 - existing string with dimensions codes';
    begin
        TempDimensionSIE.Reset();
        TempDimensionSIE.SetRange(Selected, true);
        if TempDimensionSIE.FindSet() then
            repeat
                if SelectedDimText = '' then
                    SelectedDimText := TempDimensionSIE."Dimension Code"
                else
                    if (StrLen(SelectedDimText) + StrLen(TempDimensionSIE."Dimension Code")) <= (MaxStrLen(SelectedDimText) - 4) then
                        SelectedDimText := StrSubstNo(DimCodesTxt, SelectedDimText, TempDimensionSIE."Dimension Code")
                    else
                        SelectedDimText := StrSubstNo(DimCodesThreeDotsTxt, SelectedDimText);
            until TempDimensionSIE.Next() = 0;
        exit(SelectedDimText);
    end;
}
