// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Finance.RoleCenters;
using Microsoft.Purchases.Document;

tableextension 6101 "E-Doc. Account Payable Cue" extends "Account Payable Cue"
{
    fields
    {
        field(6100; "Unprocessed E-Documents"; Integer)
        {
            CalcFormula = count("E-Document" where(Status = filter("In Progress" | Error)));
            Caption = 'Unprocessed E-Documents';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of unprocessed E-Documents.';
        }
        field(6101; "Linked Purchase Orders"; Integer)
        {
            CalcFormula = count("Purchase Header" where("Document Type" = filter("Order"),
                                                        "E-Document Link" = filter('<>00000000-0000-0000-0000-000000000000')));
            Caption = 'Linked Purchase Orders';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of linked purchase orders.';
        }
        field(6102; "E-Documents with Errors"; Integer)
        {
            CalcFormula = count("E-Document" where(Status = filter(Error)));
            Caption = 'E-Documents with Errors';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of E-Documents with errors.';
        }
        field(6103; "Processed E-Documents TM"; Integer)
        {
            CalcFormula = count("E-Document" where(Status = filter(Processed),
                                                "Posting Date" = field("Posting Date Filter")));
            Caption = 'Processed E-Documents This Month';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Number of processed E-Documents this month.';
        }
    }
}
