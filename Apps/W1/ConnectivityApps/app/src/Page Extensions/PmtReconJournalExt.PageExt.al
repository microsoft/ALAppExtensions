// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

pageextension 20356 "Pmt. Recon. Journal Ext." extends "Pmt. Reconciliation Journals"
{
    actions
    {
        addlast(Bank)
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
        addlast(Category_Category4)
        {
            actionref("Connect to Banks Promoted"; "Connect to Banks")
            {
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
