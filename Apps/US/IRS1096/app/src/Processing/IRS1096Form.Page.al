// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10021 "IRS 1096 Form"
{
    Caption = '1096 Form';
    PageType = Card;
    SourceTable = "IRS 1096 Form Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the unique number of the form.';

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the starting date of the form.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the ending date of the form.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the status of the form. Only released forms can be printed. Only opened forms can be changed.';
                }
                field("IRS Code"; Rec."IRS Code")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the IRS code of the form.';
                }
                field("Calculated Total Number Of Forms"; Rec."Calc. Total Number Of Forms")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the number of forms per period and IRS code calculated by the Create Forms action on the list page. This value cannot be changed.';
                }
                field("Total Number Of Forms"; Rec."Total Number Of Forms")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the number of forms used for printing the form. This value matches the calculated number of forms after clicking the Create Forms action and can be changed manually.';
                }
                field("Calc. Amount"; Rec."Calc. Amount")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the amount per period and IRS code calculated by the Create Forms action on the list page. This value cannot be changed.';

                    trigger OnDrillDown()
                    var
                        IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
                    begin
                        IRS1096FormMgt.ShowRelatedVendorsLedgerEntries(Rec."No.", 0);
                    end;
                }
                field("Calc. Adjustment Amount"; Rec."Calc. Adjustment Amount")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the adjustment amount per period and IRS code calculated by the Create Forms action on the list page.';
                }
                field("Total Amount To Report"; Rec."Total Amount To Report")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the amount used for printing the form. This value matches the calculated amount minus calculated adjustment amount after clicking the Create Forms action and can be changed manually.';
                }
            }
            group(History)
            {
                field("Changed By"; Rec."Changed By")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the ID of the user changed the form last time.';
                }
                field("Changed Date-Time"; Rec."Changed Date-Time")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the date and time when the form has been changed last time.';
                }
                field(Printed; Rec.Printed)
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies that the form has been printed.';
                }
                field("Printed By"; Rec."Printed By")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the ID of the user printed the form last time.';
                }
                field("Printed Date-Time"; Rec."Printed Date-Time")
                {
                    ApplicationArea = BasicUS;
                    ToolTip = 'Specifies the date and time when the form has been printed last time.';
                }
            }
            part(FormLines; "IRS 1096 Form Subform")
            {
                ApplicationArea = BasicUS;
                SubPageLink = "Form No." = field("No.");
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
        {
            systempart(LinksFactBox; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
                Provider = FormLines;
            }
            systempart(NotesFactBox; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
                Provider = FormLines;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(ReleaseReopen)
            {
                Caption = 'Release';
                Image = ReleaseDoc;
                action(Release)
                {
                    ApplicationArea = BasicUS;
                    Caption = 'Re&lease';
                    Enabled = Rec.Status = Rec.Status::Open;
                    Image = ReleaseDoc;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the form before printing it. You must reopen the form before you can make changes to it.';

                    trigger OnAction()
                    var
                        IRS1096Mgt: Codeunit "IRS 1096 Form Mgt.";
                    begin
                        IRS1096Mgt.ReleaseForm(Rec);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = BasicUS;
                    Caption = 'Re&open';
                    Enabled = Rec.Status <> Rec.Status::Open;
                    Image = ReOpen;
                    ToolTip = 'Reopen the form to change it after it has been approved. Approved forms have the Released status and must be opened before they can be changed.';

                    trigger OnAction()
                    var
                        IRS1096Mgt: Codeunit "IRS 1096 Form Mgt.";
                    begin
                        IRS1096Mgt.ReopenForm(Rec);
                    end;
                }
                action(Print)
                {
                    ApplicationArea = BasicUS;
                    Caption = 'Print';
                    Ellipsis = true;
                    Image = PrintAcknowledgement;
                    ToolTip = 'Prints a single form.';

                    trigger OnAction()
                    var
                        IRS1096FormMgt: Codeunit "IRS 1096 Form Mgt.";
                    begin
                        IRS1096FormMgt.PrintSingleForm(Rec);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Category5)
            {
                Caption = 'Release';
                ShowAs = SplitButton;

                actionref(Release_Promoted; Release)
                {
                }
                actionref(Reopen_Promoted; Reopen)
                {
                }
            }
            group(Category_Category11)
            {
                Caption = 'Print';
                actionref(Print_Single; Print)
                {
                }
            }
        }
    }
}
