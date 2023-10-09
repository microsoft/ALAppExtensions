namespace Microsoft.Bank.StatementImport.Yodlee;

page 1454 "MS - Yodlee Terms of use"
{
    Caption = 'Envestnet Yodlee Bank Feeds - Terms of use';
    PageType = NavigatePage;
    SourceTable = "MS - Yodlee Bank Service Setup";

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
                    InstructionalText = 'With the third-party Envestnet Yodlee Bank Feeds service, you can link your bank accounts in Dynamics 365 Business Central to your online bank accounts to get electronic bank feeds. By agreeing to the terms of use you give consent to Microsoft to use, collect, store, handle and share your data in accordance with the Microsoft Privacy Statement (see link below). YOU PROVIDE LOG-IN CREDENTIALS TO YOUR ACCOUNTS AT YOUR OWN RISK. BY USING ENVESTNET YODLEE BANK FEEDS SERVICE YOU AGREE THAT THE DATA SOURCES THAT MAINTAIN YOUR ACCOUNTS AND ANY THIRD PARTIES THAT INTERACT WITH YOUR CREDENTIALS OR ACCOUNT DATA IN CONNECTION WITH OUR SERVICE ARE NOT LIABLE FOR ANY LOSS, THEFT, COMPROMISE, OR MISUSE WHATSOEVER IN CONNECTION WITH OUR SERVICES (INCLUDING NEGLIGENCE), EXCEPT TO THE EXTENT SUCH LIABILITY CANNOT BE LIMITED UNDER APPLICABLE LAW. DATA SOURCES MAKE NO WARRANTIES OF ANY KIND RELATED TO THE DATA PROVIDED BY OUR SERVICES--WHETHER EXPRESS, IMPLIED, STATUTORY, OR OTHERWISE. EXCEPT FOR PDFS OF OFFICIAL ACCOUNT DOCUMENTS WE RETRIEVE ON YOUR BEHALF AND PROVIDE TO YOU WITHOUT ALTERATION, NO DATA PROVIDED BY OUR SERVICES IS AN OFFICIAL RECORD OF ANY OF YOUR ACCOUNTS.';
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
                    field(MicrosoftPrivacyStmtLbl; MicrosoftPrivacyStatementLbl)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'Specifies a link to the Microsoft Privacy Statement.';

                        trigger OnDrillDown();
                        begin
                            HYPERLINK(MicrosoftPrivacyStatementTxt);
                        end;
                    }
                    field("Accept Terms of Use"; Rec."Accept Terms of Use")
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
        TermsOfUseVisible := true;
        CloseButtonVisible := CURRENTCLIENTTYPE() <> CLIENTTYPE::Windows;
    end;

    var
        TermsOfUseLinkLbl: Label 'Envestnet Yodlee Terms of Use';
        MicrosoftPrivacyStatementLbl: Label 'Microsoft Privacy Statement';
        TermsOfUseUrlTxt: Label 'https://www.yodlee.com/legal/terms-of-use', Locked = true;
        MicrosoftPrivacyStatementTxt: Label 'https://aka.ms/privacy', Locked = true;
        TermsOfUseVisible: Boolean;
        CloseButtonVisible: Boolean;
}

