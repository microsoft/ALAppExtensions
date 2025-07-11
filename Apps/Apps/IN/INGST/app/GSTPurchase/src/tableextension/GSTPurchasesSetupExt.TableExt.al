// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Setup;

using Microsoft.Foundation.NoSeries;

tableextension 18084 "GST Purchases Setup Ext" extends "Purchases & Payables Setup"
{
    fields
    {
        field(18084; "GST Liability Adj. Jnl Nos."; Code[20])
        {
            Caption = 'GST Liability Adj. Jnl Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(18089; "RCM Exempt Start Date (Unreg)"; date)
        {
            Caption = 'RCM Exempt Start Date (Unreg)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("RCM Exempt Start Date (Unreg)" <> 0D) and ("RCM Exempt End Date (Unreg)" <> 0D) then
                    if "RCM Exempt Start Date (Unreg)" > "RCM Exempt End Date (Unreg)" then
                        Error(RcmBeforeDateErr);
            end;
        }
        field(18090; "RCM Exempt End Date (Unreg)"; date)
        {
            Caption = 'RCM Exempt End Date (Unreg)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "RCM Exempt End Date (Unreg)" < "RCM Exempt Start Date (Unreg)" then
                    Error(RcmAfterDateErr);
            end;
        }
        field(18091; "Posted Delivery Challan Nos."; Code[20])
        {
            Caption = 'Posted Delivery Challan Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(18092; "Subcontracting Order Nos."; Code[20])
        {
            Caption = 'Subcontracting Order Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(18093; "Posted SC Comp. Rcpt. Nos."; Code[20])
        {
            Caption = 'Posted SC Comp. Rcpt. Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(18094; "Delivery Challan Nos."; Code[20])
        {
            Caption = 'Delivery Challan Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(18095; "Multiple Subcon. Order Det Nos"; Code[20])
        {
            Caption = 'Multiple Subcon. Order Det Nos';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }

    var
        RcmBeforeDateErr: Label 'RCM start date must be earlier then RCM End Date.';
        RcmAfterDateErr: Label 'RCM End date must not be earlier then RCM start Date.';
}
