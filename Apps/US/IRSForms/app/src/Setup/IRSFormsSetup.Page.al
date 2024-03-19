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
            group(EmailSubject)
            {
                Caption = 'Email Subject';
                field("Email Subject"; Rec."Email Subject")
                {
                    ShowCaption = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the subject of the email with 1099 form that is sent to the vendor.';
                }
            }
            group(EmailBody)
            {
                Caption = 'Email Body';
                field("Email Body"; EmailBody)
                {
                    ExtendedDatatype = RichContent;
                    MultiLine = true;
                    Importance = Additional;
                    Caption = 'Email Body';
                    ToolTip = 'Specifies the body of the email with 1099 form that is sent to the vendor.';

                    trigger OnValidate()
                    begin
                        Rec."Email Body" := CopyStr(EmailBody, 1, MaxStrLen(Rec."Email Body"));
                    end;
                }
            }
        }
    }

    var
        EmailBody: Text;

    trigger OnOpenPage()
    var
#if not CLEAN25
        IRSFormsFeature: Codeunit "IRS Forms Feature";
#endif
    begin
#if not CLEAN25
        CurrPage.Editable := IRSFormsFeature.FeatureCanBeUsed();
#endif
        Rec.InitSetup();
        EmailBody := Rec."Email Body";
    end;
}
