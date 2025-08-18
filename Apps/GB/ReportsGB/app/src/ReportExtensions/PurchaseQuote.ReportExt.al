// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Utilities;
using Microsoft.Foundation.Shipping;
using Microsoft.Foundation.Address;
using System.Utilities;

reportextension 10587 "Purchase - Quote" extends "Purchase - Quote"
{
#if CLEAN27
    RDLCLayout = './src/ReportExtensions/PurchaseQuote.rdlc';
#endif
    dataset
    {
        add(CopyLoop)
        {
            column(CompanyInfo_PhoneNo; CompanyInfo."Phone No.")
            {
            }
            column(CompanyInfo_VatRegNo; CompanyInfo."VAT Registration No.")
            {
            }
            column(CompanyInfo_BankName; CompanyInfo."Bank Name")
            {
            }
            column(CompanyInfo_BankAccNo; CompanyInfo."Bank Account No.")
            {
            }
            column(BuyfromVendNo__PurchaseHeader; "Purchase Header"."Buy-from Vendor No.")
            {
            }
            column(CompanyInfo_BankBranchNo; CompanyInfo."Bank Branch No.")
            {
            }
            column(CompanyInfo_PhoneNoCaption; CompanyInfoPhoneNoCaptionLbl)
            {
            }
            column(CompanyInfo_VATRegistrationNoCaption; CompanyInfoVATRegistrationNoCaptionLbl)
            {
            }
            column(CompanyInfo_BankNameCaption; CompanyInfoBankNameCaptionLbl)
            {
            }
            column(CompanyInfo_BankAccountNoCaption; CompanyInfoBankAccountNoCaptionLbl)
            {
            }
            column(CompanyInfo_BankBranchNoCaption; CompanyInfoBankBranchNoCaptionLbl)
            {
            }
            column(DocDate__PurchaseHeaderCaption; DocDate_PurchaseHeaderCaptionLbl)
            {
            }
            column(Shipment_MethodCommentCaption; ShipmentMethodCommentCaptionLbl)
            {
            }
        }
        add(RoundLoop)
        {
            column(Type__PurchaseLine; Format("Purchase Line".Type, 0, 2))
            {
            }
            column(Description__PurchaseLine; "Purchase Line".Description)
            {
            }
            column(Quantity__PurchaseLine; "Purchase Line".Quantity)
            {
            }
            column(UnitOfMeasure__PurchaseLine; "Purchase Line"."Unit of Measure")
            {
            }
            column(ExpcRecpDt__PurchHdr; Format("Purchase Line"."Expected Receipt Date"))
            {
            }
            column(VendItemNo__PurchLine; "Purchase Line"."Vendor Item No.")
            {
            }
            column(PurchaseLine_VendorItemNoCaption; PurchaseLineVendorItemNoCaptionLbl)
            {
            }
            column(Comment__PurchaseLineCaption; "Purchase Line".FieldCaption(Description))
            {
            }
            column(Quantity__PurchaseLineCaption; "Purchase Line".FieldCaption(Quantity))
            {
            }
            column(UnitOfMeasure__PurchaseLineCaption; "Purchase Line".FieldCaption("Unit of Measure"))
            {
            }
        }
        addafter(Total)
        {
            dataitem(Total_2; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));

                trigger OnPreDataItem()
                begin
                    if "Purchase Header"."Buy-from Vendor No." = "Purchase Header"."Pay-to Vendor No." then
                        CurrReport.Break();
                end;
            }
            dataitem(Integer_; Integer)
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                dataitem(Total_3; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(ShipToAddr_1; ShipToAddr_[1])
                    {
                    }
                    column(ShipToAddr_2; ShipToAddr_[2])
                    {
                    }
                    column(ShipToAddr_3; ShipToAddr_[3])
                    {
                    }
                    column(ShipToAddr_4; ShipToAddr_[4])
                    {
                    }
                    column(ShipToAddr_5; ShipToAddr_[5])
                    {
                    }
                    column(ShipToAddr_6; ShipToAddr_[6])
                    {
                    }
                    column(ShipToAddr_7; ShipToAddr_[7])
                    {
                    }
                    column(ShipToAddr_8; ShipToAddr_[8])
                    {
                    }
                    column(Shipto_AddressCaption; ShiptoAddressCaptionLbl)
                    {
                    }
                }
            }
        }
        modify("Purchase Header")
        {
            trigger OnAfterAfterGetRecord()
            begin
                FillShipToAddress("Purchase Header");
                FillShipmentMethod("Purchase Header");
            end;
        }
    }

#if not CLEAN27
    rendering
    {
        layout(GBlocalizationLayout)
        {
            Type = RDLC;
            Caption = 'Purchase Quote GB localization';
            LayoutFile = './src/ReportExtensions/PurchaseQuote.rdlc';
            ObsoleteState = Pending;
            ObsoleteReason = 'Feature Reports GB will be enabled by default in version 30.0.';
            ObsoleteTag = '27.0';
        }
    }
#endif

    var
        ShipmentMethod: Record "Shipment Method";
        CompanyInfoPhoneNoCaptionLbl: Label 'Phone No.';
        CompanyInfoVATRegistrationNoCaptionLbl: Label 'VAT Registration No.';
        CompanyInfoBankNameCaptionLbl: Label 'Bank';
        CompanyInfoBankAccountNoCaptionLbl: Label 'Account No.';
        CompanyInfoBankBranchNoCaptionLbl: Label 'Bank Branch No.';
        DocDate_PurchaseHeaderCaptionLbl: Label 'Document Date';
        PurchaseLineVendorItemNoCaptionLbl: Label 'No.';
        ShipmentMethodCommentCaptionLbl: Label 'Label1040010';
        ShiptoAddressCaptionLbl: Label 'Ship-to Address';
        ShipToAddr_: array[8] of Text[100];

    local procedure FillShipToAddress(PurchaseHeader: Record "Purchase Header")
    var
        FormatAddr: Codeunit "Format Address";
    begin
        FormatAddr.SetLanguageCode(PurchaseHeader."Language Code");
        FormatAddr.PurchHeaderShipTo(ShipToAddr_, PurchaseHeader);
    end;

    local procedure FillShipmentMethod(PurchaseHeader: Record "Purchase Header")
    var
        FormatDocument: Codeunit "Format Document";
    begin
        FormatDocument.SetShipmentMethod(ShipmentMethod, PurchaseHeader."Shipment Method Code", PurchaseHeader."Language Code");
    end;
}
