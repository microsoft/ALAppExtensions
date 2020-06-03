// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page that enables a user to pick which new features to use
/// </summary>
page 2610 "Feature Management"
{
    PageType = List;
    Caption = 'Feature Management';
    ApplicationArea = All;
    UsageCategory = Administration;
    AdditionalSearchTerms = 'new features,feature key,opt in,turn off features,enable features,early access,preview';
    SourceTable = "Feature Key";
    InsertAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(FeatureKeys)
            {
                field(FeatureDescription; Description)
                {
                    Caption = 'Feature';
                    ToolTip = 'The name of the new capability or change in design.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(LearnMore; LearnMoreLbl)
                {
                    ShowCaption = false;
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Learn more';
                    ToolTip = 'View a detailed description of new capabilities and behaviors that are available when the feature is enabled (opens in a new tab).';

                    trigger OnDrillDown()
                    begin
                        Hyperlink("Learn More Link");
                    end;
                }
                field(MandatoryBy; "Mandatory By")
                {
                    Caption = 'Automatically enabled from';
                    ToolTip = 'Specifies a future software version and approximate date when this feature is automatically enabled for all users and cannot be disabled. Until this future version, the feature is optional.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(EnabledFor; Enabled)
                {
                    Caption = 'Enabled for';
                    ToolTip = 'Specifies whether the feature is enabled for all users or for none. The change takes effect the next time each user signs in.';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        FeatureManagementImpl.SendSignInAgainNotification();
                    end;
                }
                field(TryItOut; TryItOut)
                {
                    Caption = 'Get started';
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = "Can Try";
                    ToolTip = 'Starts a new session with the feature temporarily enabled (opens in a new tab). This does not affect any other users.';
                    trigger OnDrillDown()
                    begin
                        if "Can Try" then begin
                            HyperLink(FeatureManagementImpl.GetFeatureKeyUrlForWeb(ID));
                            Message(TryItOutStartedMsg);
                        end;
                    end;
                }
            }
        }
        area(factboxes)
        {
            part("Upcoming Changes FactBox"; "Upcoming Changes Factbox")
            {
                ApplicationArea = All;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if "Can Try" then
            TryItOut := TryItOutLbl
        else
            Clear(TryItOut);
    end;

    var
        FeatureManagementImpl: Codeunit "Feature Management Impl.";
        LearnMoreLbl: Label 'Learn more';
        TryItOutLbl: Label 'Try it out';
        TryItOutStartedMsg: Label 'This feature has been enabled for new sessions in your browser. When you are done, sign out or close the browser.';
        TryItOut: Text;
}