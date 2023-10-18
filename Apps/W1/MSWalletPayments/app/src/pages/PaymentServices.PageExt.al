#if not CLEAN21
pageextension 1088 "MS - Wallet Payment Services" extends "BC O365 Payment Services"
{
    ObsoleteReason = 'Microsoft Invoicing has been discontinued.';
    ObsoleteState = Pending;
    ObsoleteTag = '21.0';

    layout
    {
        addafter(Control85)
        {
            group("MsPayIsSetUpSpace")
            {
                InstructionalText = ' ';
                ShowCaption = false;
            }
            group("SetUpPayPalInMsPay")
            {
                InstructionalText = 'You can set up your PayPal account in Microsoft Pay Payments easily and fast. Once you do it, come back here and choose Microsoft Pay Payments as your payment service.';
                ShowCaption = false;
            }
            group("SetUpMsPay")
            {
                InstructionalText = 'You can set up your Microsoft Pay Payments merchant profile easily and fast. Accept the terms of service and add your favourite payment providers, and we will take care of the rest.';
                ShowCaption = false;
            }
            group(NonAdminUserMessage)
            {
                InstructionalText = 'Ask your Office 365 administrator to set up Microsoft Pay Payments so that your customers can pay you easily and fast.';
                ShowCaption = false;
            }
            group("MsPayIsSetUp")
            {
                InstructionalText = 'Your Microsoft Pay Payments merchant profile is configured and active. You are on track to be paid fast and easily!';
                ShowCaption = false;
            }

            group("SetUpMsPayLinkGroup")
            {
                ShowCaption = false;
                field("SetUpMsPayLinkControl"; MsPaySetupLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Initiates the steps required to set up Microsoft Pay Payments for this company.';
                }
            }
            group("MsPaySettingsLinkGroup")
            {
                ShowCaption = false;
                field("MsPaySettingsLinkControl"; MsPaySettingsLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
        }
    }

    var
        MsPaySetupLbl: Label 'Set up Microsoft Pay Payments';
        MsPaySettingsLbl: Label 'Microsoft Pay Payments Settings';
}
#endif