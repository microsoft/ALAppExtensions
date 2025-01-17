// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10030 "IRS Forms Setup"
{
    PageType = Card;
    SourceTable = "IRS Forms Setup";
    ApplicationArea = BasicUS;
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;
    DataCaptionExpression = '';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Collect Details For Line"; Rec."Collect Details For Line")
                {
                    ToolTip = 'Specifies if the mapping between the IRS 1099 Form Line and associated vendor ledger entries must be kept. That will allow you to drill-down into the Amount field, but requires an extra space in the database.';
                }
                field("Protect TIN"; Rec."Protect TIN")
                {
                    ToolTip = 'Specifies if the TIN of the vendor/company must be protected when printing reports.';
                }
            }
#if not CLEAN26
            group(EmailSubject)
            {
                Caption = 'Email Subject';
                Visible = false;
                ObsoleteReason = 'The group was moved to the new page IRS 1099 Email Content Setup.';
                ObsoleteState = Pending;
                ObsoleteTag = '26.0';
                field("Email Subject"; Rec."Email Subject")
                {
                    ShowCaption = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the subject of the email with 1099 form that is sent to the vendor.';
                    Visible = false;
                    ObsoleteReason = 'The field was moved to the new page IRS 1099 Email Content Setup.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';
                }
            }
            group(EmailBody)
            {
                Caption = 'Email Body';
                Visible = false;
                ObsoleteReason = 'The group was moved to the new page IRS 1099 Email Content Setup.';
                ObsoleteState = Pending;
                ObsoleteTag = '26.0';
                field("Email Body"; EmailBody)
                {
                    ExtendedDatatype = RichContent;
                    MultiLine = true;
                    Importance = Additional;
                    Caption = 'Email Body';
                    ToolTip = 'Specifies the body of the email with 1099 form that is sent to the vendor.';
                    Visible = false;
                    ObsoleteReason = 'The field was moved to the new page IRS 1099 Email Content Setup.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';

                    trigger OnValidate()
                    begin
                        Rec."Email Body" := CopyStr(EmailBody, 1, MaxStrLen(Rec."Email Body"));
                    end;
                }
            }
#endif
        }
    }

    actions
    {
        area(Navigation)
        {
            action(EmailContentSetup)
            {
                ApplicationArea = BasicUS;
                Caption = 'Email Content Setup';
                Image = Email;
                ToolTip = 'Setup the subject and the body of the email with 1099 form that is sent to the vendor.';

                trigger OnAction()
                var
                    IRS1099EmailContentSetup: Page "IRS 1099 Email Content Setup";
                begin
                    Rec.InitSetup();
                    IRS1099EmailContentSetup.SetValues(Rec."Email Subject", Rec."Email Body");
                    IRS1099EmailContentSetup.LookupMode(true);
                    if IRS1099EmailContentSetup.RunModal() = Action::LookupOK then begin
                        IRS1099EmailContentSetup.GetValues(Rec."Email Subject", Rec."Email Body");
                        Rec.Modify(true);
                    end;
                end;

            }
        }
        area(Promoted)
        {
            actionref(EmailContentSetup_Promoted; EmailContentSetup)
            {
            }
        }
    }
#if not CLEAN26
    var
        EmailBody: Text;
#endif
#if not CLEAN25
    trigger OnOpenPage()
    var
        IRSFormsFeature: Codeunit "IRS Forms Feature";
    begin
        CurrPage.Editable := IRSFormsFeature.FeatureCanBeUsed();
    end;
#endif
}
