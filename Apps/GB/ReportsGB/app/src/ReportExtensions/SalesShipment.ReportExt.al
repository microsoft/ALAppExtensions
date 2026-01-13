// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.Foundation.Address;
using System.Utilities;

reportextension 10586 "Sales - Shipment" extends "Sales - Shipment"
{
#if CLEAN27
    RDLCLayout = './src/ReportExtensions/SalesShipment.rdlc';
#endif
    dataset
    {
        add("Sales Shipment Header")
        {
            column(DocumentDate_Caption; DocumentDateCaptionLbl)
            {
            }
            column(HomePage_Caption; HomePageCaptionLbl)
            {
            }
            column(Email_Caption; EmailCaptionLbl)
            {
            }
        }
        add(CopyLoop)
        {
            column(CompanyInfo_BankBranchNo; CompanyInfo."Bank Branch No.")
            {
            }
            column(CompanyInfo_BankBranchNoCaption; CompanyInfoBankBranchNoCaptionLbl)
            {
            }

        }
        addafter(Total)
        {
            dataitem(Integer_; Integer)
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                dataitem(Total_2; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(BilltoCustNo__SalesShipmentHdr; "Sales Shipment Header"."Bill-to Customer No.")
                    {
                    }
                    column(CustAddr_1; CustAddr[1])
                    {
                    }
                    column(CustAddr_2; CustAddr[2])
                    {
                    }
                    column(CustAddr_3; CustAddr[3])
                    {
                    }
                    column(CustAddr_4; CustAddr[4])
                    {
                    }
                    column(CustAddr_5; CustAddr[5])
                    {
                    }
                    column(CustAddr_6; CustAddr[6])
                    {
                    }
                    column(CustAddr_7; CustAddr[7])
                    {
                    }
                    column(CustAddr_8; CustAddr[8])
                    {
                    }
                    column(BilltoAddress_Caption; BilltoAddressCaptionLbl)
                    {
                    }
                    column(BilltoCustNo__SalesShipmentHdrCaption; "Sales Shipment Header".FieldCaption("Bill-to Customer No."))
                    {
                    }
                }
            }
        }
        modify("Sales Shipment Header")
        {
            trigger OnAfterAfterGetRecord()
            begin
                FillCustAddr();
            end;
        }
    }
    requestpage
    {
        layout
        {
            modify(LogInteraction)
            {
                ToolTip = 'Specifies if you want the program to log this interaction.';
            }
        }
    }

#if not CLEAN27
    rendering
    {
        layout(GBlocalizationLayout)
        {
            Type = RDLC;
            Caption = 'Sales Shipment GB localization';
            LayoutFile = './src/ReportExtensions/SalesShipment.rdlc';
            ObsoleteState = Pending;
            ObsoleteReason = 'Feature Reports GB will be enabled by default in version 30.0.';
            ObsoleteTag = '27.0';
        }
    }
#endif

    var
        CompanyInfoBankBranchNoCaptionLbl: Label 'Bank Branch No.';
        DocumentDateCaptionLbl: Label 'Document Date';
        HomePageCaptionLbl: Label 'Home Page';
        EmailCaptionLbl: Label 'Email';
        BilltoAddressCaptionLbl: Label 'Bill-to Addres0s';
        CustAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];

    procedure FillCustAddr()
        FormatAddr: Codeunit "Format Address";
    begin
        FormatAddr.SetLanguageCode("Sales Shipment Header"."Language Code");
        FormatAddr.SalesShptShipTo(ShipToAddr, "Sales Shipment Header");
        FormatAddr.SalesShptBillTo(CustAddr, ShipToAddr, "Sales Shipment Header");
    end;
}