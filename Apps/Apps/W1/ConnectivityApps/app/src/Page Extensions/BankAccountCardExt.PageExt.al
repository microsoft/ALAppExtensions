// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

pageextension 20350 "Bank Account Card Ext." extends "Bank Account Card"
{
    actions
    {
        addlast(Processing)
        {
            action("Connect to Banks")
            {
                ApplicationArea = All;
                Caption = 'Connect to Banks';
                Visible = IsConnectivityAppsAvailable;
                Image = ElectronicBanking;
                ToolTip = 'View apps that can help you connect your business with banks, so you can easily import your bank transactions and transfer funds.';

                trigger OnAction()
                begin
                    Page.Run(Page::"Banking Apps");
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        IsConnectivityAppsAvailable := ConnectivityApps.IsConnectivityAppsAvailableForGeoAndCategory(ConnectivityAppsCategory::Banking);

        if IsConnectivityAppsAvailable then
            CreateConnectivityAppsNotification();
    end;

    var
        ConnectivityApps: Codeunit "Connectivity Apps";
        ConnectivityAppsCategory: Enum "Connectivity Apps Category";
        IsConnectivityAppsAvailable: Boolean;
        ConnectToBanksMsg: Label 'Automatically import bank transactions and transfer payments by installing a bank app. The options are available here.';
        NotificationActionLbl: Label 'Connect to banks';
        DisableNotificationTxt: Label 'Don''t show again';

    local procedure CreateConnectivityAppsNotification()
    var
        MyNotifications: Record "My Notifications";
        ConnectToBanks: Notification;
    begin
        if not MyNotifications.IsEnabled(GetConnectivityAppsNotificationId()) then
            exit;

        ConnectToBanks.Id := GetConnectivityAppsNotificationId();
        if ConnectToBanks.Recall() then;
        ConnectToBanks.Message := ConnectToBanksMsg;
        ConnectToBanks.Scope := NotificationScope::LocalScope;
        ConnectToBanks.AddAction(NotificationActionLbl, Codeunit::"Connectivity Apps Impl.", 'OpenBankingAppsPage');
        ConnectToBanks.SetData('NotificationId', GetConnectivityAppsNotificationId());
        ConnectToBanks.AddAction(DisableNotificationTxt, Codeunit::"Connectivity Apps Impl.", 'DisableBankingAppsNotification');
        ConnectToBanks.Send();
    end;

    local procedure GetConnectivityAppsNotificationId(): Guid
    begin
        exit('ff7ef887-2794-4f5d-a733-4807ff8cd893');
    end;
}
