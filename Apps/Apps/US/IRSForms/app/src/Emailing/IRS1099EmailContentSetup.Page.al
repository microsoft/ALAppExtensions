// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10055 "IRS 1099 Email Content Setup"
{
    PageType = Card;
    ApplicationArea = BasicUS;

    layout
    {
        area(content)
        {
            group(EmailSubject)
            {
                Caption = 'Email Subject';
                field("Email Subject"; EmailSubject)
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
                    ShowCaption = false;
                    ExtendedDatatype = RichContent;
                    MultiLine = true;
                    Importance = Additional;
                }
            }
        }
    }

    var
        EmailSubject: Text[250];
        EmailBody: Text;

#if not CLEAN25
    trigger OnOpenPage()
    var
        IRSFormsFeature: Codeunit "IRS Forms Feature";
    begin
        CurrPage.Editable := IRSFormsFeature.FeatureCanBeUsed();
    end;
#endif

    procedure SetValues(NewEmailSubject: Text[250]; NewEmailBody: Text[2048])
    begin
        EmailSubject := NewEmailSubject;
        EmailBody := NewEmailBody;
    end;

    procedure GetValues(var NewEmailSubject: Text[250]; var NewEmailBody: Text[2048])
    begin
        NewEmailSubject := EmailSubject;
        NewEmailBody := CopyStr(EmailBody, 1, MaxStrLen(NewEmailBody));
    end;
}