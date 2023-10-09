// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ServicesTransfer;

page 18356 "Service Transfer Lines"
{
    Caption = 'Service Transfer Lines';
    PageType = List;
    SourceTable = "Service Transfer Line";
    UsageCategory = Documents;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s document number.';
                }
                field("Transfer From G/L Account No."; Rec."Transfer From G/L Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account of the service being transferred.';
                }
                field("Transfer To G/L Account No."; Rec."Transfer To G/L Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number where the service will be received.';
                }
                field("Ship Control A/C No."; Rec."Ship Control A/C No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general account number for the shipment of the service.';
                }
                field("Receive Control A/C No."; Rec."Receive Control A/C No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number used for receive control account.';
                }
                field("Transfer Price"; Rec."Transfer Price")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the price for the transfer of the service.';
                }
            }
        }
    }
}
