page 1454 "MS - Yodlee Terms of use"
{
    Caption = 'Envestnet Yodlee Bank Feeds - Terms of use';
    PageType = NavigatePage;
    SourceTable = 1450;

    layout
    {
        area(content)
        {
            group(TermsOfUse)
            {
                ShowCaption = false;
                Visible = TermsOfUseVisible;
                group(TermsOfUseViewAndAccept)
                {
                    ShowCaption = false;
                    InstructionalText = 'With the third-party Envestnet Yodlee Bank Feeds service, you can link your bank accounts in Dynamics 365 Business Central to your online bank accounts to get electronic bank feeds. This enables efficient payment processing and bank reconciliation. To enable the service, you must read and agree to the terms of use from Envestnet Yodlee.';
                    field(TermsOfUseLbl; TermsOfUseLinkLbl)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'Specifies a link to the terms of use for Envestnet Yodlee.';

                        trigger OnDrillDown();
                        begin
                            HYPERLINK(TermsOfUseUrlTxt);
                        end;
                    }
                    field("Accept Terms of Use"; "Accept Terms of Use")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if you accept the terms of use for Envestnet Yodlee.';
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Close)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Close';
                Image = Close;
                InFooterBar = true;
                Visible = CloseButtonVisible;

                trigger OnAction();
                begin
                    CurrPage.CLOSE();
                end;
            }
        }
    }

    trigger OnOpenPage();
    begin
        TermsOfUseVisible := TRUE;
        CloseButtonVisible := CURRENTCLIENTTYPE() <> CLIENTTYPE::Windows;
    end;

    var
        TermsOfUseLinkLbl: Label 'Envestnet Yodlee Terms of Use';
        TermsOfUseUrlTxt: Label 'https://go.microsoft.com/fwlink/?LinkId=746179', Locked = true;
        TermsOfUseVisible: Boolean;
        CloseButtonVisible: Boolean;
}

