// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSForCustomer;

using Microsoft.Sales.Receivables;

page 18666 "Rectify TDS Cert. Details"
{
    Caption = 'Rectify TDS Cert. Details';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Cust. Ledger Entry";
    SourceTableView = where("TDS Certificate Receivable" = filter(true),
                            "TDS Certificate Received" = filter(true));

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the entry, when the entry was created.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the customer number from whom TDS certificate is received.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the posting date of the customer ledger entry.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document of the customer ledger entry.';
                }
                field("Document No."; Rec."Document No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the customer ledger entry.';
                }
                field(Amount; Rec.Amount)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the customer ledger entry.';
                }
                field("TDS Certificate Received"; Rec."TDS Certificate Received")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Mark in this field specify the same entry in the Rectify TDS Cert. Details window.';

                    trigger OnValidate()
                    begin
                        if Rec."TDS Certificate Received" and (Rec."Certificate No." = '') then
                            Error(EmptyCertificateDetailsErr);
                        if Rec."TDS Certificate Received" then begin
                            Rec."Certificate Received" := true;
                            Rec.Modify();
                        end;
                    end;
                }
                field("Financial Year"; Rec."Financial Year")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the financial year for which TDS certificate has received.';
                }
                field("TDS Section Code"; Rec."TDS Section Code")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Choose the TDS section code from the lookup list for which TDS certificate has received.';
                }
                field("Certificate No."; Rec."Certificate No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the certificate number as per the certificate received.';
                }
                field("TDS Certificate Rcpt Date"; Rec."TDS Certificate Rcpt Date")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which TDS certificate has been received.';
                }
                field("TDS Certificate Amount"; Rec."TDS Certificate Amount")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the TDS certificate amount as per the TDS certificate.';
                }
            }
        }
    }

    var
        EmptyCertificateDetailsErr: Label 'Certificate Received cannot be True as Certificate details are not filled up.';
}
