// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page is used to display email rate limit usage by email accounts.
/// </summary>
page 8898 "Email Rate Limit Wizard"
{
    Caption = 'Set Email Rate Limit per Minute';
    PageType = NavigatePage;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "Email Rate Limit";
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
                ToolTip = 'Specifies the maximum number of emails per minute the account can send. A rate limit of 0 indicates no limit.';
                Numeric = true;

                trigger OnValidate()
                begin
                    UpdateRateLimitDisplay();
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
                    Rec.Modify();
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        EmailRateLimitDisplay := Format(Rec."Rate Limit");
        UpdateRateLimitDisplay();
    end;

    internal procedure SetEmailAccountName(EmailAccountName: Text[250])
    begin
        EmailName := EmailAccountName;
    end;

    internal procedure UpdateRateLimitDisplay()
    begin
        Evaluate(Rec."Rate Limit", EmailRateLimitDisplay);
        if Rec."Rate Limit" = 0 then
            EmailRateLimitDisplay := NoLimitTxt;
    end;

    var
        EmailRateLimitDisplay: Text[250];
        EmailName: Text[250];
        NoLimitTxt: label 'No limit';
}