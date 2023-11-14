// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.History;

using Microsoft.Foundation.Address;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Transfer;

report 31205 "Posted Direct Transfer CZL"
{
    Caption = 'Posted Direct Transfer';
    Permissions = tabledata "Direct Trans. Header" = r,
                  tabledata "Direct Trans. Line" = r;
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/PostedDirectTransfer.rdl';
    ApplicationArea = Basic, Suite;
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Direct Trans. Header"; "Direct Trans. Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";

            column(LocatinFromAddr1; LocatinFromAddr[1])
            {
            }
            column(LocatinFromAddr2; LocatinFromAddr[2])
            {
            }
            column(LocatinFromAddr3; LocatinFromAddr[3])
            {
            }
            column(LocatinFromAddr4; LocatinFromAddr[4])
            {
            }
            column(LocatinFromAddr5; LocatinFromAddr[5])
            {
            }
            column(LocatinFromAddr6; LocatinFromAddr[6])
            {
            }

            column(LocatinToAddr1; LocatinToAddr[1])
            {
            }
            column(LocatinToAddr2; LocatinToAddr[2])
            {
            }
            column(LocatinToAddr3; LocatinToAddr[3])
            {
            }
            column(LocatinToAddr4; LocatinToAddr[4])
            {
            }
            column(LocatinToAddr5; LocatinToAddr[5])
            {
            }
            column(LocatinToAddr6; LocatinToAddr[6])
            {
            }
            column(TransferNo_DirectTransferHeader; "Transfer Order No.")
            {
                IncludeCaption = true;
            }
            column(TransferOrderDate_DirectTransferHeader; "Transfer Order Date")
            {
                IncludeCaption = true;
            }
            column(TransferPostUser_DirectTransferHeader; GetRegisterUserIDCZL())
            {

            }
            column(TransferPostDate_DirectTransferHeader; "Posting Date")
            {
                IncludeCaption = true;
            }
            dataitem("Direct Trans. Line"; "Direct Trans. Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemLinkReference = "Direct Trans. Header";
                DataItemTableView = sorting("Document No.", "Line No.") where(Quantity = filter(<> 0));

                column(ItemNo_DirectTransferLine; "Item No.")
                {
                    IncludeCaption = true;
                }
                column(Description_DirectTransferLine; Description)
                {
                    IncludeCaption = true;
                }
                column(Quantity_DirectTransferLine; Quantity)
                {
                    IncludeCaption = true;
                }
                column(UnitofMeasureCode_DirectTransferLine; "Unit of Measure Code")
                {
                    IncludeCaption = true;
                }

                trigger OnAfterGetRecord()
                begin
                    if Description = '' then
                        Description := GetItemDescription("Item No.");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                FormatAddress.FormatAddr(LocatinFromAddr, "Direct Trans. Header"."Transfer-from Name", "Direct Trans. Header"."Transfer-from Name 2", "Direct Trans. Header"."Transfer-from Contact", "Direct Trans. Header"."Transfer-from Address", "Direct Trans. Header"."Transfer-from Address 2", "Direct Trans. Header"."Transfer-from City", "Direct Trans. Header"."Transfer-from Post Code", "Direct Trans. Header"."Transfer-from County", "Direct Trans. Header"."Trsf.-from Country/Region Code");
                FormatAddress.FormatAddr(LocatinToAddr, "Direct Trans. Header"."Transfer-to Name", "Direct Trans. Header"."Transfer-to Name 2", "Direct Trans. Header"."Transfer-to Contact", "Direct Trans. Header"."Transfer-to Address", "Direct Trans. Header"."Transfer-to Address 2", "Direct Trans. Header"."Transfer-to City", "Direct Trans. Header"."Transfer-to Post Code", "Direct Trans. Header"."Transfer-to County", "Direct Trans. Header"."Trsf.-to Country/Region Code");

            end;
        }
    }

    labels
    {
        ReportNameLbl = 'Posted Direct Transfer';
        PageLbl = 'Page';
        TransferLbl = 'Transfer';
        PostedByLbl = 'Posted by';
    }

    var
        FormatAddress: Codeunit "Format Address";
        LocatinFromAddr: array[8] of Text[100];
        LocatinToAddr: array[8] of Text[100];

    local procedure GetItemDescription(ItemNo: Code[20]) Description: Text[100]
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Description := Item.Description;
        if Item."Description 2" <> '' then
            Description += ' ' + Item."Description 2";
    end;
}
