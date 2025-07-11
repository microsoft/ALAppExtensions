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
                        DimensionSie: Record "Dimension SIE";
                        DimensionsSiePage: Page "Dimensions SIE";
                    begin
                        DimensionsSiePage.LookupMode(true);
                        if DimensionsSiePage.RunModal() = Action::LookupOK then
                            Rec.Dimensions := DimensionSie.GetDimSelectionText();
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
}
