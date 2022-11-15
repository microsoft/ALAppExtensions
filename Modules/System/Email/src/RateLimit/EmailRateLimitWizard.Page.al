// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page is used to display email rate limit usage by email accounts.
/// </summary>
page 8898 "Email Rate Limit Wizard"
{
    Caption = 'Set Up the Rate Limit per Minute';
    PageType = NavigatePage;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "Email Rate Limit";
    SourceTableTemporary = true;
    InstructionalText = 'Assign email rate limit for an account';

    Permissions = tabledata "Email Rate Limit" = rim;

    layout
    {
        area(Content)
        {
            field(EmailName; EmailName)
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Email Account Name';
                ToolTip = 'The email account name for the current account.';
            }

            field(EmailAddress; Rec."Email Address")
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Email Address';
                ToolTip = 'The email address for the current email account.';
            }

            field(EmailRateLimitDisplay; EmailRateLimitDisplay)
            {
                ApplicationArea = All;
                Caption = 'Rate Limit per Minute';
                ToolTip = 'Specifies the rate limit for the current email account.';
                Numeric = true;

                trigger OnValidate()
                begin
                    DefaultEmailRateLimitDisplay := EmailRateLimitDisplay;
                end;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Done)
            {
                ApplicationArea = All;
                Caption = 'Confirm';
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Set the rate limit.';

                trigger OnAction()
                begin
                    Rec := EmailRateLimit;
                    Evaluate(Rec."Rate Limit", EmailRateLimitDisplay);
                    EmailRateLimitImpl.UpdateRateLimitForAccount(Rec);
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec := EmailRateLimit;
    end;

    // Used to set the focus on an email account
    internal procedure SetEmailAccountId(AccountId: Guid)
    begin
        EmailAccountId := AccountId;
    end;

    internal procedure SetEmailAddress(Address: Text[250])
    begin
        EmailAddress := Address;
    end;

    internal procedure SetEmailName(Name: Text[250])
    begin
        EmailName := Name;
    end;

    internal procedure SetEmailConnector(Connector: Enum "Email Connector")
    begin
        EmailConnector := Connector;
    end;

    internal procedure SetDefaultRateLimitDisplay()
    begin
        EmailRateLimitDisplay := 'No Limit';
        DefaultEmailRateLimitDisplay := 'No Limit';
    end;

    internal procedure UpdateDefaultRateLimitDisplay()
    begin
        EmailRateLimit.Get(EmailAccountId, EmailConnector);
        EmailRateLimitDisplay := Format(EmailRateLimit."Rate Limit");
        DefaultEmailRateLimitDisplay := Format(EmailRateLimit."Rate Limit");
    end;

    internal procedure GetEmailRateLimit(var RateLimit: Record "Email Rate Limit"): Boolean
    begin
        if IsNullGuid(Rec."Account Id") then
            exit(false);
        RateLimit.TransferFields(Rec);
        exit(true);
    end;

    var
        EmailRateLimit: Record "Email Rate Limit";
        EmailRateLimitImpl: Codeunit "Email Rate Limit Impl.";
        EmailAccountId: Guid;
        EmailRateLimitDisplay: Text[250];
        DefaultEmailRateLimitDisplay: Text[250];
        EmailName: Text[250];
        EmailAddress: Text[250];
        EmailConnector: Enum "Email Connector";
}