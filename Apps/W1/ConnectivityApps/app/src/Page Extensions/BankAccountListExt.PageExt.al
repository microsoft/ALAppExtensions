// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

pageextension 20351 "Bank Account List Ext." extends "Bank Account List"
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
                AboutTitle = 'Streamline your bookkeeping';
                AboutText = 'Easily and securely connect to banks online to import transactions for bank account reconciliation and payment transfers.';

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
    end;

    var
        ConnectivityApps: Codeunit "Connectivity Apps";
        ConnectivityAppsCategory: Enum "Connectivity Apps Category";
        IsConnectivityAppsAvailable: Boolean;
}
