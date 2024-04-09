// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

report 31103 "VAT Ctrl. Report - Test CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/VATCtrlReportTest.rdl';
    Caption = 'VAT Control Report - Test';

    dataset
    {
        dataitem(VATControlReportHeader; "VAT Ctrl. Report Header CZL")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Closed by Document No. Filter";
            column(COMPANYNAME; CompanyProperty.DisplayName())
            {
            }
            column(VATControlReportHeader_No; "No.")
            {
            }
            column(VATControlReportHeader_PeriodNo; "Period No.")
            {
            }
            column(VATControlReportHeader_Year; Year)
            {
            }
            column(VATControlReportHeader_StartDate; Format("Start Date", 0, '<Day,2>.<Month,2>.<Year>'))
            {
            }
            column(VATControlReportHeader_EndDate; Format("End Date", 0, '<Day,2>.<Month,2>.<Year>'))
            {
            }
            column(VATControlReportHeader_VATStatementTemplateName; "VAT Statement Template Name")
            {
            }
            column(VATControlReportHeader_VATStatementName; "VAT Statement Name")
            {
            }
            column(VATControlReportHeader_ClosedbyDocumentNoFilter; GetFilter("Closed by Document No. Filter"))
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(ReportCaption; ReportCaptionLbl)
            {
            }
            column(VATControlReportHeader_No_Caption; FieldCaption("No."))
            {
            }
            column(VATControlReportHeader_PeriodNo_Caption; FieldCaption("Period No."))
            {
            }
            column(VATControlReportHeader_Year_Caption; FieldCaption(Year))
            {
            }
            column(VATControlReportHeader_StartDate_Caption; FieldCaption("Start Date"))
            {
            }
            column(VATControlReportHeader_EndDate_Caption; FieldCaption("End Date"))
            {
            }
            column(VATControlReportHeader_VATStatementTemplateName_Caption; FieldCaption("VAT Statement Template Name"))
            {
            }
            column(VATControlReportHeader_VATStatementName_Caption; FieldCaption("VAT Statement Name"))
            {
            }
            column(VATControlReportHeader_ClosedbyDocumentNoFilter_Caption; FieldCaption("Closed by Document No. Filter"))
            {
            }
            column(VATControlReportBuffer_PostingDate_Caption; VATControlReportBuffer.FieldCaption("Original Document VAT Date"))
            {
            }
            column(VATControlReportBuffer_BirthDate_Caption; VATControlReportBuffer.FieldCaption("Birth Date"))
            {
            }
            column(VATControlReportBuffer_RatioUse_Caption; VATControlReportBuffer.FieldCaption("Ratio Use"))
            {
            }
            column(VATControlReportBuffer_CorrectionsForBadReceivable_Caption; VATControlReportBuffer.FieldCaption("Corrections for Bad Receivable"))
            {
            }
            dataitem(HeaderErrorCounter; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(ErrorText_Number_Header; ErrorText[Number])
                {
                }
                column(ErrorText_Number_HeaderCaption; ErrorTextLbl)
                {
                }
                column(HeaderErrorCounter_Number; Number)
                {
                }
                trigger OnPostDataItem()
                begin
                    ErrorCounter := 0;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, ErrorCounter);
                end;
            }
            dataitem(VATControlReportBuffer; "VAT Ctrl. Report Buffer CZL")
            {
                DataItemTableView = sorting("VAT Ctrl. Report Section Code", "Line No.");
                UseTemporary = true;
                column(VATControlReportBuffer_VATControlRepSectionCode; "VAT Ctrl. Report Section Code")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_PostingDate; Format("Original Document VAT Date", 0, '<Day,2>.<Month,2>.<Year>'))
                {
                }
                column(VATControlReportBuffer_BilltoPaytoNo; "Bill-to/Pay-to No.")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_VATRegistrationNo; "VAT Registration No.")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_RegistrationNo; "Registration No.")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_TaxRegistrationNo; "Tax Registration No.")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_DocumentNo; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_Type; Type)
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_VATBusPostingGroup; "VAT Bus. Posting Group")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_VATProdPostingGroup; "VAT Prod. Posting Group")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_VATRate; "VAT Rate")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_CommodityCode; "Commodity Code")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_SuppliesModeCode; "Supplies Mode Code")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_CorrectionsForBadReceivable; Format("Corrections for Bad Receivable"))
                {
                }
                column(VATControlReportBuffer_RatioUse; Format("Ratio Use"))
                {
                }
                column(VATControlReportBuffer_Name; Name)
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_BirthDate; Format("Birth Date", 0, '<Day,2>.<Month,2>.<Year>'))
                {
                }
                column(VATControlReportBuffer_Placeofstay; "Place of Stay")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_Base1; "Base 1")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_Amount1; "Amount 1")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_Base2; "Base 2")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_Amount2; "Amount 2")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_Base3; "Base 3")
                {
                    IncludeCaption = true;
                }
                column(VATControlReportBuffer_Amount3; "Amount 3")
                {
                    IncludeCaption = true;
                }
                dataitem(LineErrorCounter; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(ErrorText_Number__Line; ErrorText[Number])
                    {
                    }
                    column(ErrorText_Number__LineCaption; ErrorTextLbl)
                    {
                    }
                    column(LineErrorCounter_Number; Number)
                    {
                    }
                    trigger OnAfterGetRecord()
                    var
                        TempVATCtrlReportBufferCZL3: Record "VAT Ctrl. Report Buffer CZL" temporary;
                    begin
                        if Number = 2 then begin
                            TempVATCtrlReportBufferCZL3 := VATControlReportBuffer;
                            Clear(VATControlReportBuffer);
                            VATControlReportBuffer."VAT Ctrl. Report Section Code" := TempVATCtrlReportBufferCZL3."VAT Ctrl. Report Section Code";
                            VATControlReportBuffer."Line No." := TempVATCtrlReportBufferCZL3."Line No.";
                        end;
                    end;

                    trigger OnPostDataItem()
                    begin
                        ErrorCounter := 0;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, ErrorCounter);
                    end;
                }
                trigger OnAfterGetRecord()
                begin
                    if ReportPrintType = ReportPrintType::Detail then begin
                        if "VAT Ctrl. Report Section Code" = '' then
                            AddError(StrSubstNo(MustBeSpecifiedErr, FieldCaption("VAT Ctrl. Report Section Code")));

                        CopyBufferToLine(VATControlReportBuffer, VATCtrlReportLineCZL);
                        CheckMandatoryFields();

                        if OnlyErrorLines and (ErrorCounter = 0) then
                            CurrReport.Skip();
                    end;

                    if (("Base 1" + "Amount 1") = 0) and
                       (("Base 2" + "Amount 2") = 0) and
                       (("Base 3" + "Amount 3") = 0)
                    then
                        CurrReport.Skip();
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if "Period No." = 0 then
                    AddError(StrSubstNo(MustBeSpecifiedErr, FieldCaption("Period No.")));
                if Year = 0 then
                    AddError(StrSubstNo(MustBeSpecifiedErr, FieldCaption(Year)));
                if "Start Date" = 0D then
                    AddError(StrSubstNo(MustBeSpecifiedErr, FieldCaption("Start Date")));
                if "End Date" = 0D then
                    AddError(StrSubstNo(MustBeSpecifiedErr, FieldCaption("End Date")));

                case ReportPrintType of
                    ReportPrintType::Detail:
                        begin
                            VATCtrlReportLineCZL.Reset();
                            VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", "No.");
                            // All, Export, Not Export
                            case ReportPrintEntries of
                                ReportPrintEntries::Export:
                                    VATCtrlReportLineCZL.SetRange("Exclude from Export", false);
                                ReportPrintEntries::"Not Export":
                                    VATCtrlReportLineCZL.SetRange("Exclude from Export", true);
                            end;
                            // Open, Close, Open and Close
                            case VATStatementReportSelection of
                                VATStatementReportSelection::Open:
                                    VATCtrlReportLineCZL.SetFilter("Closed by Document No.", '%1', '');
                                VATStatementReportSelection::Closed:
                                    if GetFilter("Closed by Document No. Filter") <> '' then
                                        VATCtrlReportLineCZL.SetFilter("Closed by Document No.", GetFilter("Closed by Document No. Filter"))
                                    else
                                        VATCtrlReportLineCZL.SetFilter("Closed by Document No.", '<>%1', '');
                                VATStatementReportSelection::"Open and Closed":
                                    if GetFilter("Closed by Document No. Filter") <> '' then
                                        VATCtrlReportLineCZL.SetFilter("Closed by Document No.", GetFilter("Closed by Document No. Filter"))
                                    else
                                        VATCtrlReportLineCZL.SetRange("Closed by Document No.");
                            end;
                            if VATCtrlReportLineCZL.FindSet() then
                                repeat
                                    case VATCtrlReportLineCZL."VAT Ctrl. Report Section Code" of
                                        'A5', 'B3':
                                            begin
                                                // A5 and B3 section summary
                                                if not VATControlReportBuffer.Get(VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", 0) then begin
                                                    VATControlReportBuffer.Init();
                                                    VATControlReportBuffer."VAT Ctrl. Report Section Code" := VATCtrlReportLineCZL."VAT Ctrl. Report Section Code";
                                                    VATControlReportBuffer."Line No." := 0;
                                                    VATControlReportBuffer.Insert();
                                                end;
                                                case VATCtrlReportLineCZL."VAT Rate" of
                                                    VATCtrlReportLineCZL."VAT Rate"::Base:
                                                        begin
                                                            VATControlReportBuffer."Base 1" += VATCtrlReportLineCZL.Base;
                                                            VATControlReportBuffer."Amount 1" += VATCtrlReportLineCZL.Amount;
                                                        end;
                                                    VATCtrlReportLineCZL."VAT Rate"::Reduced:
                                                        begin
                                                            VATControlReportBuffer."Base 2" += VATCtrlReportLineCZL.Base;
                                                            VATControlReportBuffer."Amount 2" += VATCtrlReportLineCZL.Amount;
                                                        end;
                                                    VATCtrlReportLineCZL."VAT Rate"::"Reduced 2":
                                                        begin
                                                            VATControlReportBuffer."Base 3" += VATCtrlReportLineCZL.Base;
                                                            VATControlReportBuffer."Amount 3" += VATCtrlReportLineCZL.Amount;
                                                        end;
                                                end;
                                                VATControlReportBuffer.Modify();
                                            end;
                                        else begin
                                            // other section codes
                                            CopyLineToBuffer(VATCtrlReportLineCZL, VATControlReportBuffer);
                                            VATControlReportBuffer.Insert();
                                        end;
                                    end;
                                until VATCtrlReportLineCZL.Next() = 0;
                        end;
                    ReportPrintType::Export:
                        VATCtrlReportMgtCZL.CreateBufferForExport(VATControlReportHeader, VATControlReportBuffer, false, VATStatementReportSelection);
                    ReportPrintType::Summary:
                        VATCtrlReportMgtCZL.CreateBufferForStatistics(VATControlReportHeader, VATControlReportBuffer, false);
                end;

                VATControlReportBuffer.Reset();
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ReportPrintTypeCZL; ReportPrintType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print';
                        OptionCaption = 'Detail,Export,Summary';
                        ToolTip = 'Specifies the preparation the document. A report request window for the document opens where you can specify what to include on the print-out.';

                        trigger OnValidate()
                        begin
                            LinesDetailEnable := (ReportPrintType = ReportPrintType::Detail);
                        end;
                    }
                    field(ReportPrintEntriesCZL; ReportPrintEntries)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Entries';
                        Enabled = LinesDetailEnable;
                        OptionCaption = 'All,Export,Not Export';
                        ToolTip = 'Specifies to indicate that detailed documents will print.';
                    }
                    field(SelectionCZL; VATStatementReportSelection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Entries Selection';
                        ToolTip = 'Specifies if opened, closed or opened and closed VAT Control Report lines have to be printed.';
                    }
                    field(OnlyErrorLinesCZL; OnlyErrorLines)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print only lines with error';
                        Enabled = LinesDetailEnable;
                        ToolTip = 'Specifies if only lines with error has to be printed.';
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            LinesDetailEnable := (ReportPrintType = ReportPrintType::Detail);
        end;
    }
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportMgtCZL: Codeunit "VAT Ctrl. Report Mgt. CZL";
        ReportCaptionLbl: Label 'VAT Control Report - Test';
        MustBeSpecifiedErr: Label '%1 must be specified.', Comment = '%1 = FieldCaption';
        PageCaptionLbl: Label 'Page';
        ErrorTextLbl: Label 'Warning!';
        ErrorText: array[99] of Text;
        ErrorCounter: Integer;
        ReportPrintType: Option Detail,Export,Summary;
        ReportPrintEntries: Option All,Export,"Not Export";
        OnlyErrorLines: Boolean;
        LinesDetailEnable: Boolean;
        VATStatementReportSelection: Enum "VAT Statement Report Selection";

    local procedure AddError(Text: Text)
    begin
        ErrorCounter := ErrorCounter + 1;
        ErrorText[ErrorCounter] := Text;
    end;

    local procedure CopyBufferToLine(var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary; var VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL")
    begin
        VATCtrlReportMgtCZL.CopyBufferToLine(TempVATCtrlReportBufferCZL, VATCtrlReportLineCZL);

        if (TempVATCtrlReportBufferCZL."Base 1" <> 0) or (TempVATCtrlReportBufferCZL."Amount 1" <> 0) then begin
            VATCtrlReportLineCZL."VAT Rate" := TempVATCtrlReportBufferCZL."VAT Rate"::Base;
            VATCtrlReportLineCZL.Base := TempVATCtrlReportBufferCZL."Base 1";
            VATCtrlReportLineCZL.Amount := TempVATCtrlReportBufferCZL."Amount 1";
        end;
        if (TempVATCtrlReportBufferCZL."Base 2" <> 0) or (TempVATCtrlReportBufferCZL."Amount 2" <> 0) then begin
            VATCtrlReportLineCZL."VAT Rate" := TempVATCtrlReportBufferCZL."VAT Rate"::Reduced;
            VATCtrlReportLineCZL.Base := TempVATCtrlReportBufferCZL."Base 2";
            VATCtrlReportLineCZL.Amount := TempVATCtrlReportBufferCZL."Amount 2";
        end;
        if (TempVATCtrlReportBufferCZL."Base 3" <> 0) or (TempVATCtrlReportBufferCZL."Amount 3" <> 0) then begin
            VATCtrlReportLineCZL."VAT Rate" := TempVATCtrlReportBufferCZL."VAT Rate"::"Reduced 2";
            VATCtrlReportLineCZL.Base := TempVATCtrlReportBufferCZL."Base 3";
            VATCtrlReportLineCZL.Amount := TempVATCtrlReportBufferCZL."Amount 3";
        end;
        VATCtrlReportLineCZL.Name := TempVATCtrlReportBufferCZL.Name;
        VATCtrlReportLineCZL."Birth Date" := TempVATCtrlReportBufferCZL."Birth Date";
        VATCtrlReportLineCZL."Place of Stay" := TempVATCtrlReportBufferCZL."Place of Stay";
    end;

    local procedure CopyLineToBuffer(var VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL"; var TempVATCtrlReportBufferCZL: Record "VAT Ctrl. Report Buffer CZL" temporary)
    begin
        VATCtrlReportMgtCZL.CopyLineToBuffer(VATCtrlReportLineCZL, TempVATCtrlReportBufferCZL);

        case TempVATCtrlReportBufferCZL."VAT Rate" of
            TempVATCtrlReportBufferCZL."VAT Rate"::Base:
                begin
                    TempVATCtrlReportBufferCZL."Base 1" := VATCtrlReportLineCZL.Base;
                    TempVATCtrlReportBufferCZL."Amount 1" := VATCtrlReportLineCZL.Amount;
                end;
            TempVATCtrlReportBufferCZL."VAT Rate"::Reduced:
                begin
                    TempVATCtrlReportBufferCZL."Base 2" := VATCtrlReportLineCZL.Base;
                    TempVATCtrlReportBufferCZL."Amount 2" := VATCtrlReportLineCZL.Amount;
                end;
            TempVATCtrlReportBufferCZL."VAT Rate"::"Reduced 2":
                begin
                    TempVATCtrlReportBufferCZL."Base 3" := VATCtrlReportLineCZL.Base;
                    TempVATCtrlReportBufferCZL."Amount 3" := VATCtrlReportLineCZL.Amount;
                end;
        end;
    end;

    local procedure CheckMandatoryFields()
    begin
        if VATCtrlReportLineCZL."VAT Ctrl. Report Section Code" <> 'A3' then
            CheckMandatoryField(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL."VAT Registration No."), VATCtrlReportLineCZL.FieldCaption(VATCtrlReportLineCZL."VAT Registration No."), VATCtrlReportLineCZL."VAT Registration No." = '')
        else
            if (VATCtrlReportLineCZL.Name = '') or (VATCtrlReportLineCZL."Birth Date" = 0D) or (VATCtrlReportLineCZL."Place of Stay" = '') then
                CheckMandatoryField(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL."VAT Registration No."), VATCtrlReportLineCZL.FieldCaption(VATCtrlReportLineCZL."VAT Registration No."), VATCtrlReportLineCZL."VAT Registration No." = '');

        CheckMandatoryField(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL."Posting Date"), VATCtrlReportLineCZL.FieldCaption(VATCtrlReportLineCZL."Posting Date"), VATCtrlReportLineCZL."Posting Date" = 0D);
        CheckMandatoryField(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL."Document No."), VATCtrlReportLineCZL.FieldCaption(VATCtrlReportLineCZL."Document No."), VATCtrlReportLineCZL."Document No." = '');
        CheckMandatoryField(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL.Base), VATCtrlReportLineCZL.FieldCaption(VATCtrlReportLineCZL.Base), VATCtrlReportLineCZL.Base = 0);
        CheckMandatoryField(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL.Amount), VATCtrlReportLineCZL.FieldCaption(VATCtrlReportLineCZL.Amount), VATCtrlReportLineCZL.Amount = 0);
        CheckMandatoryField(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL."Commodity Code"), VATCtrlReportLineCZL.FieldCaption(VATCtrlReportLineCZL."Commodity Code"), VATCtrlReportLineCZL."Commodity Code" = '');

        if VATCtrlReportLineCZL."VAT Registration No." = '' then begin
            CheckMandatoryField(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL.Name), VATCtrlReportLineCZL.FieldCaption(VATCtrlReportLineCZL.Name), VATCtrlReportLineCZL.Name = '');
            CheckMandatoryField(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL."Birth Date"), VATCtrlReportLineCZL.FieldCaption(VATCtrlReportLineCZL."Birth Date"), VATCtrlReportLineCZL."Birth Date" = 0D);
            CheckMandatoryField(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL."Place of Stay"), VATCtrlReportLineCZL.FieldCaption(VATCtrlReportLineCZL."Place of Stay"), VATCtrlReportLineCZL."Place of Stay" = '');
        end;

        CheckMandatoryField(VATCtrlReportLineCZL.FieldNo(VATCtrlReportLineCZL."Ratio Use"), VATCtrlReportLineCZL.FieldCaption(VATCtrlReportLineCZL."Ratio Use"), not VATCtrlReportLineCZL."Ratio Use");
    end;

    local procedure CheckMandatoryField(FieldNo: Integer; FieldCaption: Text; FieldIsEmpty: Boolean)
    begin
        if not FieldIsEmpty then
            exit;

        if not VATCtrlReportMgtCZL.CheckMandatoryField(FieldNo, VATCtrlReportLineCZL) then
            AddError(StrSubstNo(MustBeSpecifiedErr, FieldCaption));
    end;
}
