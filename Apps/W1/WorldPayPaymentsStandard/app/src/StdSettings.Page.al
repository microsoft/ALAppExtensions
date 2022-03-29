page 1364 "MS - WorldPay Std. Settings"
{
    Caption = 'WorldPay Email';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    ShowFilter = false;
    SourceTable = "MS - WorldPay Standard Account";

    layout
    {
        area(content)
        {
            group("WorldPay Information")
            {
                Caption = 'WorldPay Information';
                field(AccountID; AccountID)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'WorldPay Email';
                    ToolTip = 'Specify the Account';

                    trigger OnValidate()
                    var
                        MSWorldPayStandardMgt: Codeunit "MS - WorldPay Standard Mgt.";
                    begin
                        HideAllDialogs();
                        VALIDATE("Account ID", AccountID);

                        IF STRPOS(AccountID, SandboxPrefixTok) = 1 THEN
                            IF CONFIRM(WorldPaySandBoxModeQst) THEN BEGIN
                                SetTargetURL(MSWorldPayStandardMgt.GetSandboxURL());
                                EXIT;
                            END;

                        SetTargetURL(MSWorldPayStandardMgt.GetTargetURL());
                    end;
                }
                field("Terms of Service"; "Terms of Service")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    begin
                        HYPERLINK("Terms of Service");
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        AccountID := "Account ID";
    end;

    trigger OnOpenPage()
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSWorldPayStandardMgt: Codeunit "MS - WorldPay Standard Mgt.";
    begin
        IF ISEMPTY() THEN BEGIN
            MSWorldPayStandardMgt.RegisterWorldPayStandardTemplate(TempPaymentServiceSetup);

            MSWorldPayStandardMgt.GetTemplate(MSWorldPayStdTemplate);
            MSWorldPayStdTemplate.RefreshLogoIfNeeded();
            TRANSFERFIELDS(MSWorldPayStdTemplate, FALSE);
            INSERT(TRUE);

            COMMIT();
        END;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        IF CloseAction = ACTION::Cancel THEN
            EXIT(TRUE);

        // If we transition from disabled to enabled state
        // show 3rd party notice message
        IF NOT xRec.Enabled AND Enabled THEN
            MESSAGE(ThirdPartyNoticeMsg);

        HideAllDialogs();
        IF "Account ID" <> '' THEN BEGIN
            VALIDATE(Enabled, TRUE);
            VALIDATE("Always Include on Documents", TRUE);
            MODIFY(TRUE);
        END ELSE BEGIN
            VALIDATE(Enabled, FALSE);
            MODIFY(TRUE);
        END;

        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Invoice);
        IF SalesHeader.FINDSET(TRUE, FALSE) THEN
            REPEAT
                SalesHeader.SetDefaultPaymentServices();
                SalesHeader.MODIFY()
            UNTIL SalesHeader.NEXT() = 0;
    end;

    var
        MSWorldPayStdTemplate: Record "MS - WorldPay Std. Template";
        AccountID: Text[250];
        SandboxPrefixTok: Label 'sandbox.', Locked = true;
        WorldPaySandBoxModeQst: Label 'Do you want to enable WorldPay Sandbox setup?';
        ThirdPartyNoticeMsg: Label 'You are accessing a third-party website and service. You should review the third-party''''s terms and privacy policy.';
}

