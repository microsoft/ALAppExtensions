// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;
using Microsoft.Foundation.Company;
using Microsoft.eServices.EDocument;

pageextension 6440 "SignUp Company Information Ext" extends "Company Information"
{
    layout
    {
        addafter(General)
        {
            group(ExFlowEInvoicing)
            {
                Caption = 'ExFlow E-Invoicing';
                Visible = ExFlowEInvoicingVisible;

                field("SignUp Service Participant Id"; Rec."SignUp Service Participant Id")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }

    var
        ExFlowEInvoicingVisible: Boolean;

    trigger OnAfterGetRecord()
    var
        EDocumentService: Record "E-Document Service";
    begin
        EDocumentService.SetRange("Service Integration V2", EDocumentService."Service Integration V2"::"ExFlow E-Invoicing");
        ExFlowEInvoicingVisible := not EDocumentService.IsEmpty();
    end;
}