// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10059 "Transmission IRIS Subform"
{
    PageType = ListPart;
    ApplicationArea = BasicUS;
    Caption = 'Documents';
    SourceTable = "IRS 1099 Form Doc. Header";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("IRIS Needs Correction"; Rec."IRIS Needs Correction")
                {
                    Editable = NeedsCorrectionEditable;
                }
                field("IRIS Updated Not Sent"; Rec."IRIS Updated Not Sent")
                {
                }
                field(ID; Rec.ID)
                {
                    ToolTip = 'Specifies the ID of the 1099 form document.';

                    trigger OnAssistEdit()
                    begin
                        Page.RunModal(Page::"IRS 1099 Form Document", Rec);
                    end;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies the vendor number for which the 1099 form will be sent.';
                    Editable = false;
                }
                field("Form No."; Rec."Form No.")
                {
                    ToolTip = 'Specifies the form type.';
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    StyleExpr = DocStatusStyle;

                    Caption = 'Document Status';
                    ToolTip = 'Specifies the status of the 1099 form document.';
                    Editable = false;
                }
                field("IRIS Submission ID"; Rec."IRIS Submission ID")
                {
                    Visible = false;
                }
                field("IRIS Record ID"; Rec."IRIS Record ID")
                {
                    Visible = false;
                }
                field("IRIS Submission Status"; Rec."IRIS Submission Status")
                {
                    StyleExpr = SubmStatusStyle;

                    trigger OnDrillDown()
                    begin
                        if Rec."IRIS Submission ID" = '' then
                            exit;

                        if Rec."IRIS Submission Status" in
                            [Enum::"Transmission Status IRIS"::None,
                             Enum::"Transmission Status IRIS"::Accepted,
                             Enum::"Transmission Status IRIS"::Processing]
                        then
                            exit;

                        ProcessTransmission.ShowErrorInformation(Rec."IRIS Transmission Document ID", Rec."IRIS Submission ID", Rec."IRIS Record ID");
                    end;
                }
                field("IRIS Corrected"; Format(Rec."IRIS Corrected"))
                {
                    Caption = 'Corrected';
                    ToolTip = 'Specifies if the selected 1099 form was previously sent in a correction transmission.';
                    Editable = false;
                    StyleExpr = CorrectedStyle;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetDocStatusStyle();
        SetSubmStatusStyle();
        SetCorrectedStyle();
        SetNeedsCorrectionEditable();
    end;

    var
        ProcessTransmission: Codeunit "Process Transmission IRIS";
        DocStatusStyle: Text;
        SubmStatusStyle: Text;
        CorrectedStyle: Text;
        NeedsCorrectionEditable: Boolean;

    local procedure SetDocStatusStyle()
    begin
        DocStatusStyle := '';
        case Rec.Status of
            Enum::"IRS 1099 Form Doc. Status"::Open:
                DocStatusStyle := 'Attention';
            Enum::"IRS 1099 Form Doc. Status"::Abandoned:
                DocStatusStyle := 'Subordinate';
        end;
    end;

    local procedure SetSubmStatusStyle()
    var
        ErrorInformation: Record "Error Information IRIS";
    begin
        SubmStatusStyle := '';
        ProcessTransmission.FilterErrorInformation(ErrorInformation, Rec."IRIS Transmission Document ID", Rec."IRIS Submission ID", Rec."IRIS Record ID");
        if not ErrorInformation.IsEmpty() then
            SubmStatusStyle := 'Attention';
    end;

    local procedure SetCorrectedStyle()
    begin
        CorrectedStyle := '';
        if Rec."IRIS Corrected" then
            CorrectedStyle := 'Attention';
    end;

    local procedure SetNeedsCorrectionEditable()
    begin
        NeedsCorrectionEditable := true;
        if Rec.Status in [Enum::"IRS 1099 Form Doc. Status"::Open, Enum::"IRS 1099 Form Doc. Status"::Abandoned] then
            NeedsCorrectionEditable := false;
    end;
}