// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Receivables;

using Microsoft.Finance.TDS.TDSBase;

tableextension 18663 "Cust. Ledger Entry" extends "Cust. Ledger Entry"
{
    fields
    {
        field(18661; "Certificate No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(18662; "TDS Certificate Rcpt Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(18663; "TDS Certificate Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(18664; "Financial Year"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(18665; "TDS Section Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "TDS Section";
        }
        field(18666; "Certificate Received"; Boolean)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
            begin
                if not "Certificate Received" then begin
                    "Certificate No." := '';
                    "TDS Certificate Rcpt Date" := 0D;
                    "TDS Certificate Amount" := 0;
                    "Financial Year" := 0;
                    "TDS Section Code" := '';
                end;
            end;
        }
        field(18667; "TDS Certificate Receivable"; Boolean)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                TDSCertUnCheckErr: Label 'Please uncheck TDS Certificate Received.';
            begin
                if not "TDS Certificate Receivable" then
                    if "TDS Certificate Received" then
                        Error(TDSCertUnCheckErr);
            end;
        }
        field(18668; "TDS Certificate Received"; Boolean)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                TDSCertErr: Label 'TDS Certificate Received cannot be False unless TDS Receivable is False.';
            begin
                if "TDS Certificate Received" and ("TDS Certificate Receivable" = false) then
                    Error(TDSCertErr);

                if not "TDS Certificate Received" then begin
                    "Certificate No." := '';
                    "TDS Certificate Rcpt Date" := 0D;
                    "TDS Certificate Amount" := 0;
                    "Financial Year" := 0;
                    "TDS Section Code" := '';
                    "Certificate Received" := false;
                end;
            end;
        }
    }
}
