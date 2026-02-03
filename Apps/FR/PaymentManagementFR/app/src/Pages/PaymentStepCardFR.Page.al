// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

page 10851 "Payment Step Card FR"
{
    Caption = 'Payment Step Card';
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "Payment Step FR";

    layout
    {
        area(content)
        {
            group(Control1)
            {
                ShowCaption = false;
                field("Payment Class"; Rec."Payment Class")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the payment class.';
                }
                field(Line; Rec.Line)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the step line''s entry number.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies text to describe the payment step.';
                }
                field("Previous Status"; Rec."Previous Status")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status from which this step should start executing.';

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Previous Status Name");
                    end;
                }
                field("Previous Status Name"; Rec."Previous Status Name")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies the name of the status selected in the Previous Status field.';
                }
                field("Next Status"; Rec."Next Status")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status on which this step should end.';

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Next Status Name");
                    end;
                }
                field("Next Status Name"; Rec."Next Status Name")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies the name of the status selected in the Next Status field.';
                }
                field("Action Type"; Rec."Action Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of action to be performed by this step.';

                    trigger OnValidate()
                    begin
                        DisableFields();
                    end;
                }
                field("Report No."; Rec."Report No.")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = ReportNoEnable;
                    ToolTip = 'Specifies the ID for the report used, when Action Type is set to Report.';
                }
                field("Export Type"; Rec."Export Type")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = ExportTypeEnable;
                    ToolTip = 'Specifies the method that is used to export files.';
                }
                field("Export No."; Rec."Export No.")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = ExportNoEnable;
                    ToolTip = 'Specifies the ID code for the selected export type.';
                }
                field("Verify Lines RIB"; Rec."Verify Lines RIB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the RIB of the header on the payment slip lines has been properly reported.';
                }
                field("Verify Due Date"; Rec."Verify Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the due date on the billing and payment lines has been properly reported.';
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = SourceCodeEnable;
                    ToolTip = 'Specifies the source code linked to the payment step.';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = ReasonCodeEnable;
                    ToolTip = 'Specifies the reason code linked to the payment step.';
                }
                field("Header Nos. Series"; Rec."Header Nos. Series")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = HeaderNosSeriesEnable;
                    ToolTip = 'Specifies the code used to assign numbers to the header of a new payment slip.';
                }
                field(Correction; Rec.Correction)
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = CorrectionEnable;
                    ToolTip = 'Specifies you want the payment entries to pass as corrections.';
                }
                field("Realize VAT"; Rec."Realize VAT")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = RealizeVATEnable;
                    ToolTip = 'Specifies that the unrealized VAT should be reversed and the VAT should be declared.';
                }
                field("Verify Header RIB"; Rec."Verify Header RIB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the RIB on the payment slip header has been properly reported.';
                }
                field("Acceptation Code<>No"; Rec."Acceptation Code<>No")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the acceptation code on each payment line is not No.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Payment Step")
            {
                Caption = 'Payment Step';
                Image = Installments;
                action(Ledger)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ledger';
                    Image = Ledger;
                    RunObject = Page "Payment Step Ledger List FR";
                    RunPageLink = "Payment Class" = field("Payment Class"),
                                  Line = field(Line);
                    ToolTip = 'View and edit the list of payment steps for posting debit and credit entries to the general ledger.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DisableFields();
    end;

    trigger OnInit()
    begin
        CorrectionEnable := true;
        HeaderNosSeriesEnable := true;
        SourceCodeEnable := true;
        ReasonCodeEnable := true;
        ExportNoEnable := true;
        ExportTypeEnable := true;
        ReportNoEnable := true;
    end;

    var
        PaymentClass: Record "Payment Class FR";
        ReportNoEnable: Boolean;
        ExportTypeEnable: Boolean;
        ExportNoEnable: Boolean;
        ReasonCodeEnable: Boolean;
        SourceCodeEnable: Boolean;
        HeaderNosSeriesEnable: Boolean;
        CorrectionEnable: Boolean;
        RealizeVATEnable: Boolean;


    procedure DisableFields()
    begin
        case Rec."Action Type" of
            Rec."Action Type"::None:
                begin
                    ReportNoEnable := false;
                    ExportTypeEnable := false;
                    ExportNoEnable := false;
                    ReasonCodeEnable := false;
                    SourceCodeEnable := false;
                    HeaderNosSeriesEnable := false;
                    CorrectionEnable := false;
                    RealizeVATEnable := false;
                end;

            Rec."Action Type"::Ledger:
                begin
                    ReportNoEnable := false;
                    ExportTypeEnable := false;
                    ExportNoEnable := false;
                    ReasonCodeEnable := true;
                    SourceCodeEnable := true;
                    HeaderNosSeriesEnable := false;
                    CorrectionEnable := true;
                    PaymentClass.Get(Rec."Payment Class");
                    RealizeVATEnable :=
                        (PaymentClass."Unrealized VAT Reversal" = PaymentClass."Unrealized VAT Reversal"::Delayed);
                end;

            Rec."Action Type"::Report:
                begin
                    ReportNoEnable := true;
                    ExportTypeEnable := false;
                    ExportNoEnable := false;
                    ReasonCodeEnable := false;
                    SourceCodeEnable := false;
                    HeaderNosSeriesEnable := false;
                    CorrectionEnable := false;
                    RealizeVATEnable := false;
                end;

            Rec."Action Type"::File:
                begin
                    ReportNoEnable := false;
                    ExportTypeEnable := true;
                    ExportNoEnable := true;
                    ReasonCodeEnable := false;
                    SourceCodeEnable := false;
                    HeaderNosSeriesEnable := false;
                    CorrectionEnable := false;
                    RealizeVATEnable := false;
                end;

            Rec."Action Type"::"Create New Document":
                begin
                    ReportNoEnable := false;
                    ExportTypeEnable := false;
                    ExportNoEnable := false;
                    ReasonCodeEnable := false;
                    SourceCodeEnable := false;
                    HeaderNosSeriesEnable := true;
                    CorrectionEnable := false;
                    RealizeVATEnable := false;
                end;
        end;
    end;
}

