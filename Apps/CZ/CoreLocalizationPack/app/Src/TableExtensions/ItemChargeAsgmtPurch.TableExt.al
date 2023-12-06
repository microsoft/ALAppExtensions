// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;
#if not CLEAN22

using Microsoft.Foundation.Company;
using Microsoft.Purchases.History;
#endif

tableextension 31019 "Item Charge Asgmt. (Purch) CZL" extends "Item Charge Assignment (Purch)"
{
    fields
    {
        field(31052; "Incl. in Intrastat Amount CZL"; Boolean)
        {
            Caption = 'Incl. in Intrastat Amount';
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
#if not CLEAN22

            trigger OnValidate()
            begin
#pragma warning disable AL0432
                StatutoryReportingSetupCZL.CheckItemChargesInIntrastatCZL();
#pragma warning restore AL0432
            end;
#endif
        }
        field(31053; "Incl. in Intrastat S.Value CZL"; Boolean)
        {
            Caption = 'Incl. in Intrastat Stat. Value';
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
#if not CLEAN22

            trigger OnValidate()
            begin
#pragma warning disable AL0432
                StatutoryReportingSetupCZL.CheckItemChargesInIntrastatCZL();
#pragma warning restore AL0432
            end;
#endif
        }
    }
#if not CLEAN22
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";

    [Obsolete('Intrastat related functionalities are moved to Intrastat extensions.', '22.0')]
    procedure SetIncludeAmountCZL(): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
    begin
        if PurchaseHeader.Get("Document Type", "Document No.") then begin
            VendorNo := GetVendor();
            if (VendorNo <> '') then
                exit(PurchaseHeader."Buy-from Vendor No." = VendorNo);
        end;
    end;

    local procedure GetVendor(): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        VendorNo: Code[20];
    begin
        case "Applies-to Doc. Type" of
            "Applies-to Doc. Type"::Order, "Applies-to Doc. Type"::Invoice,
            "Applies-to Doc. Type"::"Return Order", "Applies-to Doc. Type"::"Credit Memo":
                begin
                    PurchaseHeader.Get("Applies-to Doc. Type", "Applies-to Doc. No.");
                    VendorNo := PurchaseHeader."Buy-from Vendor No.";
                end;
            "Applies-to Doc. Type"::Receipt:
                begin
                    PurchRcptHeader.Get("Applies-to Doc. No.");
                    VendorNo := PurchRcptHeader."Buy-from Vendor No.";
                end;
            "Applies-to Doc. Type"::"Return Shipment":
                begin
                    ReturnShipmentHeader.Get("Applies-to Doc. No.");
                    VendorNo := ReturnShipmentHeader."Buy-from Vendor No.";
                end;
            "Applies-to Doc. Type"::"Transfer Receipt":
                VendorNo := '';
            "Applies-to Doc. Type"::"Sales Shipment":
                VendorNo := '';
            "Applies-to Doc. Type"::"Return Receipt":
                VendorNo := '';
        end;

        exit(VendorNo);
    end;
#endif
}
